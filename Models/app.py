from flask import Flask, request, jsonify
from flask_cors import CORS
import numpy as np
import joblib
import tensorflow as tf
import traceback
import os
from werkzeug.utils import secure_filename

from gait import GaitAnalyzer

app = Flask(__name__)
CORS(app)

UPLOAD_FOLDER = "uploads"
os.makedirs(UPLOAD_FOLDER, exist_ok=True)

try:
    fall_model = joblib.load('fall_risk_model.joblib')
    print("✅ Fall risk model loaded")
except Exception as e:
    print("❌ Fall model error:", e)
    fall_model = None

try:
    fog_model = tf.keras.models.load_model(
        'fog_ensemble.keras'
    )
    print("✅ FOG model loaded")
except Exception as e:
    print("❌ FOG model error:", e)
    fog_model = None

gait_analyzer = GaitAnalyzer()

@app.route('/predict_fall', methods=['POST'])
def predict_fall():

    if fall_model is None:
        return jsonify({'error': 'Fall model not loaded'}), 503

    try:
        data = request.get_json()

        if not data or 'features' not in data:
            return jsonify({'error': 'Missing features'}), 400

        features = data['features']

        if len(features) != 11:
            return jsonify({'error': 'Expected 11 features'}), 400

        X = np.array(features, dtype=np.float32).reshape(1, -1)

        proba = fall_model.predict_proba(X)[0]

        risk = float(proba[1])

        risk = max(0.0, min(1.0, risk))

        return jsonify({
            'risk': risk
        })

    except Exception as e:
        traceback.print_exc()
        return jsonify({'error': str(e)}), 500


@app.route('/predict_fog', methods=['POST'])
def predict_fog():

    if fog_model is None:
        return jsonify({'error': 'FOG model not loaded'}), 503

    try:
        data = request.get_json()

        if 'input' not in data:
            return jsonify({'error': 'Missing input'}), 400

        input_data = np.array(data['input'])

        if input_data.shape == (100, 9):
            input_data = input_data.reshape(1, 100, 9)

        elif input_data.shape != (1, 100, 9):
            return jsonify({
                'error': f'Expected (100,9) or (1,100,9), got {input_data.shape}'
            }), 400

        pred = fog_model.predict(input_data)

        return jsonify({
            'prediction': float(pred[0][0])
        })

    except Exception as e:
        traceback.print_exc()
        return jsonify({'error': str(e)}), 500


@app.route('/analyze_gait', methods=['POST'])
def analyze_gait():

    try:

        if 'video' not in request.files:
            return jsonify({'error': 'No video uploaded'}), 400

        file = request.files['video']

        filename = secure_filename(file.filename)

        filepath = os.path.join(UPLOAD_FOLDER, filename)

        file.save(filepath)

        result = gait_analyzer.analyze(filepath)

        return jsonify({
            'classification': result.classification,
            'confidence': result.confidence,
            'risk_score': result.risk_score,
            'avg_knee_angle': result.avg_knee_angle,
            'avg_hip_angle': result.avg_hip_angle,
            'symmetry_score': result.symmetry_score,
            'cadence_spm': result.cadence_spm,
            'gait_speed_kmh': result.gait_speed_kmh,
            'stride_length_m': result.stride_length_m,
            'issues': result.issues,
            'frames_analyzed': result.frames_analyzed
        })

    except Exception as e:
        traceback.print_exc()
        return jsonify({'error': str(e)}), 500


@app.route('/')
def home():
    return jsonify({
        'status': 'running'
    })

if __name__ == '__main__':
    app.run(
        host='0.0.0.0',
        port=5000,
        threaded=True,
        debug=False
    )