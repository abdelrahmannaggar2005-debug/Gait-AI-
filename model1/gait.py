"""
Gait Analysis Model  v2
- Input  : video file path
- Output : GaitResult (classification + metrics)
- Engine : OpenCV optical flow + joint angle estimation (no external model files)
- Speed  : ~real-time on CPU
"""

import cv2
import numpy as np
import math
from dataclasses import dataclass, field


# ── Result dataclass ───────────────────────────────────────────────────────────

@dataclass
class GaitResult:
    classification: str       # "Normal" | "Abnormal"
    confidence: float         # 0.0 – 1.0
    risk_score: float         # 0.0 – 1.0
    avg_knee_angle: float
    avg_hip_angle: float
    symmetry_score: float
    cadence_spm: float
    gait_speed_kmh: float
    stride_length_m: float
    issues: list = field(default_factory=list)
    frames_analyzed: int = 0


# ── Core analyser ──────────────────────────────────────────────────────────────

class GaitAnalyzer:
    """
    Analyzes gait from video using:
    1. Background subtraction  → detect moving person
    2. Bounding box tracking   → measure body proportions & motion
    3. Optical flow            → measure limb oscillation & symmetry
    4. Rule-based classifier   → Normal / Abnormal
    """

    KNEE_ANGLE_MIN   = 140
    HIP_ANGLE_MIN    = 150
    SYMMETRY_MIN     = 0.70
    CADENCE_MIN      = 80
    CADENCE_MAX      = 140
    SPEED_MIN        = 2.0

    def analyze(self, video_path: str) -> GaitResult:
        cap = cv2.VideoCapture(video_path)
        if not cap.isOpened():
            raise ValueError(f"Cannot open video: {video_path}")

        fps   = cap.get(cv2.CAP_PROP_FPS) or 30.0
        w     = int(cap.get(cv2.CAP_PROP_FRAME_WIDTH))
        h     = int(cap.get(cv2.CAP_PROP_FRAME_HEIGHT))

        bg_sub = cv2.createBackgroundSubtractorMOG2(
            history=200, varThreshold=40, detectShadows=False
        )

        # ── Accumulators ─────────────────────────────
        prev_gray    = None
        flow_left    = []   # left-half optical flow magnitude
        flow_right   = []   # right-half optical flow magnitude
        bbox_heights = []   # person bounding box height (px)
        bbox_cx      = []   # centroid x (for horizontal sway)
        motion_y     = []   # vertical motion of lower body centroid
        frame_count  = 0
        valid_frames = 0

        while True:
            ok, frame = cap.read()
            if not ok:
                break
            frame_count += 1
            if frame_count % 2 != 0:   # process every other frame
                continue

            gray = cv2.cvtColor(frame, cv2.COLOR_BGR2GRAY)
            fg   = bg_sub.apply(frame)

            # ── Person bounding box via foreground mask ──
            kernel = cv2.getStructuringElement(cv2.MORPH_ELLIPSE, (5, 5))
            fg     = cv2.morphologyEx(fg, cv2.MORPH_CLOSE, kernel)
            cnts, _= cv2.findContours(fg, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)

            if cnts:
                largest = max(cnts, key=cv2.contourArea)
                if cv2.contourArea(largest) > 1500:   # ignore noise
                    x, y, bw, bh = cv2.boundingRect(largest)
                    bbox_heights.append(bh)
                    bbox_cx.append(x + bw // 2)
                    # lower-body centroid (below mid-point)
                    motion_y.append(y + bh * 0.75)
                    valid_frames += 1

            # ── Optical flow left vs right ──
            if prev_gray is not None:
                flow = cv2.calcOpticalFlowFarneback(
                    prev_gray, gray, None,
                    0.5, 3, 15, 3, 5, 1.2, 0
                )
                mag, _ = cv2.cartToPolar(flow[..., 0], flow[..., 1])
                mid    = w // 2
                flow_left.append(float(np.mean(mag[:, :mid])))
                flow_right.append(float(np.mean(mag[:, mid:])))

            prev_gray = gray

        cap.release()

        if valid_frames < 5:
            raise ValueError(
                "Could not detect a walking person. "
                "Ensure the full body is visible with good lighting."
            )

        duration_s = (frame_count / 2) / fps

        # ── Derived metrics ───────────────────────────────────────────────────

        # 1) Cadence from lower-body vertical oscillation
        cadence = self._cadence_from_signal(motion_y, fps, duration_s)

        # 2) Symmetry from left/right optical flow balance
        if flow_left and flow_right:
            lmean = np.mean(flow_left)
            rmean = np.mean(flow_right)
            total = lmean + rmean + 1e-9
            symmetry = 1 - abs(lmean - rmean) / total
        else:
            symmetry = 0.85

        # 3) Estimate knee & hip angles from bounding box proportions
        #    (heuristic: taller bbox → more extension → larger angle)
        avg_h    = np.mean(bbox_heights) if bbox_heights else h * 0.6
        ratio    = avg_h / h   # 0..1
        avg_knee = 100 + ratio * 70   # maps 0→100°, 1→170°
        avg_hip  = 120 + ratio * 60

        # 4) Horizontal sway → adds to abnormality
        sway = np.std(bbox_cx) / w if bbox_cx else 0.05

        # 5) Speed heuristic
        stride_length  = self._estimate_stride(avg_knee, cadence)
        gait_speed_kmh = (stride_length * cadence / 60) * 3.6

        # ── Classification ────────────────────────────────────────────────────
        issues    = []
        penalties = 0.0

        if avg_knee < self.KNEE_ANGLE_MIN:
            issues.append(f"Limited knee extension ({avg_knee:.1f}°)")
            penalties += 0.30

        if avg_hip < self.HIP_ANGLE_MIN:
            issues.append(f"Reduced hip flexion ({avg_hip:.1f}°)")
            penalties += 0.20

        if symmetry < self.SYMMETRY_MIN:
            issues.append(f"Gait asymmetry ({symmetry * 100:.0f}%)")
            penalties += 0.25

        if cadence < self.CADENCE_MIN:
            issues.append(f"Low cadence ({cadence:.0f} spm)")
            penalties += 0.10

        if gait_speed_kmh < self.SPEED_MIN:
            issues.append(f"Slow gait speed ({gait_speed_kmh:.1f} km/h)")
            penalties += 0.10

        if sway > 0.12:
            issues.append(f"Excessive lateral sway ({sway*100:.1f}%)")
            penalties += 0.15

        risk_score     = min(penalties, 1.0)
        confidence     = min(0.55 + valid_frames / 200, 0.94)
        classification = "Normal" if risk_score < 0.30 else "Abnormal"

        return GaitResult(
            classification  = classification,
            confidence      = round(confidence, 2),
            risk_score      = round(risk_score, 2),
            avg_knee_angle  = round(avg_knee, 1),
            avg_hip_angle   = round(avg_hip, 1),
            symmetry_score  = round(symmetry, 2),
            cadence_spm     = round(cadence, 1),
            gait_speed_kmh  = round(gait_speed_kmh, 1),
            stride_length_m = round(stride_length, 2),
            issues          = issues,
            frames_analyzed = valid_frames,
        )

    # ── Helpers ───────────────────────────────────────────────────────────────

    def _cadence_from_signal(self, signal: list, fps: float, duration_s: float) -> float:
        if len(signal) < 8:
            return 100.0
        arr = np.array(signal, dtype=float)
        arr = (arr - arr.mean()) / (arr.std() + 1e-9)
        crosses = np.where(np.diff(np.sign(arr)))[0]
        steps   = len(crosses)
        effective_dur = max(duration_s, 1.0)
        cadence = (steps / effective_dur) * 30   # tuned constant
        return float(np.clip(cadence, 60, 160))

    def _estimate_stride(self, knee_angle: float, cadence: float) -> float:
        base   = 1.25
        kf     = min(knee_angle / 165.0, 1.0)
        cf     = min(cadence   / 110.0, 1.0)
        return base * kf * cf


if __name__ == "__main__":

    video_path = input("Enter video path: ").strip()

    analyzer = GaitAnalyzer()

try:
    result = analyzer.analyze(video_path)

    print("\n===== GAIT ANALYSIS RESULT =====")
    print(f"Classification : {result.classification}")
    print(f"Confidence     : {result.confidence}")
    print(f"Risk Score     : {result.risk_score}")

    print(f"Knee Angle     : {result.avg_knee_angle}°")
    print(f"Hip Angle      : {result.avg_hip_angle}°")
    print(f"Symmetry       : {result.symmetry_score}")

    print(f"Cadence        : {result.cadence_spm} spm")
    print(f"Gait Speed     : {result.gait_speed_kmh} km/h")
    print(f"Stride Length  : {result.stride_length_m} m")

    print(f"Frames         : {result.frames_analyzed}")

    if result.issues:
        print("\nDetected Issues:")
        for issue in result.issues:
            print("-", issue)

except Exception as e:
    print("Error:", e)
