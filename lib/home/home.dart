import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:camera/camera.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:pedometer/pedometer.dart';
import 'package:permission_handler/permission_handler.dart';
import './fog_api.dart';
import 'fall_risk_api.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:GaitAI/getstart.dart';

const kBg = Color.fromARGB(255, 255, 255, 255);
const kCard = Color(0xFFFFFFFF);
const kCard2 = Color(0xFFF8FAFF);
const kBorder = Color(0xFFD0DEFA);
const kPrimary = Color(0xFF398BEF);
const kAccent = Color(0xFF0099CC);
const kGreen = Color(0xFF10B981);
const kOrange = Color(0xFFF59E0B);
const kRed = Color(0xFFEF4444);
const kText = Color(0xFF0D1B3E);
const Color kBg2 = Color(0xFF0D1525);
const Color kTextDim = Color(0xFF64748B);
const kGlow = Color(0xFF1A4B8F);
const kTextSub = Color(0xFF6B87AA);
const kSurface = Color(0xFFE4EDFC);

// ── Theme-aware colors ──────────────────────────────────────────────────────
extension ThemeColors on BuildContext {
  Color get card => Theme.of(this).brightness == Brightness.dark
      ? const Color(0xFF1A2540)
      : kCard;
  Color get card2 => Theme.of(this).brightness == Brightness.dark
      ? const Color(0xFF0F1A2E)
      : kCard2;
  Color get border => Theme.of(this).brightness == Brightness.dark
      ? const Color(0xFF2A3A5C)
      : kBorder;
  Color get text =>
      Theme.of(this).brightness == Brightness.dark ? Colors.white : kText;
  Color get surface => Theme.of(this).brightness == Brightness.dark
      ? const Color(0xFF0D1525)
      : kSurface;

  Color get txt => Theme.of(this).brightness == Brightness.dark
      ? const Color(0xFFFFFFFF)
      : kText;

  Color get txtDim => Theme.of(this).brightness == Brightness.dark
      ? const Color.fromARGB(255, 185, 197, 213)
      : kTextDim;

  Color get txtSub => Theme.of(this).brightness == Brightness.dark
      ? const Color.fromARGB(255, 205, 206, 207)
      : kTextSub;
  Color get PBg => Theme.of(this).brightness == Brightness.dark
      ? kBg2
      : kBg;
}

class AppStrings {
  static bool isArabic = false;

  static String get home => isArabic ? 'الرئيسية' : 'Home';
  static String get analyze => isArabic ? 'تحليل' : 'Analyze';
  static String get history => isArabic ? 'السجل' : 'History';
  static String get profile => isArabic ? 'الملف' : 'Profile';
  static String get goodMorning => isArabic ? 'صباح الخير' : 'Good Morning';
  static String get lastName => isArabic ? 'عبدالرحمن' : 'Abdelrahman';
  static String get readyText => isArabic
      ? 'مستعد لتحليل مشيتك اليوم؟'
      : 'Ready to analyze your gait today?';
  static String get startAnalysis =>
      isArabic ? 'ابدأ التحليل' : 'Start Analysis';
  static String get uploadVideo => isArabic ? 'رفع فيديو' : 'Upload Video';
  static String get latestResult => isArabic ? 'آخر نتيجة' : 'Latest Result';
  static String get strideLen => isArabic ? 'طول الخطوة' : 'Stride Length';
  static String get cadence => isArabic ? 'معدل الخطى' : 'Cadence';
  static String get gaitSpeed => isArabic ? 'سرعة المشي' : 'Gait Speed';
  static String get kneeAngle => isArabic ? 'زاوية الركبة' : 'Knee Angle';
  static String get hipAngle => isArabic ? 'زاوية الورك' : 'Hip Angle';
  static String get symmetry => isArabic ? 'مؤشر التماثل' : 'Symmetry';
  static String get fallRisk => isArabic ? 'خطر السقوط' : 'Fall Risk';
  static String get normal => isArabic ? 'طبيعي' : 'Normal';
  static String get moderate => isArabic ? 'متوسط' : 'Moderate';
  static String get fogAnalysis => isArabic ? ' تجمد المشي' : 'Fog Analysis';
  static String get high => isArabic ? 'مرتفع' : 'High';
  static String get low => isArabic ? 'منخفض' : 'Low';
  static String get previousSessions =>
      isArabic ? 'الجلسات السابقة' : 'Previous Sessions';
  static String get myProfile => isArabic ? 'ملفي الشخصي' : 'My Profile';
  static String get personalInfo =>
      isArabic ? 'المعلومات الشخصية' : 'Personal Info';
  static String get email => isArabic ? 'البريد الإلكتروني' : 'Email';
  static String get password => isArabic ? 'كلمة المرور' : 'Password';
  static String get weight => isArabic ? 'الوزن' : 'Weight';
  static String get language => isArabic ? 'اللغة' : 'Language';
  static String get arabic => isArabic ? 'العربية' : 'Arabic';
  static String get english => isArabic ? 'الإنجليزية' : 'English';
  static String get notifications => isArabic ? 'الإشعارات' : 'Notifications';
  static String get darkMode => isArabic ? 'الوضع الليلي' : 'Dark Mode';
  static String get recordVideo => isArabic ? 'تسجيل فيديو' : 'Record Video';
  static String get analyzing => isArabic ? 'جاري التحليل...' : 'Analyzing...';
  static String get tapToRecord => isArabic ? 'اضغط للتسجيل' : 'Tap to Record';
  static String get walkInstruct => isArabic
      ? 'امشِ 3-5 أمتار بجانب الكاميرا'
      : 'Walk 3-5 meters sideways to camera';
  static String get viewResult => isArabic ? 'عرض النتيجة' : 'View Result';
  static String get orUpload =>
      isArabic ? 'أو ارفع فيديو موجود' : 'or upload existing video';
  static String get totalSessions =>
      isArabic ? 'إجمالي الجلسات' : 'Total Sessions';
  static String get avgSpeed => isArabic ? 'متوسط السرعة' : 'Avg Speed';
  static String get improvement => isArabic ? 'التحسن' : 'Improvement';
  static String get today => isArabic ? 'اليوم' : 'Today';
  static String get yesterday => isArabic ? 'أمس' : 'Yesterday';
  static String get daysAgo => isArabic ? 'أيام مضت' : 'days ago';
  static String get medCondition =>
      isArabic ? 'الحالة الطبية' : 'Medical Condition';
  static String get units => isArabic ? 'الوحدات' : 'Units';
  static String get metric => isArabic ? 'متري' : 'Metric';
  static String get imperial => isArabic ? 'إمبراطوري' : 'Imperial';
  static String get editProfile => isArabic ? 'تعديل الملف' : 'Edit Profile';
  static String get signOut => isArabic ? 'تسجيل الخروج' : 'Sign Out';
  static String get appSettings =>
      isArabic ? 'إعدادات التطبيق' : 'App Settings';
  static String get weeklyTrend => isArabic ? 'الأسبوع الماضي' : 'Weekly Trend';
  static String get yourStats => isArabic ? 'إحصائياتك' : 'Your Stats';
  static String get km => isArabic ? 'كم/س' : 'km/h';
  static String get meter => isArabic ? 'م' : 'm';
  static String get steps => isArabic ? 'خطوة/دقيقة' : 'spm';
  static String get UploadTask => isArabic
      ? 'قم بتسجيل أو تحميل فيديو للمشي'
      : 'Record or upload a walking video';
  static String get Taptostartrecording =>
      isArabic ? 'انقر لبدء التسجيل' : 'Tap to start recording';
  static String get position => isArabic ? 'الموقع' : 'Position';
  static String get record => isArabic ? 'التسجيل' : 'Record';
  static String get results => isArabic ? 'النتائج' : 'Results';
  static String get Placephoneatwaistheightonastablesurface => isArabic
      ? 'ضع الهاتف على مستوى الخصر على سطح مستقر'
      : 'Place phone at waist height on a stable surface';
  static String get oruploadexistingvideo =>
      isArabic ? 'أو ارفع فيديو موجود' : 'or upload existing video';
  static String get RecordingTips =>
      isArabic ? 'نصائح التسجيل' : 'Recording Tips';
  static String get Walknaturallydontchangeyournormalgait => isArabic
      ? 'امشِ بشكل طبيعي، لا تغير مشيتك العادية'
      : 'Walk naturally, don\'t change your normal gait';
  static String get Ensuregoodlightingavoidbacklight => isArabic
      ? 'تأكد من الإضاءة الجيدة، تجنب الإضاءة الخلفية'
      : 'Ensure good lighting, avoid backlight';
  static String get Stay23metersawayfromthecamera => isArabic
      ? 'ابق على مسافة 2-3 أمتار من الكاميرا'
      : 'Stay 2-3 meters away from the camera';
  static String get fogDetector => isArabic ? ' تجمد المشي' : 'FOG Detector';
  static String get startMonitoring =>
      isArabic ? 'بدء المراقبة' : 'Start Monitoring';
  static String get stopMonitoring =>
      isArabic ? 'إيقاف المراقبة' : 'Stop Monitoring';
  static String get monitoringActive =>
      isArabic ? 'المراقبة نشطة في الخلفية' : 'Monitoring active';
  static String get lastEvent => isArabic ? 'آخر حدث: ' : 'Last event: ';
  static String get minutesAgo => isArabic ? 'دقيقة مضت' : 'min ago';
  static String get fogSessions => isArabic ? 'جلسات FOG' : 'FOG Sessions';
  static String get totalFreezes =>
      isArabic ? 'إجمالي التجمدات' : 'Total Freezes';
  static String get avgDuration => isArabic ? 'متوسط المدة' : 'Avg Duration';
  static String get longestFreeze => isArabic ? 'أطول تجمد' : 'Longest Freeze';
  static String get fogDetected =>
      isArabic ? 'تم اكتشاف تجمد!' : 'FOG Detected!';
  static String get stepNow => isArabic ? 'ارفع رجلك الآن!' : 'Step now!';
  static String get fogevent => isArabic ? '(FOG) أحداث' : 'FOG Events';
  static String get safe => isArabic ? 'آمن' : 'SAFE';
  static String get highRisk => isArabic ? 'خطر عالي' : 'HIGH RISK';
  static String get freezingOfGaitDetector =>
      isArabic ? 'كاشف تجمد المشي' : 'Freezing of Gait Detector';
  static String get sensorReadings =>
      isArabic ? 'قراءات الحساس' : 'Sensor Readings';
  static String get accelerometer =>
      isArabic ? 'محسّن التسارع' : 'Accelerometer';
  static String get stop => isArabic ? 'إيقاف' : 'Stop';
  static String get session => isArabic ? 'جلسة' : 'Session';
  static String get gyroscope => isArabic ? 'جهاز قياس الدوران' : 'Gyroscope';
  static String get aiready => isArabic ? 'جاهز ' : 'AI Ready';
  static String get magnetometer =>
      isArabic ? 'مقياس المغناطيسية' : 'Magnetometer';
  static String get fallRiskAssessment =>
      isArabic ? 'تقييم خطر السقوط' : 'Fall Risk Assessment';
  static String get morseScaleDescription => isArabic
      ? 'مقياس مورس · نموذج التنبؤ السريري'
      : 'Morse Scale · Clinical Prediction Model';
  static String get patientInfo =>
      isArabic ? 'العلامات الحيوية للمريض' : 'PATIENT VITALS';
  static String get clinicalHistory =>
      isArabic ? 'التاريخ الطبي للمريض' : 'CLINICAL HISTORY';
  static String get functionalStatus =>
      isArabic ? 'الحالة الوظيفية للمريض' : 'Mobility & Status';
  static String get conditions =>
      isArabic ? 'الحالات الصحية للمريض' : 'CONDITIONS';
  static String get calculateRisk => isArabic ? 'حساب الخطر' : 'Calculate Risk';
  static String get calculateing =>
      isArabic ? 'جاري الحساب...' : 'Calculating...';
  static String get noassessmentyet =>
      isArabic ? 'لا تقييم بعد' : 'No Assessment Yet';
  static String get yourGaitIsExcellentThisWeek => isArabic
      ? 'مشيتك ممتازة هذا الأسبوع!'
      : 'Your gait is excellent this week!';
  static String get implementFallPreventionProtocol => isArabic
      ? 'نفذ بروتوكول الوقاية من السقوط.'
      : 'Implement fall prevention protocol.';
  static String get highRiskInterventionsRequired => isArabic
      ? 'تدخلات خطر عالية مطلوبة.'
      : 'High-risk interventions required.';
  static String get completeAssessmentToSeeResults => isArabic
      ? 'أكمل التقييم لرؤية النتائج.'
      : 'Complete the assessment to see results.';
  static String get fillInAllFieldsAndTapCalculateRiskToSeeResults => isArabic
      ? 'املأ جميع الحقول وانقر على "حساب الخطر" لرؤية النتائج.'
      : 'Fill in all fields and tap\nCalculate Risk to see results.';
  static String get age => isArabic ? 'العمر' : 'Age';
  static String get bmi => isArabic ? 'مؤشر كتلة الجسم' : 'BMI';
  static String get historyOfFalls =>
      isArabic ? 'تاريخ السقوط' : 'History of Falls';
  static String get secondaryDiagnosis =>
      isArabic ? 'تشخيص ثانوي' : 'Secondary Diagnosis';
  static String get ambulatoryAid =>
      isArabic ? 'وسيلة مساعدة على المشي' : 'Ambulatory Aid';
  static String get ivTherapy => isArabic ? 'العلاج الوريدي' : 'IV Therapy';
  static String get gaitStatus => isArabic ? 'حالة المشي' : 'Gait Status';
  static String get mentalStatus =>
      isArabic ? 'الحالة العقلية' : 'Mental Status';
  static String get visionImpairment =>
      isArabic ? 'ضعف البصر' : 'Vision Impairment';
  static String get osteoporosis => isArabic ? 'هشاشة العظام' : 'Osteoporosis';
  static String get medicationsCount =>
      isArabic ? 'عدد الأدوية' : 'Medications Count';
  static String get totalNumberOfCurrentMedications => isArabic
      ? 'إجمالي عدد الأدوية الحالية'
      : 'Total number of current medications';
  // static String get historyOfFalls => isArabic ? 'تاريخ السقوط' : 'History of Falls';
  // static String get secondaryDiagnosis => isArabic ? 'تشخيص ثانوي' : 'Secondary Diagnosis';
  // static String get ambulatoryAid => isArabic ? 'وسيلة مساعدة على المشي' : 'Ambulatory Aid';
  // static String get ivTherapy => isArabic ? 'العلاج الوريدي' : 'IV Therapy';
  // static String get gaitStatus => isArabic ? 'حالة المشي' : 'Gait Status';
  // static String get mentalStatus => isArabic ? 'الحالة العقلية' : 'Mental Status';
  // static String get visionImpairment => isArabic ? 'ضعف البصر' : 'Vision Impairment';
  static String get lowrisk => isArabic ? 'خطر منخفض' : 'Low Risk';
  static String get moderaterisk => isArabic ? 'خطر متوسط' : 'Moderate Risk';
  static String get highrisk => isArabic ? 'خطر عالٍ' : 'High Risk';
  static String get years => isArabic ? 'سنوات' : 'Years';
  static String get hasThePatientFallenBefore =>
      isArabic ? 'هل سقط المريض من قبل؟' : 'Has the patient fallen before?';
  static String get anySecondaryConditionPresent => isArabic
      ? 'هل هناك حالات ثانوية Present؟'
      : 'Is there any secondary condition present?';
  static String get isPatientReceivingIVTherapy => isArabic
      ? 'هل المريض يحصل على العلاج الوريدي؟'
      : 'Is the patient receiving IV therapy?';
  static String get isCognitiveFunctionImpaired => isArabic
      ? 'هل الوظيفة الذهنية متأثرة؟'
      : 'Is cognitive function impaired?';
  static String get doesThePatientHaveVisionIssues => isArabic
      ? 'هل المريض يعاني من مشاكل في البصر؟'
      : 'Does the patient have vision issues?';
  static String get hasOsteoporosisBeenDiagnosed => isArabic
      ? 'هل تم تشخيص هشاشة العظام؟'
      : 'Has osteoporosis been diagnosed?';
  static String get no => isArabic ? 'لا' : 'No';
  static String get yes => isArabic ? 'نعم' : 'Yes';
  static String get impaired => isArabic ? 'متأثر' : 'Impaired';
  static String get abnormal => isArabic ? 'غير طبيعي' : 'Abnormal';
  static String get severe => isArabic ? 'شديد' : 'Severe';
  static String get none => isArabic ? 'لا شيء' : 'None';
  static String get cane => isArabic ? 'عصا' : 'Cane';
  static String get clinicalInsights => isArabic ? 'الرؤى السريرية' : 'Clinical Insights';
  static String get aiGenerated => isArabic ? 'مُولَّد من قبل الذكاء الاصطناعي' : 'AI Generated';
  static String get walker => isArabic ? 'مساعد على المشي' : 'Walker';
  static String get rotationrate => isArabic ? 'معدل الدوران' : 'Rotation Rate';
  static String get orientation => isArabic ? 'التوجيه' : 'Orientation';
  static String get readyToAnalyze =>
      isArabic ? 'جاهز للتحليل' : 'Ready to Analyze';
  static String get aiPoweredMotionAssessment => isArabic
      ? 'تقييم الحركة المدعوم بالذكاء الاصطناعي'
      : 'AI-powered Motion Assessment';
  static String get uploadGaitVideo =>
      isArabic ? 'رفع فيديو المشي' : 'Upload Gait Video';
  static String get tapToSelectVideo => isArabic
      ? 'انقر لتحديد الفيديو من المعرض'
      : 'Tap to select video from gallery';
  static String get supportedVideoFormats =>
      isArabic ? 'MP4 · MOV · AVI' : 'MP4 · MOV · AVI';
  static String get tipsForBestResults =>
      isArabic ? 'نصائح للحصول على أفضل النتائج' : 'Tips for Best Results';
  static String get placePhoneAtWaistHeight =>
      isArabic ? 'ضع الهاتف على مستوى الخصر' : 'Place phone at waist height';
  static String get walkNaturally => isArabic
      ? 'امشِ بشكل طبيعي — لا تغير طريقة المشي العادية'
      : 'Walk naturally — don\'t change your normal gait';
  static String get ensureGoodLighting => isArabic
      ? 'تأكد من الإضاءة الجيدة، و évite الإضاءة الخلفية القوية'
      : 'Ensure good lighting, avoid strong backlight';
  static String get stay23MetersFromCamera => isArabic
      ? 'ابقِ على بعد 2–3 أمتار من الكاميرا'
      : 'Stay 2–3 meters away from the camera';
  static String get analysisComplete =>
      isArabic ? 'اكتملت التحليل' : 'Analysis Complete';
  static String get fallRiskScore =>
      isArabic ? 'درجة خطر السقوط' : 'Fall Risk Score';
  static String get strideLength => isArabic ? 'طول الخطوة' : 'Stride Length';
  static String get detectedIssues =>
      isArabic ? 'المشاكل المكتشفة' : 'Detected Issues';
  static String get gaitPatternWithinNormalParameters => isArabic
      ? 'نمط المشي ضمن المعلمات الطبيعية'
      : 'Gait pattern is within normal parameters.';
  static String get continueRegularPhysicalActivity => isArabic
      ? 'استمر في النشاط البدني المنتظم لحفظ الحركة'
      : 'Continue regular physical activity to maintain mobility.';
  static String get considerPeriodicReassessment => isArabic
      ? 'فكر في إعادة التقييم بشكل دوري كل 3–6 أشهر'
      : 'Consider periodic reassessment every 3–6 months.';
  static String get moderateGaitIrregularitiesDetected => isArabic
      ? 'تم اكتشاف عيوب في نمط المشي المتوسطة'
      : 'Moderate gait irregularities detected.';
  static String get considerConsultingPhysiotherapist => isArabic
      ? 'فكر في الاستشارة مع علاج طبيعي'
      : 'Consider consulting a physiotherapist.';
  static String get focusOnBalanceAndStrengthExercises => isArabic
      ? 'ركّز على تمارين التوازن والقوة'
      : 'Focus on balance and strength exercises.';
  static String get useAssistiveDevicesIfExperiencingInstability => isArabic
      ? 'استخدم أجهزة المساعدة إذا كنت تواجه عدم الاستقرار'
      : 'Use assistive devices if experiencing instability.';
  static String get highFallRiskDetected => isArabic
      ? 'تم اكتشاف خطر سقوط عالي'
      : 'High fall risk detected. Please seek medical advice.';
  static String get avoidWalkingOnUnevenSurfaces => isArabic
      ? 'تجنب المشي على الأسطح غير المنتظمة دون دعم'
      : 'Avoid walking on uneven surfaces without support.';
  static String get consultNeurologistOrMovementDisorderSpecialist => isArabic
      ? 'استشر طبيب أعصاب أو متخصص في اضطرابات الحركة'
      : 'Consult a neurologist or movement disorder specialist.';
  static String get considerUsingWalkingAid => isArabic
      ? 'فكر في استخدام مساعد على المشي فوراً'
      : 'Consider using a walking aid immediately.';
  static String get recommendations =>
      isArabic ? 'التوصيات' : 'Recommendations';
  static String get analysisFailed =>
      isArabic ? 'فشل التحليل' : 'Analysis Failed';
  static String get classification => isArabic ? 'التصنيف' : 'Classification';
  static String get classificationResult => isArabic ? 'نتيجة التصنيف' : 'Classification Result';
  static String get unknown => isArabic ? 'غير معروف' : 'Unknown';
  static String get symmetryScore =>
      isArabic ? 'درجة التماثل' : 'Symmetry Score';
  static String get confidence => isArabic ? 'درجة الثقة' : 'Confidence';
  static String get neww => isArabic ? 'جديد' : 'New';
  static String get Ensure_good_lighting => isArabic ? 'تأكد من الإضاءة الجيدة' : 'Ensure Good Lighting';
  static String get Stay_2_3_meters_from_camera => isArabic ? 'ابقِ على بعد 2–3 أمتار من الكاميرا' : 'Stay 2–3 Meters from Camera';
  static String get Recording_Tips => isArabic ? 'نصائح التسجيل' : 'Recording Tips';
  static String get Walk_naturally_and_steadily => isArabic ? 'مشي بشكل طبيعي وببطء' : 'Walk naturally and steadily';
  static String get Place_phone_at_waist_height => isArabic ? 'ضع الهاتف على مستوى الحزام' : 'Place phone at waist height';
  static String get LSTM_Autoencoder => isArabic ? 'LSTM Autoencoder' : 'LSTM Autoencoder';
  static String get Upload_Video_for_Analysis => isArabic ? 'رفع فيديو للتحليل' : 'Upload Video for Analysis';
  static String get Tap_to_select_MP4_MOV_AVI => isArabic ? 'اضغط لتحديد ملف MP4 أو MOV أو AVI' : 'Tap to select MP4, MOV, or AVI file';
  static String get Upload_Gait_Video => isArabic ? 'رفع فيديو المشي' : 'Upload Gait Video';
  static String get Reconstruction_Error_Joint_Mapping => isArabic ? 'خطأ في إعادة بناء 매핑 المفاصل' : 'Reconstruction Error: Joint Mapping';
  static String get Sending_to_Neural_Engine => isArabic ? 'إرسال إلى محرك العصبي' : 'Sending to Neural Engine';
  static String get Detecting_Stride_Cadence_Angles => isArabic ? 'كشف خطوات وسرعة المشي' : 'Detecting Stride Cadence Angles';
  static String get LSTM_Localizing_Anomalies => isArabic ? 'تحديد الشذوذات باستخدام LSTM' : 'LSTM Localizing Anomalies';
  static String get Sending_to_Classifier_Engine => isArabic ? 'إرسال إلى محرك التصنيف' : 'Sending to Classifier Engine';
  static String get AI_Classifying_Gait => isArabic ? 'الذكاء الاصطناعي في تصنيف المشي' : 'AI Classifying Gait';
  static String get Gait_Classifier => isArabic ? 'مُصنِّف المشي' : 'Gait Classifier';
  static String get Uploading_Video => isArabic ? 'جاري الرفع' : 'Uploading Video';
  static String get AnomalyLocalizationMap => isArabic ? 'خريطة تحديد مواقع الشذوذ' : 'Anomaly Localization Map';
  static String get PeakAnomalyFrame => isArabic ? 'أعلى إطار شذوذ' : 'Peak Anomaly Frame';
  static String get PrimaryDeviantJoint => isArabic ? 'أعلى مفصل شذوذ' : 'Primary Deviant Joint';
  static String get HighestVarianceDimension => isArabic ? 'أعلى بعد تشويه' : 'Highest Variance Dimension';
  static String get FrameTimeline => isArabic ? 'جدول زمني للإطار' : 'Frame Timeline';
  static String get Top_5_Anomalous_Joints => isArabic ? 'أعلى 5 مفاصل شذوذ' : 'Top 5 Anomalous Joints';
  static String get localizationResults => isArabic ? 'نتائج التحديد' : 'Localization Results';
  static String get Processing_30_120_sec => isArabic ? 'جاري المعالجة\n~30–120 ثانية' : 'Processing\n~30–120 sec';
  static String get _48_Joint_Dimensions => isArabic ? '48 بعداً للمفاصل' : '48 Joint Dimensions';
  static String get Frame_level_Localization => isArabic ? 'تحديد موقع الإطار' : 'Frame-level Localization';
  static String get Gait_Classifier_Subtitle => isArabic ? 'الكشف الطبيعي / غير الطبيعي' : 'Normal / Abnormal Detection';
  static String get Gait_Localization_Analysis => isArabic ? 'تحليل تحديد موقع المشي' : 'Gait Localization Analysis';
  static String get Gait_Localization_Analysis_Subtitle => isArabic ? 'تحديد موقع الانحراف على مستوى المفاصل' : 'Joint-level Deviation Localization';
  static String get Gait_Localization_Analysis_Description => isArabic ? 'تحديد موقع الانحراف على مستوى المفاصل' : 'Pinpoints exactly which joints deviate from normal gait — shoulder symmetry, ankle strike, knee flexion & more.';


}

class MainShell extends StatefulWidget {
  const MainShell({super.key});
  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> with TickerProviderStateMixin {
  final name = FirebaseAuth.instance.currentUser!.displayName ?? 'User';
  final user = FirebaseAuth.instance.currentUser;
  int _tab = 0;
  late AnimationController _navAnim;
  late AnimationController _bgAnim;
  late Animation<double> _bg;

  @override
  void initState() {
    super.initState();

    _navAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _bgAnim = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 22),
    )..repeat();
    _bg = Tween<double>(
      begin: 0,
      end: 2 * math.pi,
    ).animate(CurvedAnimation(parent: _bgAnim, curve: Curves.linear));
    _navAnim.forward();
  }

  @override
  void dispose() {
    _navAnim.dispose();
    _bgAnim.dispose();
    super.dispose();
  }

  void _switchTab(int i) {
    if (_tab == i) return;
    HapticFeedback.lightImpact();
    setState(() => _tab = i);
  }

  void _rebuild() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isRtl = AppStrings.isArabic;

    return Directionality(
      textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        extendBody: true,
        body: Stack(
          children: [
            AnimatedBuilder(
              animation: _bg,
              builder: (_, __) => CustomPaint(
                size: size,
                painter: _GlobalBgPainter(
                  angle: _bg.value,
                  bgColor: Theme.of(context).scaffoldBackgroundColor,
                ),
              ),
            ),
            // Page content
            IndexedStack(
              index: _tab,
              children: [
                HomePage(onTabSwitch: _switchTab),
                AnalyzePage(),
                FallRiskScreen(),
                FogDetectorPage(),
                ProfilePage(onLanguageChange: _rebuild),
              ],
            ),
          ],
        ),
        bottomNavigationBar: _FloatingNavBar(current: _tab, onTap: _switchTab),
      ),
    );
  }
}

class _GlobalBgPainter extends CustomPainter {
  final double angle;
  final Color bgColor;
  _GlobalBgPainter({required this.angle, this.bgColor = kBg});

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = bgColor,
    );

    void blob(Offset c, double r, Color col, double op) {
      canvas.drawCircle(
        c,
        r,
        Paint()
          ..shader = RadialGradient(
            colors: [col.withOpacity(op), Colors.transparent],
          ).createShader(Rect.fromCircle(center: c, radius: r)),
      );
    }

    blob(
      Offset(
        size.width * 0.9 + math.cos(angle * 0.2) * 30,
        size.height * 0.1 + math.sin(angle * 0.2) * 20,
      ),
      size.width * 0.65,
      kPrimary,
      0.10,
    );
    blob(
      Offset(
        size.width * 0.05 + math.sin(angle * 0.15) * 25,
        size.height * 0.75 + math.cos(angle * 0.15) * 25,
      ),
      size.width * 0.5,
      kAccent,
      0.07,
    );
    blob(
      Offset(
        size.width * 0.5 + math.cos(angle * 0.1) * 40,
        size.height * 0.45 + math.sin(angle * 0.1) * 30,
      ),
      size.width * 0.4,
      kPrimary,
      0.05,
    );

    // dot grid
    final dp = Paint()
      ..color = const Color(0xFF1A6FD4).withOpacity(0.08)
      ..style = PaintingStyle.fill;
    for (double x = 28; x < size.width; x += 28) {
      for (double y = 28; y < size.height; y += 28) {
        canvas.drawCircle(Offset(x, y), 1.1, dp);
      }
    }
  }

  @override
  bool shouldRepaint(_GlobalBgPainter o) => o.angle != angle;
}

class _FloatingNavBar extends StatefulWidget {
  final int current;
  final void Function(int) onTap;

  const _FloatingNavBar({required this.current, required this.onTap});

  @override
  State<_FloatingNavBar> createState() => _FloatingNavBarState();
}

class _FloatingNavBarState extends State<_FloatingNavBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildItem(int index, List items) {
    final active = widget.current == index;
    final item = items[index];

    return GestureDetector(
      onTap: () => widget.onTap(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
        padding: EdgeInsets.symmetric(
          horizontal: active ? 18 : 12,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          color: active ? kPrimary : Colors.transparent,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(item.$1, color: active ? Colors.white : Colors.grey, size: 24),
            AnimatedSize(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOut,
              child: active
                  ? Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: Text(
                        item.$2,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    )
                  : const SizedBox(),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final items = [
      (Icons.home, AppStrings.home),
      (Icons.videocam, AppStrings.analyze),
      (Icons.directions_walk_sharp, AppStrings.fallRisk),
      (Icons.monitor_heart, AppStrings.fogDetector),
      (Icons.person, AppStrings.profile),
    ];
    return SlideTransition(
      position: Tween(
        begin: const Offset(0, 1),
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut)),
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        padding: const EdgeInsets.symmetric(horizontal: 8),
        height: 64,
        decoration: BoxDecoration(
          color: context.card,
          borderRadius: BorderRadius.circular(40),
          boxShadow: [
            BoxShadow(
              blurRadius: 20,
              color: Colors.black.withOpacity(0.08),
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(items.length, (i) => _buildItem(i, items)),
        ),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  final void Function(int) onTabSwitch;
  HomePage({super.key, required this.onTabSwitch});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  final name = FirebaseAuth.instance.currentUser!.displayName ?? 'User';
  final user = FirebaseAuth.instance.currentUser!;
  late AnimationController _entry;
  late List<Animation<Offset>> _slides;
  late List<Animation<double>> _fades;

  @override
  void initState() {
    super.initState();
    _entry = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _slides = List.generate(
      6,
      (i) =>
          Tween<Offset>(begin: const Offset(0, 0.4), end: Offset.zero).animate(
            CurvedAnimation(
              parent: _entry,
              curve: Interval(
                i * 0.1,
                0.55 + i * 0.08,
                curve: Curves.easeOutCubic,
              ),
            ),
          ),
    );
    _fades = List.generate(
      6,
      (i) => Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(
          parent: _entry,
          curve: Interval(i * 0.1, 0.55 + i * 0.08, curve: Curves.easeIn),
        ),
      ),
    );
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) _entry.forward();
    });
  }

  @override
  void dispose() {
    _entry.dispose();
    super.dispose();
  }

  Widget _stagger(int i, Widget child) => AnimatedBuilder(
    animation: _entry,
    builder: (_, __) => SlideTransition(
      position: _slides[i],
      child: FadeTransition(opacity: _fades[i], child: child),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ──
            _stagger(0, _buildHeader()),
            const SizedBox(height: 24),

            // ── Hero CTA card ──
            _stagger(1, _buildHeroCta()),
            const SizedBox(height: 20),

            // ── Weekly trend chart ──
            _stagger(4, _buildWeeklyTrend(context)),
            const SizedBox(height: 20),

            // ── Fall Risk Big Card ──
            _stagger(5, _buildFallRiskCard()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${AppStrings.goodMorning},',
              style: TextStyle(
                fontSize: 14,
                color: context.txtSub.withOpacity(0.42),
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 2),
            ShaderMask(
              shaderCallback: (r) => const LinearGradient(
                colors: [Colors.white, kAccent],
              ).createShader(r),
              child: Text(
                user.displayName ?? 'User',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: context.txt,
                  letterSpacing: -0.8,
                ),
              ),
            ),
          ],
        ),
        const Spacer(),
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(colors: [kPrimary, kAccent]),
            boxShadow: [
              BoxShadow(
                color: kPrimary.withOpacity(0.4),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(
            Icons.person_rounded,
            color: const Color(0xFF0D1B3E),
            size: 24,
          ),
        ),
      ],
    );
  }

  // ── Hero CTA ──────────────────────────────────
  Widget _buildHeroCta() {
    return GestureDetector(
      onTap: () => widget.onTabSwitch(1),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Color.fromARGB(255, 25, 105, 226),
              Color(0xFF1A6FD4),
              Color(0xFF0EA5D0),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: kPrimary.withOpacity(0.4),
              blurRadius: 30,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Decorative circles
            Positioned(
              right: -20,
              top: -20,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF1A6FD4).withOpacity(0.06),
                ),
              ),
            ),
            Positioned(
              right: 30,
              bottom: -30,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF1A6FD4).withOpacity(0.04),
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A6FD4).withOpacity(0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.fiber_manual_record,
                            color: kAccent,
                            size: 8,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            AppStrings.aiready,
                            style: TextStyle(
                              fontSize: 11,
                              color: const Color(0xFF0D1B3E).withOpacity(0.85),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  AppStrings.readyText,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF0D1B3E),
                    height: 1.3,
                    letterSpacing: -0.4,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    _PillBtn(
                      icon: Icons.nordic_walking_rounded,
                      label: AppStrings.fogAnalysis,
                      onTap: () => widget.onTabSwitch(3),
                    ),
                    const SizedBox(width: 10),
                    _PillBtn(
                      icon: Icons.upload_rounded,
                      label: AppStrings.uploadVideo,
                      onTap: () => widget.onTabSwitch(1),
                      secondary: true,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFallRiskCard() {
    return Consumer<FallRiskProvider>(
      builder: (context, fallRisk, _) {
        final score = fallRisk.risk ?? 0.00;
        final label = fallRisk.riskLabel;
        final color = fallRisk.riskColor;

        return Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: context.card,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: context.border, width: 1.2),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.06), // اللون بيتغير حسب الـ risk
                blurRadius: 20,
                spreadRadius: -2,
              ),
            ],
          ),
          child: Row(
            children: [
              _FallRiskCircle(score: score, label: label, color: color),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.fallRisk,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: context.txt,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      fallRisk.hasResult
                          ? '${(score * 100).toInt()}% — $label'
                          : AppStrings.noassessmentyet,
                      style: TextStyle(
                        fontSize: 13,
                        color: color,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      fallRisk.hasResult
                          ? (score < 0.3
                                ? AppStrings.yourGaitIsExcellentThisWeek
                                : score < 0.7
                                ? AppStrings.implementFallPreventionProtocol
                                : AppStrings.highRiskInterventionsRequired)
                          : AppStrings.completeAssessmentToSeeResults,
                      style: TextStyle(
                        fontSize: 12,
                        color: context.txtSub.withOpacity(0.38),
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

Widget _buildWeeklyTrend(BuildContext context) {
  final data = [3.8, 4.1, 3.9, 4.4, 4.2, 4.6, 4.2];
  final days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

  return Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: context.card,
      borderRadius: BorderRadius.circular(24),
      border: Border.all(color: context.border, width: 1.2),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(
          label: AppStrings.weeklyTrend,
          sub: AppStrings.gaitSpeed,
        ),
        const SizedBox(height: 20),
        SizedBox(
          height: 90,
          child: CustomPaint(
            size: const Size(double.infinity, 90),
            painter: _LinechartPainter(data: data, days: days),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(
            days.length,
            (i) => Text(
              days[i],
              style: TextStyle(
                fontSize: 10,
                color: context.txtDim.withOpacity(0.32),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

const kClassifierUrl  = 'http://172.20.10.3:5000';   // Model 1: Normal/Abnormal
const kLocalizerUrl   = 'http://172.20.10.3:5001';   // Model 2: LSTM Autoencoder Localization
 
// ═══════════════════════════════════════════════════
//  COLORS
// ═══════════════════════════════════════════════════
const kDark    = Color(0xFF0D1B3E);
 
// ═══════════════════════════════════════════════════
//  ANALYZE PAGE
// ═══════════════════════════════════════════════════
enum _Phase { idle, uploading, analyzing, results, error }
enum _LocalPhase { idle, uploading, analyzing, results, error }
 
class AnalyzePage extends StatefulWidget {
  const AnalyzePage({super.key});
  @override
  State<AnalyzePage> createState() => _AnalyzePageState();
}
 
class _AnalyzePageState extends State<AnalyzePage>
    with TickerProviderStateMixin {
 
  // ── Model 1: Classifier ──────────────────────────
  _Phase _phase = _Phase.idle;
  Map<String, dynamic>? _classResult;
  String _classError = '';
 
  // ── Model 2: Localizer ───────────────────────────
  _LocalPhase _localPhase = _LocalPhase.idle;
  Map<String, dynamic>? _localResult;
  String _localError = '';
 
  late AnimationController _scanCtrl;
  late AnimationController _pulseCtrl;
  late AnimationController _resultCtrl;
  late AnimationController _orbitCtrl;
  late AnimationController _localCtrl;
 
  @override
  void initState() {
    super.initState();
    _scanCtrl  = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat();
    _pulseCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1600))..repeat(reverse: true);
    _resultCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200));
    _orbitCtrl  = AnimationController(vsync: this, duration: const Duration(seconds: 4))..repeat();
    _localCtrl  = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000));
  }
 
  @override
  void dispose() {
    _scanCtrl.dispose(); _pulseCtrl.dispose(); _resultCtrl.dispose();
    _orbitCtrl.dispose(); _localCtrl.dispose();
    super.dispose();
  }
 
  Future<void> _pickAndUpload() async {
    HapticFeedback.mediumImpact();
    final result = await FilePicker.platform.pickFiles(type: FileType.video, allowMultiple: false);
    if (result == null || result.files.single.path == null) return;
    final filePath = result.files.single.path!;
 
    setState(() => _phase = _Phase.uploading);
    await Future.delayed(const Duration(milliseconds: 300));
    setState(() => _phase = _Phase.analyzing);
 
    try {
      final uri = Uri.parse('$kClassifierUrl/analyze_gait');
      final req = http.MultipartRequest('POST', uri)
        ..files.add(await http.MultipartFile.fromPath('video', filePath));
      final streamed = await req.send().timeout(const Duration(seconds: 400));
      final body = await streamed.stream.bytesToString();
 
      if (streamed.statusCode == 200) {
        final data = json.decode(body) as Map<String, dynamic>;
        setState(() { _classResult = data; _phase = _Phase.results; });
        _resultCtrl.forward(from: 0);
        HapticFeedback.heavyImpact();
      } else {
        final err = json.decode(body);
        setState(() { _classError = err['error'] ?? 'Server error ${streamed.statusCode}'; _phase = _Phase.error; });
      }
    } catch (e) {
      setState(() { _classError = e.toString(); _phase = _Phase.error; });
    }
  }
 
  Future<void> _pickAndLocalize() async {
    HapticFeedback.mediumImpact();
    final result = await FilePicker.platform.pickFiles(type: FileType.video, allowMultiple: false);
    if (result == null || result.files.single.path == null) return;
    final filePath = result.files.single.path!;
 
    setState(() => _localPhase = _LocalPhase.uploading);
    await Future.delayed(const Duration(milliseconds: 300));
    setState(() => _localPhase = _LocalPhase.analyzing);
 
    try {
      final uri = Uri.parse('$kLocalizerUrl/localize_gait');
      final req = http.MultipartRequest('POST', uri)
        ..files.add(await http.MultipartFile.fromPath('video', filePath));
      final streamed = await req.send().timeout(const Duration(seconds: 400));
      final body = await streamed.stream.bytesToString();
 
      if (streamed.statusCode == 200) {
        final data = json.decode(body) as Map<String, dynamic>;
        setState(() { _localResult = data; _localPhase = _LocalPhase.results; });
        _localCtrl.forward(from: 0);
        HapticFeedback.heavyImpact();
      } else {
        final err = json.decode(body);
        setState(() { _localError = err['error'] ?? 'Server error ${streamed.statusCode}'; _localPhase = _LocalPhase.error; });
      }
    } catch (e) {
      setState(() { _localError = e.toString(); _localPhase = _LocalPhase.error; });
    }
  }
 
  void _resetClassifier() {
    HapticFeedback.lightImpact();
    _resultCtrl.reset();
    setState(() { _phase = _Phase.idle; _classResult = null; _classError = ''; });
  }
 
  void _resetLocalizer() {
    HapticFeedback.lightImpact();
    _localCtrl.reset();
    setState(() { _localPhase = _LocalPhase.idle; _localResult = null; _localError = ''; });
  }
 
  // ── Build ─────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.PBg,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(22, 16, 22, 110),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
 
              // ══════════════════════════════════════
              //  MODEL 1 — Classifier Section
              // ══════════════════════════════════════
              _ModelSectionHeader(
                index: '01',
                title: AppStrings.Gait_Classifier,
                subtitle: AppStrings.Gait_Classifier_Subtitle,
                gradientColors: const [kPrimary, kAccent],
                icon: Icons.account_tree_rounded,
              ),
              const SizedBox(height: 16),
 
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 450),
                transitionBuilder: (child, anim) => FadeTransition(
                  opacity: CurvedAnimation(parent: anim, curve: Curves.easeOut),
                  child: SlideTransition(
                    position: Tween<Offset>(begin: const Offset(0, 0.05), end: Offset.zero)
                        .animate(CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)),
                    child: child,
                  ),
                ),
                child: _buildClassifierPhase(),
              ),
 
              const SizedBox(height: 32),
 
              _SectionDivider(),
 
              const SizedBox(height: 32),
 
              _ModelSectionHeader(
                index: '02',
                title: AppStrings.Gait_Localization_Analysis,
                subtitle: AppStrings.Gait_Localization_Analysis_Subtitle,
                gradientColors: const [kPrimary, kAccent],
                icon: Icons.my_location_rounded,
              ),
              const SizedBox(height: 6),
 
              // Subtitle note
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: kPrimary.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: kPrimary.withOpacity(0.15)),
                ),
                child: Row(children: [
                  Icon(Icons.info_outline_rounded, color: kPrimary, size: 14),
                  const SizedBox(width: 8),
                  Expanded(child: Text(
                    AppStrings.Gait_Localization_Analysis_Description,
                    style: TextStyle(fontSize: 11, color: context.txt.withOpacity(0.55), height: 1.4),
                  )),
                ]),
              ),
 
              const SizedBox(height: 16),
 
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 450),
                transitionBuilder: (child, anim) => FadeTransition(
                  opacity: CurvedAnimation(parent: anim, curve: Curves.easeOut),
                  child: SlideTransition(
                    position: Tween<Offset>(begin: const Offset(0, 0.05), end: Offset.zero)
                        .animate(CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)),
                    child: child,
                  ),
                ),
                child: _buildLocalizerPhase(),
              ),
 
            ],
          ),
        ),
      ),
    );
  }
 
  // ── Classifier phase switcher ─────────────────────
  Widget _buildClassifierPhase() {
    switch (_phase) {
      case _Phase.idle:
        return _ClassifierIdleCard(
          key: const ValueKey('c_idle'),
          scan: _scanCtrl, pulse: _pulseCtrl,
          onUpload: _pickAndUpload,
        );
      case _Phase.uploading:
      case _Phase.analyzing:
        return _LoadingCard(
          key: const ValueKey('c_loading'),
          orbit: _orbitCtrl, scan: _scanCtrl,
          phase: _phase,
          gradientColors: const [kPrimary, kAccent],
          label: _phase == _Phase.uploading ? AppStrings.Uploading_Video : AppStrings.AI_Classifying_Gait,
          sub: _phase == _Phase.uploading ? AppStrings.Sending_to_Classifier_Engine : AppStrings.Detecting_Stride_Cadence_Angles,
        );
      case _Phase.results:
        return _ClassifierResultsCard(
          key: const ValueKey('c_results'),
          data: _classResult!,
          ctrl: _resultCtrl,
          onNew: _resetClassifier,
        );
      case _Phase.error:
        return _ErrorCard(
          key: const ValueKey('c_error'),
          message: _classError,
          onRetry: _resetClassifier,
          color: kRed,
        );
    }
  }
 
  // ── Localizer phase switcher ──────────────────────
  Widget _buildLocalizerPhase() {
    switch (_localPhase) {
      case _LocalPhase.idle:
        return _LocalizerIdleCard(
          key: const ValueKey('l_idle'),
          scan: _scanCtrl, pulse: _pulseCtrl,
          onUpload: _pickAndLocalize,
        );
      case _LocalPhase.uploading:
      case _LocalPhase.analyzing:
        return _LoadingCard(
          key: const ValueKey('l_loading'),
          orbit: _orbitCtrl, scan: _scanCtrl,
          phase: _phase,
          gradientColors: const [kPrimary, kAccent],
          label: _localPhase == _LocalPhase.uploading ? AppStrings.Uploading_Video : AppStrings.LSTM_Localizing_Anomalies,
          sub: _localPhase == _LocalPhase.uploading ? AppStrings.Sending_to_Neural_Engine : AppStrings.Reconstruction_Error_Joint_Mapping,
        );
      case _LocalPhase.results:
        return _LocalizerResultsCard(
          key: const ValueKey('l_results'),
          data: _localResult!,
          ctrl: _localCtrl,
          onNew: _resetLocalizer,
        );
      case _LocalPhase.error:
        return _ErrorCard(
          key: const ValueKey('l_error'),
          message: _localError,
          onRetry: _resetLocalizer,
          color: kPrimary,
        );
    }
  }
}
 
// ═══════════════════════════════════════════════════
//  MODEL SECTION HEADER
// ═══════════════════════════════════════════════════
class _ModelSectionHeader extends StatelessWidget {
  final String index, title, subtitle;
  final List<Color> gradientColors;
  final IconData icon;
  const _ModelSectionHeader({
    required this.index, required this.title, required this.subtitle,
    required this.gradientColors, required this.icon,
  });
 
  @override
  Widget build(BuildContext context) {
    return Row(children: [
      // Index badge
      Container(
        width: 44, height: 44,
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: gradientColors,
              begin: Alignment.topLeft, end: Alignment.bottomRight),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [BoxShadow(color: gradientColors.first.withOpacity(0.35),
              blurRadius: 12, offset: const Offset(0, 4))],
        ),
        child: Center(child: Text(index,
            style:  TextStyle(color: context.txt, fontSize: 13,
                fontWeight: FontWeight.w900, letterSpacing: 0.5))),
      ),
      const SizedBox(width: 14),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style:  TextStyle(fontSize: 17, fontWeight: FontWeight.w800,
            color: context.txt, letterSpacing: -0.4)),
         SizedBox(height: 2),
        Text(subtitle, style: TextStyle(fontSize: 11,
            color: context.txt.withOpacity(0.42), fontWeight: FontWeight.w500)),
      ])),
      // Model tag
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: gradientColors.first.withOpacity(0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: gradientColors.first.withOpacity(0.2)),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, color: gradientColors.first, size: 12),
          const SizedBox(width: 5),
          Text('AI Model', style: TextStyle(fontSize: 10,
              color: gradientColors.first, fontWeight: FontWeight.w700)),
        ]),
      ),
    ]);
  }
}
 
// ═══════════════════════════════════════════════════
//  SECTION DIVIDER
// ═══════════════════════════════════════════════════
class _SectionDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Expanded(child: Container(height: 1,
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [context.border.withOpacity(0), context.border]),
          ))),
      Container(
        margin: const EdgeInsets.symmetric(horizontal: 14),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          color: context.card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: context.border),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 6, height: 6,
              decoration: BoxDecoration(shape: BoxShape.circle,
                  color: kPrimary.withOpacity(0.7))),
          const SizedBox(width: 6),
          Text('Localization Engine', style: TextStyle(
              fontSize: 10, color: context.txt.withOpacity(0.45), fontWeight: FontWeight.w600)),
        ]),
      ),
      Expanded(child: Container(height: 1,
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [context.border, context.border.withOpacity(0)]),
          ))),
    ]);
  }
}
 
// ══════════════════════════════════════════════════
//  CLASSIFIER IDLE CARD
// ═══════════════════════════════════════════════════
class _ClassifierIdleCard extends StatelessWidget {
  final Animation<double> scan, pulse;
  final VoidCallback onUpload;
  const _ClassifierIdleCard({super.key, required this.scan,
    required this.pulse, required this.onUpload});
 
  @override
  Widget build(BuildContext context) {
    return Column(children: [
      // Upload zone
      AnimatedBuilder(
        animation: Listenable.merge([scan, pulse]),
        builder: (_, __) => GestureDetector(
          onTap: onUpload,
          child: Container(
            width: double.infinity, height: 220,
            decoration: BoxDecoration(
              color: context.card,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: context.border, width: 1.5),
              boxShadow: [BoxShadow(color: kPrimary.withOpacity(0.07),
                  blurRadius: 30, spreadRadius: -4)],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(22),
              child: Stack(children: [
                // Scan line
                Positioned(
                  top: scan.value * 220 - 1.5, left: 0, right: 0,
                  child: Container(height: 3, decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [
                      Colors.transparent, kAccent.withOpacity(0.6),
                      kPrimary, kAccent.withOpacity(0.6), Colors.transparent,
                    ]),
                  )),
                ),
                // Grid
                CustomPaint(size: const Size(double.infinity, 220),
                    painter: _GridPainter()),
                // Corners
                ..._corners(kPrimary),
                // Center
                Center(child: Transform.scale(
                  scale: 0.97 + pulse.value * 0.03,
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Container(
                      width: 72, height: 72,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(colors: [
                          kPrimary.withOpacity(0.18), kPrimary.withOpacity(0.04)]),
                        border: Border.all(color: kPrimary.withOpacity(0.3), width: 1.5),
                      ),
                      child: const Icon(Icons.upload_file_rounded, color: kPrimary, size: 32),
                    ),
                    const SizedBox(height: 14),
                     Text(AppStrings.Upload_Gait_Video,
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: context.txt)),
                    const SizedBox(height: 5),
                    Text(AppStrings.Tap_to_select_MP4_MOV_AVI,
                        style: TextStyle(fontSize: 12, color: context.txt.withOpacity(0.38))),
                  ]),
                )),
              ]),
            ),
          ),
        ),
      ),
      const SizedBox(height: 12),
      // Tips
      _TipsCard(color: kPrimary),
    ]);
  }
}
 
// ═══════════════════════════════════════════════════
//  LOCALIZER IDLE CARD  — big button style
// ═══════════════════════════════════════════════════
class _LocalizerIdleCard extends StatelessWidget {
  final Animation<double> scan, pulse;
  final VoidCallback onUpload;
  const _LocalizerIdleCard({super.key, required this.scan,
    required this.pulse, required this.onUpload});
 
  @override
  Widget build(BuildContext context) {
    return Column(children: [
      // ── Big styled upload button ──────────────────
      AnimatedBuilder(
        animation: pulse,
        builder: (_, __) => GestureDetector(
          onTap: onUpload,
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [kAccent, kPrimary],
                begin: Alignment.topLeft, end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(color: kPrimary.withOpacity(0.35 + pulse.value * 0.15),
                    blurRadius: 28, offset: const Offset(0, 10)),
                BoxShadow(color: kAccent.withOpacity(0.15),
                    blurRadius: 40, spreadRadius: -8),
              ],
            ),
            child: Stack(children: [
              // Decorative circles
              Positioned(right: -20, top: -20, child: Container(
                width: 120, height: 120,
                decoration: BoxDecoration(shape: BoxShape.circle,
                    color: context.card.withOpacity(0.2)),
              )),
              Positioned(left: -10, bottom: -30, child: Container(
                width: 100, height: 100,
                decoration: BoxDecoration(shape: BoxShape.circle,
                    color: context.card.withOpacity(0.04)),
              )),
              // Scan line on button
              ClipRRect(
                borderRadius: BorderRadius.circular(28),
                child: AnimatedBuilder(
                  animation: scan,
                  builder: (_, __) => CustomPaint(
                    size: const Size(double.infinity, 180),
                    painter: _ScanLinePainter(scan.value, context.card),
                  ),
                ),
              ),
              // Content
              Padding(
                padding: const EdgeInsets.all(28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Icon + badge row
                    Row(children: [
                      Container(
                        width: 52, height: 52,
                        decoration: BoxDecoration(
                          color: context.card.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: context.card.withOpacity(0.25)),
                        ),
                        child: const Icon(Icons.my_location_rounded,
                            color: Colors.white, size: 26),
                      ),
                      const SizedBox(width: 14),
                      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                         Text(AppStrings.Gait_Localization_Analysis,
                            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800,
                                color: context.txt, letterSpacing: -0.4)),
                        const SizedBox(height: 3),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: context.card.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child:  Text(AppStrings.LSTM_Autoencoder,
                              style: TextStyle(color: context.txt, fontSize: 10,
                                  fontWeight: FontWeight.w700, letterSpacing: 0.3)),
                        ),
                      ]),
                    ]),
 
                    const SizedBox(height: 20),
 
                    // Description
                    Text(
                      AppStrings.Gait_Localization_Analysis_Description,
                      style: TextStyle(fontSize: 13,
                          color: Colors.white.withOpacity(0.75), height: 1.5),
                    ),
 
                    const SizedBox(height: 20),
 
                    // What it detects chips
                    Wrap(spacing: 8, runSpacing: 8, children: [
                      'Shoulder Symmetry', 'Knee Angle', 'Ankle Strike',
                      'Hip Coupling', 'Trunk Sway',
                    ].map((t) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white.withOpacity(0.2)),
                      ),
                      child: Text(t, style: const TextStyle(
                          color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
                    )).toList()),
 
                    const SizedBox(height: 24),
 
                    // CTA row
                    Row(children: [
                      Expanded(child: Container(
                        height: 50,
                        decoration: BoxDecoration(
                          color: context.card.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15),
                              blurRadius: 12, offset: const Offset(0, 4))],
                        ),
                        child:  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                          Icon(Icons.upload_file_rounded, color: context.txt, size: 20),
                          SizedBox(width: 10),
                          Text(AppStrings.Upload_Video_for_Analysis,
                              style: TextStyle(color: context.txt, fontSize: 14,
                                  fontWeight: FontWeight.w800)),
                        ]),
                      )),
                    ]),
                  ],
                ),
              ),
            ]),
          ),
        ),
      ),
 
      const SizedBox(height: 12),
 
      // Info chips row
      Row(children: [
        Expanded(child: _InfoChip(Icons.timer_outlined, AppStrings.Processing_30_120_sec, kPrimary)),
        const SizedBox(width: 10),
        Expanded(child: _InfoChip(Icons.hub_rounded, AppStrings._48_Joint_Dimensions, Color(0xFFDB2777))),
        const SizedBox(width: 10),
        Expanded(child: _InfoChip(Icons.analytics_rounded, AppStrings.Frame_level_Localization, kPrimary)),
      ]),
    ]);
  }
}
 
// ═══════════════════════════════════════════════════
//  LOADING CARD (shared)
// ═══════════════════════════════════════════════════
class _LoadingCard extends StatelessWidget {
  final Animation<double> orbit, scan;
  final _Phase phase;
  final List<Color> gradientColors;
  final String label, sub;
  const _LoadingCard({super.key, required this.orbit, required this.scan,
    required this.phase, required this.gradientColors,
    required this.label, required this.sub});
 
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
      decoration: BoxDecoration(
        color: context.card, borderRadius: BorderRadius.circular(28),
        border: Border.all(color: context.border),
        boxShadow: [BoxShadow(color: gradientColors.first.withOpacity(0.08),
            blurRadius: 24)],
      ),
      child: Column(children: [
        // Orbit animation
        AnimatedBuilder(
          animation: Listenable.merge([orbit, scan]),
          builder: (_, __) => SizedBox(
            width: 160, height: 160,
            child: CustomPaint(painter: _OrbitPainter(
                orbit.value, scan.value, gradientColors, context.border)),
          ),
        ),
        const SizedBox(height: 28),
        Text(label, style:  TextStyle(fontSize: 18, fontWeight: FontWeight.w800,
            color: context.txt, letterSpacing: -0.4)),
        const SizedBox(height: 6),
        Text(sub, style: TextStyle(fontSize: 12, color: context.txt.withOpacity(0.42))),
        const SizedBox(height: 24),
        // Pulsing dots
        AnimatedBuilder(
          animation: scan,
          builder: (_, __) => Row(mainAxisSize: MainAxisSize.min,
              children: List.generate(3, (i) {
                final p = (scan.value + i * 0.33) % 1.0;
                final op = math.sin(p * math.pi).clamp(0.2, 1.0);
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: 8, height: 8,
                  decoration: BoxDecoration(shape: BoxShape.circle,
                      color: gradientColors.first.withOpacity(op)),
                );
              })),
        ),
      ]),
    );
  }
}
 
// ═══════════════════════════════════════════════════
//  CLASSIFIER RESULTS CARD
// ═══════════════════════════════════════════════════
class _ClassifierResultsCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final AnimationController ctrl;
  final VoidCallback onNew;
  const _ClassifierResultsCard({super.key, required this.data,
    required this.ctrl, required this.onNew});
 
  double _d(String k, [double def = 0.0]) => (data[k] as num?)?.toDouble() ?? def;
  String _s(String k, [String def = '—']) => data[k]?.toString() ?? def;
 
  @override
  Widget build(BuildContext context) {
    final classification = _s('classification');
    final riskScore = _d('risk_score');
    final confidence = _d('confidence');
    final isNormal = classification == 'Normal';
    final riskColor = riskScore < 0.3 ? kGreen : riskScore < 0.6 ? kOrange : kRed;
 
    final metrics = [
      _MetricData(AppStrings.strideLength, '${_d('stride_length_m').toStringAsFixed(2)} m',
          kGreen, Icons.straighten_rounded, (_d('stride_length_m') / 1.6).clamp(0,1)),
      _MetricData(AppStrings.cadence, '${_d('cadence_spm').toStringAsFixed(0)} spm',
          kAccent, Icons.directions_walk_rounded, (_d('cadence_spm') / 140).clamp(0,1)),
      _MetricData(AppStrings.gaitSpeed, '${_d('gait_speed_kmh').toStringAsFixed(1)} km/h',
          kPrimary, Icons.speed_rounded, (_d('gait_speed_kmh') / 6).clamp(0,1)),
      _MetricData(AppStrings.kneeAngle, '${_d('avg_knee_angle').toStringAsFixed(1)}°',
          kGreen, Icons.accessibility_new_rounded, (_d('avg_knee_angle') / 180).clamp(0,1)),
      _MetricData(AppStrings.hipAngle, '${_d('avg_hip_angle').toStringAsFixed(1)}°',
          kOrange, Icons.accessibility_rounded, (_d('avg_hip_angle') / 180).clamp(0,1)),
      _MetricData(AppStrings.symmetry, '${(_d('symmetry_score') * 100).toStringAsFixed(0)}%',
          kGreen, Icons.balance_rounded, _d('symmetry_score').clamp(0,1)),
    ];
 
    return Column(children: [
      // Header
      Row(children: [
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
           Text(AppStrings.classificationResult, style: TextStyle(
              fontSize: 18, fontWeight: FontWeight.w800, color: context.txt, letterSpacing: -0.4)),
          Text('${_s('frames_analyzed')} frames · ${(confidence * 100).toStringAsFixed(0)}% confidence',
              style: TextStyle(fontSize: 12, color: context.txt.withOpacity(0.38))),
        ])),
        _NewBtn(onTap: onNew, gradient: const [kPrimary, kAccent]),
      ]),
      const SizedBox(height: 14),
 
      // Hero
      _animEntry(ctrl, 0.0, 0.4, _HeroCard(
        classification: classification, riskScore: riskScore,
        riskColor: riskColor, isNormal: isNormal,
      )),
      const SizedBox(height: 12),
 
      // Metrics grid
      GridView.builder(
        shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, crossAxisSpacing: 10, mainAxisSpacing: 10, childAspectRatio: 1.22),
        itemCount: metrics.length,
        itemBuilder: (_, i) => _animEntry(ctrl, 0.08 + i * 0.07, 0.5,
            _MetricCard(metric: metrics[i])),
      ),
 
      // Issues
      if ((data['issues'] as List?)?.isNotEmpty == true) ...[
        const SizedBox(height: 10),
        _animEntry(ctrl, 0.55, 0.45,
            _IssuesCard(issues: (data['issues'] as List).cast<String>())),
      ],
 
      const SizedBox(height: 10),
      _animEntry(ctrl, 0.65, 0.35,
          _RecommendCard(isNormal: isNormal, riskScore: riskScore, color: kPrimary)),
    ]);
  }
 
  Widget _animEntry(AnimationController c, double delay, double range, Widget child) =>
      AnimatedBuilder(animation: c, builder: (_, __) {
        final t = Curves.easeOutCubic.transform(((c.value - delay) / range).clamp(0.0, 1.0));
        return Transform.translate(offset: Offset(0, 24 * (1 - t)),
            child: Opacity(opacity: t, child: child));
      });
}
 
// ═══════════════════════════════════════════════════
//  LOCALIZER RESULTS CARD
// ═══════════════════════════════════════════════════
class _LocalizerResultsCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final AnimationController ctrl;
  final VoidCallback onNew;
  const _LocalizerResultsCard({super.key, required this.data,
    required this.ctrl, required this.onNew});
 
  // ignore: unused_element
  double _d(String k, [double def = 0.0]) => (data[k] as num?)?.toDouble() ?? def;
  String _s(String k, [String def = '—']) => data[k]?.toString() ?? def;
  int    _i(String k, [int def = 0])      => (data[k] as num?)?.toInt() ?? def;
 
  @override
  Widget build(BuildContext context) {
    // Parse joint scores from API
    // Expected: { "top_joints": [{"name":"shoulder_symmetry","score":0.26,"contribution":9.0,"clinical":"..."}] }
    final topJoints = (data['top_joints'] as List?)?.cast<Map<String, dynamic>>() ?? _demoJoints;
    final peakFrame = _i('peak_frame', 36);
    final primaryJoint = _s('primary_joint', 'shoulder_symmetry');
    final highestVar = _s('highest_variance_col', 'symmetry_shoulder_x');
    final framesAnalyzed = _i('frames_analyzed', 48);
 
    return Column(children: [
      // Header
      Row(children: [
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
           Text(AppStrings.localizationResults, style: TextStyle(
              fontSize: 18, fontWeight: FontWeight.w800, color: context.txt, letterSpacing: -0.4)),
          Text('LSTM Autoencoder · $framesAnalyzed frames analyzed',
              style: TextStyle(fontSize: 12, color: context.txt.withOpacity(0.38))),
        ])),
        _NewBtn(onTap: onNew, gradient: const [kPrimary, kAccent]),
      ]),
      const SizedBox(height: 14),
 
      // ── Temporal mapping card ─────────────────────
      _animEntry(ctrl, 0.0, 0.4, _TemporalCard(
        peakFrame: peakFrame,
        totalFrames: framesAnalyzed,
        primaryJoint: primaryJoint,
        highestVar: highestVar,
      )),
      const SizedBox(height: 12),
 
      // ── Top 5 joints bar chart ─────────────────────
      _animEntry(ctrl, 0.2, 0.5, _JointBarsCard(joints: topJoints, ctrl: ctrl)),
      const SizedBox(height: 12),
 
      // ── Clinical insights ─────────────────────────
      _animEntry(ctrl, 0.55, 0.45, _ClinicalInsightsCard(joints: topJoints)),
    ]);
  }
 
  Widget _animEntry(AnimationController c, double delay, double range, Widget child) =>
      AnimatedBuilder(animation: c, builder: (_, __) {
        final t = Curves.easeOutCubic.transform(((c.value - delay) / range).clamp(0.0, 1.0));
        return Transform.translate(offset: Offset(0, 24 * (1 - t)),
            child: Opacity(opacity: t, child: child));
      });
 
  // Demo data matching the notebook output
  static final List<Map<String, dynamic>> _demoJoints = [
    {'name': 'shoulder_symmetry',         'score': 0.2645, 'contribution': 9.0,
     'clinical': 'Reduced left-right gait symmetry across shoulder girdle.'},
    {'name': 'right_ankle',               'score': 0.2367, 'contribution': 8.1,
     'clinical': 'Atypical strike pattern near right ankle vectors.'},
    {'name': 'left_shoulder',             'score': 0.2258, 'contribution': 7.7,
     'clinical': 'Localized anomaly near left shoulder joint plane.'},
    {'name': 'right_knee',                'score': 0.2150, 'contribution': 7.3,
     'clinical': 'Irregular extension/flexion near right knee indicators.'},
    {'name': 'contralateral_leftSH_rightHP', 'score': 0.2129, 'contribution': 7.3,
     'clinical': 'Abnormal contralateral arm-leg coordination (Left Shoulder / Right Hip).'},
  ];
}
 
// ─────────────────────────────────────────────────────
//  TEMPORAL MAPPING CARD
// ─────────────────────────────────────────────────────
class _TemporalCard extends StatelessWidget {
  final int peakFrame, totalFrames;
  final String primaryJoint, highestVar;
  const _TemporalCard({required this.peakFrame, required this.totalFrames,
    required this.primaryJoint, required this.highestVar});
 
  @override
  Widget build(BuildContext context) {
    final progress = totalFrames > 0 ? peakFrame / totalFrames : 0.0;
 
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [kPrimary.withOpacity(0.08), kAccent.withOpacity(0.04)],
          begin: Alignment.topLeft, end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: kPrimary.withOpacity(0.2), width: 1.5),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [kPrimary, kAccent]),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.location_on_rounded, color: Colors.white, size: 16)),
          const SizedBox(width: 10),
           Text(AppStrings.AnomalyLocalizationMap,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: context.txt)),
        ]),
        const SizedBox(height: 18),
 
        // Three key findings
        _FindingRow('⏳', AppStrings.PeakAnomalyFrame, 'Frame #$peakFrame of $totalFrames'),
        const SizedBox(height: 10),
        _FindingRow('📍', AppStrings.PrimaryDeviantJoint, _formatJointName(primaryJoint)),
        const SizedBox(height: 10),
        _FindingRow('🧬', AppStrings.HighestVarianceDimension, highestVar),
 
        const SizedBox(height: 18),
 
        // Frame timeline bar
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Text(AppStrings.FrameTimeline, style: TextStyle(
                fontSize: 11, color: context.txt.withOpacity(0.45), fontWeight: FontWeight.w600)),
            const Spacer(),
            Text('Peak at frame $peakFrame',
                style: const TextStyle(fontSize: 11, color: kPrimary, fontWeight: FontWeight.w700)),
          ]),
          const SizedBox(height: 6),
          Stack(children: [
            ClipRRect(borderRadius: BorderRadius.circular(6), child:
              LinearProgressIndicator(value: 1.0, minHeight: 10,
                  backgroundColor: context.border, valueColor: const AlwaysStoppedAnimation(kBorder))),
            // Peak marker
            FractionallySizedBox(
              widthFactor: progress.clamp(0.02, 0.98),
              child: Container(height: 10,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [kPrimary, kAccent]),
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ),
          ]),
          const SizedBox(height: 4),
          Row(children: [
            Text('0', style: TextStyle(fontSize: 9, color: context.txt.withOpacity(0.3))),
            const Spacer(),
            Text('$totalFrames', style: TextStyle(fontSize: 9, color: context.txt.withOpacity(0.3))),
          ]),
        ]),
      ]),
    );
  }
 
  String _formatJointName(String s) =>
      s.replaceAll('_', ' ').split(' ').map((w) =>
          w.isEmpty ? '' : '${w[0].toUpperCase()}${w.substring(1)}').join(' ');
}
 
class _FindingRow extends StatelessWidget {
  final String emoji, label, value;
  const _FindingRow(this.emoji, this.label, this.value);
  @override
  Widget build(BuildContext context) => Row(children: [
    Text(emoji, style: const TextStyle(fontSize: 16)),
    const SizedBox(width: 10),
    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: TextStyle(fontSize: 10,
          color: context.txt.withOpacity(0.42), fontWeight: FontWeight.w500)),
      Text(value, style: TextStyle(fontSize: 13,
          color: context.txt, fontWeight: FontWeight.w700)),
    ])),
  ]);
}
 
// ─────────────────────────────────────────────────────
//  JOINT BARS CARD  (Top 5 anomalous joints)
// ─────────────────────────────────────────────────────
class _JointBarsCard extends StatelessWidget {
  final List<Map<String, dynamic>> joints;
  final AnimationController ctrl;
  const _JointBarsCard({required this.joints, required this.ctrl});
 
  static const _barColors = [
    Color(0xFF7B0000), Color(0xFFB22222), Color(0xFFCD5C5C),
    Color(0xFFE8967A), Color(0xFFF5B8A8),
  ];
 
  @override
  Widget build(BuildContext context) {
    final maxScore = joints.isEmpty ? 1.0
        : (joints.first['score'] as num).toDouble();
 
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.card, borderRadius: BorderRadius.circular(22),
        border: Border.all(color: context.border, width: 1.2),
        boxShadow: [BoxShadow(color: kPrimary.withOpacity(0.06), blurRadius: 20)],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: kPrimary.withOpacity(0.10),
                borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.bar_chart_rounded, color: kPrimary, size: 16)),
          const SizedBox(width: 10),
           Expanded(child: Text(AppStrings.Top_5_Anomalous_Joints,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: context.txt))),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: kPrimary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(8)),
            child: const Text('Deviance Score',
                style: TextStyle(fontSize: 9, color: kPrimary, fontWeight: FontWeight.w700)),
          ),
        ]),
        const SizedBox(height: 18),
 
        ...List.generate(math.min(joints.length, 5), (i) {
          final joint = joints[i];
          final name = joint['name'] as String? ?? '';
          final score = (joint['score'] as num?)?.toDouble() ?? 0.0;
          final contrib = (joint['contribution'] as num?)?.toDouble() ?? 0.0;
          final fraction = maxScore > 0 ? score / maxScore : 0.0;
          final clr = _barColors[i % _barColors.length];
          final displayName = name.replaceAll('_', ' ');
 
          return Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                // Rank badge
                Container(
                  width: 20, height: 20,
                  decoration: BoxDecoration(shape: BoxShape.circle,
                      color: clr.withOpacity(0.15),
                      border: Border.all(color: clr.withOpacity(0.4))),
                  child: Center(child: Text('${i+1}',
                      style: TextStyle(fontSize: 10, color: clr, fontWeight: FontWeight.w800))),
                ),
                const SizedBox(width: 8),
                Expanded(child: Text(displayName,
                    style: TextStyle(fontSize: 12, color: context.txt.withOpacity(0.75),
                        fontWeight: FontWeight.w600))),
                Text('${score.toStringAsFixed(4)}',
                    style: TextStyle(fontSize: 11, color: clr, fontWeight: FontWeight.w800)),
                const SizedBox(width: 8),
                Text('${contrib.toStringAsFixed(1)}%',
                    style: TextStyle(fontSize: 10, color: context.txt.withOpacity(0.35))),
              ]),
              const SizedBox(height: 6),
              AnimatedBuilder(
                animation: ctrl,
                builder: (_, __) {
                  final t = Curves.easeOutCubic.transform(
                      ((ctrl.value - 0.2 - i * 0.06) / 0.5).clamp(0.0, 1.0));
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: fraction * t, minHeight: 8,
                      backgroundColor: context.border,
                      valueColor: AlwaysStoppedAnimation(clr),
                    ),
                  );
                },
              ),
            ]),
          );
        }),
      ]),
    );
  }
}
 
// ─────────────────────────────────────────────────────
//  CLINICAL INSIGHTS CARD
// ─────────────────────────────────────────────────────
class _ClinicalInsightsCard extends StatelessWidget {
  final List<Map<String, dynamic>> joints;
  const _ClinicalInsightsCard({required this.joints});
 
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [kPrimary.withOpacity(0.05), context.PBg],
          begin: Alignment.topLeft, end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: kPrimary.withOpacity(0.15), width: 1.3),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [kPrimary, kAccent]),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.medical_information_rounded,
                color: Colors.white, size: 16)),
          const SizedBox(width: 10),
           Text(AppStrings.clinicalInsights,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: context.txt)),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: kPrimary.withOpacity(0.08), borderRadius: BorderRadius.circular(8)),
            child:  Text(AppStrings.aiGenerated,
                style: TextStyle(fontSize: 9, color: kPrimary, fontWeight: FontWeight.w700)),
          ),
        ]),
        const SizedBox(height: 16),
 
        ...List.generate(math.min(joints.length, 5), (i) {
          final joint = joints[i];
          final name = (joint['name'] as String? ?? '').replaceAll('_', ' ');
          final clinical = joint['clinical'] as String? ?? '—';
          return Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(
                width: 24, height: 24, margin: const EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                      colors: [kPrimary, kAccent]),
                ),
                child: Center(child: Text('${i+1}',
                    style: const TextStyle(color: Colors.white, fontSize: 10,
                        fontWeight: FontWeight.w800))),
              ),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(name.split(' ').map((w) =>
                    w.isEmpty ? '' : '${w[0].toUpperCase()}${w.substring(1)}').join(' '),
                    style:  TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: context.txt)),
                const SizedBox(height: 3),
                Text('💡 $clinical',
                    style: TextStyle(fontSize: 12,
                        color: context.txt.withOpacity(0.52), height: 1.45)),
              ])),
            ]),
          );
        }),
      ]),
    );
  }
}
 
// ═══════════════════════════════════════════════════
//  SHARED SMALL WIDGETS
// ═══════════════════════════════════════════════════
 
class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _InfoChip(this.icon, this.label, this.color);
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
    decoration: BoxDecoration(color: context.card, borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.border)),
    child: Column(children: [
      Icon(icon, color: color, size: 18),
      const SizedBox(height: 6),
      Text(label, textAlign: TextAlign.center,
          style: TextStyle(fontSize: 10, color: context.txt.withOpacity(0.55),
              fontWeight: FontWeight.w600, height: 1.3)),
    ]),
  );
}
 
class _NewBtn extends StatelessWidget {
  final VoidCallback onTap;
  final List<Color> gradient;
  const _NewBtn({required this.onTap, required this.gradient});
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: gradient),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: gradient.first.withOpacity(0.4), blurRadius: 12)],
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.add_rounded, color: Colors.white, size: 15),
        SizedBox(width: 5),
        Text(AppStrings.neww, style: TextStyle(color: Colors.white, fontSize: 13,
            fontWeight: FontWeight.w700)),
      ]),
    ),
  );
}
 
class _TipsCard extends StatelessWidget {
  final Color color;
  const _TipsCard({required this.color});
  @override
  Widget build(BuildContext context) {
    final tips = [
      [Icons.height_rounded,          AppStrings.Place_phone_at_waist_height],
      [Icons.directions_walk_rounded, AppStrings.Walk_naturally_and_steadily],
      [Icons.wb_sunny_rounded,        AppStrings.Ensure_good_lighting],
      [Icons.social_distance_rounded, AppStrings.Stay_2_3_meters_from_camera],
    ];
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: context.card, borderRadius: BorderRadius.circular(20),
          border: Border.all(color: context.border, width: 1.2)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(Icons.tips_and_updates_rounded, color: color, size: 15),
          const SizedBox(width: 8),
          Text(AppStrings.Recording_Tips, style: TextStyle(
              color: context.txt, fontSize: 13, fontWeight: FontWeight.w700)),
        ]),
        const SizedBox(height: 12),
        ...tips.map((t) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(children: [
            Container(padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(color: color.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(8)),
              child: Icon(t[0] as IconData, color: color, size: 12)),
            const SizedBox(width: 10),
            Text(t[1] as String, style: TextStyle(fontSize: 12,
                color: context.txt.withOpacity(0.50), height: 1.4)),
          ]),
        )),
      ]),
    );
  }
}
 
// ═══════════════════════════════════════════════════
//  SHARED RESULT WIDGETS (Hero, Metric, Issues, Recommend)
// ═══════════════════════════════════════════════════
class _MetricData {
  final String label, value;
  final Color color;
  final IconData icon;
  final double fraction;
  const _MetricData(this.label, this.value, this.color, this.icon, this.fraction);
}
 
class _MetricCard extends StatelessWidget {
  final _MetricData metric;
  const _MetricCard({required this.metric});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(color: context.card, borderRadius: BorderRadius.circular(20),
        border: Border.all(color: context.border, width: 1.2),
        boxShadow: [BoxShadow(color: metric.color.withOpacity(0.07), blurRadius: 12)]),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Container(padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(color: metric.color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10)),
          child: Icon(metric.icon, color: metric.color, size: 14)),
        const Spacer(),
        Container(width: 7, height: 7, decoration: BoxDecoration(
            shape: BoxShape.circle, color: metric.color.withOpacity(0.6))),
      ]),
      const Spacer(),
      Text(metric.value, style:  TextStyle(fontSize: 22, fontWeight: FontWeight.w800,
          color: context.txt, letterSpacing: -0.5)),
      const SizedBox(height: 2),
      Text(metric.label, style: TextStyle(fontSize: 11, color: context.txt.withOpacity(0.40))),
      const SizedBox(height: 8),
      ClipRRect(borderRadius: BorderRadius.circular(4), child: LinearProgressIndicator(
        value: metric.fraction, minHeight: 3,
        backgroundColor: context.border, valueColor: AlwaysStoppedAnimation(metric.color),
      )),
    ]),
  );
}
 
class _HeroCard extends StatelessWidget {
  final String classification;
  final double riskScore;
  final Color riskColor;
  final bool isNormal;
  const _HeroCard({required this.classification, required this.riskScore,
    required this.riskColor, required this.isNormal});
  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity, padding: const EdgeInsets.all(22),
    decoration: BoxDecoration(color: context.card, borderRadius: BorderRadius.circular(24),
        border: Border.all(color: riskColor.withOpacity(0.3), width: 1.5),
        boxShadow: [BoxShadow(color: riskColor.withOpacity(0.10), blurRadius: 30, spreadRadius: -4)]),
    child: Row(children: [
      SizedBox(width: 90, height: 90,
          child: CustomPaint(painter: _GaugePainter(riskScore, riskColor, context.border))),
      const SizedBox(width: 18),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(color: riskColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: riskColor.withOpacity(0.35))),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(isNormal ? Icons.check_circle_rounded : Icons.warning_amber_rounded,
                color: riskColor, size: 12),
            const SizedBox(width: 5),
            Text(classification, style: TextStyle(color: riskColor, fontSize: 11,
                fontWeight: FontWeight.w700)),
          ]),
        ),
        const SizedBox(height: 10),
        Text('${(riskScore * 100).toStringAsFixed(0)}%',
            style: TextStyle(fontSize: 36, fontWeight: FontWeight.w900,
                color: riskColor, letterSpacing: -1.5)),
        Text(AppStrings.fallRiskScore, style: TextStyle(fontSize: 12,
            color: context.txt.withOpacity(0.38))),
      ])),
    ]),
  );
}
 
class _IssuesCard extends StatelessWidget {
  final List<String> issues;
  const _IssuesCard({required this.issues});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(color: kRed.withOpacity(0.06),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: kRed.withOpacity(0.22), width: 1.2)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Icon(Icons.warning_amber_rounded, color: kRed, size: 16),
        SizedBox(width: 8),
        Text(AppStrings.detectedIssues, style: TextStyle(color: kRed, fontSize: 13,
            fontWeight: FontWeight.w700)),
      ]),
      const SizedBox(height: 12),
      ...issues.map((iss) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(width: 5, height: 5, margin: const EdgeInsets.only(top: 5, right: 10),
              decoration: const BoxDecoration(shape: BoxShape.circle, color: kRed)),
          Expanded(child: Text(iss, style: TextStyle(fontSize: 12,
              color: context.txt.withOpacity(0.60), height: 1.4))),
        ]),
      )),
    ]),
  );
}
 
class _RecommendCard extends StatelessWidget {
  final bool isNormal;
  final double riskScore;
  final Color color;
  const _RecommendCard({required this.isNormal, required this.riskScore, required this.color});
  @override
  Widget build(BuildContext context) {
    final recs = isNormal
        ? ['Gait pattern within normal parameters.',
           'Continue regular physical activity.',
           'Consider periodic reassessment every 3 months.']
        : riskScore < 0.6
        ? ['Moderate gait irregularities detected.',
           'Consider consulting a physiotherapist.',
           'Focus on balance and strength exercises.',
           'Use assistive devices if experiencing instability.']
        : ['High fall risk detected — immediate action advised.',
           'Avoid walking on uneven surfaces without support.',
           'Consult a neurologist or movement disorder specialist.',
           'Consider using a walking aid.'];
    final icon = isNormal ? Icons.thumb_up_rounded
        : riskScore < 0.6 ? Icons.medical_services_rounded : Icons.emergency_rounded;
 
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: context.card, borderRadius: BorderRadius.circular(22),
          border: Border.all(color: context.border, width: 1.2)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: color, size: 16)),
          const SizedBox(width: 10),
           Text(AppStrings.recommendations, style: TextStyle(color: context.txt,
              fontSize: 14, fontWeight: FontWeight.w700)),
        ]),
        const SizedBox(height: 14),
        ...recs.asMap().entries.map((e) => Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(width: 20, height: 20, margin: const EdgeInsets.only(right: 10),
              decoration: BoxDecoration(shape: BoxShape.circle,
                  color: color.withOpacity(0.12),
                  border: Border.all(color: color.withOpacity(0.3))),
              child: Center(child: Text('${e.key+1}', style: TextStyle(
                  color: color, fontSize: 10, fontWeight: FontWeight.w800)))),
            Expanded(child: Text(e.value, style: TextStyle(
                fontSize: 13, color: context.txt.withOpacity(0.58), height: 1.45))),
          ]),
        )),
      ]),
    );
  }
}
 
class _ErrorCard extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  final Color color;
  const _ErrorCard({super.key, required this.message,
    required this.onRetry, required this.color});
  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity, padding: const EdgeInsets.all(32),
    decoration: BoxDecoration(color: context.card, borderRadius: BorderRadius.circular(24),
        border: Border.all(color: color.withOpacity(0.2))),
    child: Column(children: [
      Container(width: 64, height: 64,
        decoration: BoxDecoration(shape: BoxShape.circle,
            color: color.withOpacity(0.08),
            border: Border.all(color: color.withOpacity(0.3), width: 1.5)),
        child: Icon(Icons.error_outline_rounded, color: color, size: 30)),
      const SizedBox(height: 16),
      Text(AppStrings.analysisFailed, style: TextStyle(fontSize: 18,
          fontWeight: FontWeight.w700, color: context.txt)),
      const SizedBox(height: 8),
      Text(message, textAlign: TextAlign.center, style: TextStyle(
          fontSize: 12, color: context.txt.withOpacity(0.45), height: 1.5)),
      const SizedBox(height: 22),
      GestureDetector(onTap: onRetry, child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 13),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [color, color.withOpacity(0.7)]),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [BoxShadow(color: color.withOpacity(0.4), blurRadius: 14)],
        ),
        child: const Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.refresh_rounded, color: Colors.white, size: 16),
          SizedBox(width: 8),
          Text('Try Again', style: TextStyle(color: Colors.white,
              fontSize: 14, fontWeight: FontWeight.w700)),
        ]),
      )),
    ]),
  );
}
 
// ═══════════════════════════════════════════════════
//  PAINTERS
// ═══════════════════════════════════════════════════
class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..color = kPrimary.withOpacity(0.07)..strokeWidth = 0.5;
    for (double x = 36; x < size.width; x += 36)
      canvas.drawLine(Offset(x,0), Offset(x,size.height), p);
    for (double y = 36; y < size.height; y += 36)
      canvas.drawLine(Offset(0,y), Offset(size.width,y), p);
  }
  @override bool shouldRepaint(_GridPainter _) => false;
}
 
class _ScanLinePainter extends CustomPainter {
  final double progress;
  final Color color;
  _ScanLinePainter(this.progress, this.color);
  @override
  void paint(Canvas canvas, Size size) {
    final y = progress * size.height;
    canvas.drawRect(Rect.fromLTWH(0, y-1.5, size.width, 3),
      Paint()..shader = LinearGradient(colors: [
        Colors.transparent, color.withOpacity(0.25),
        color.withOpacity(0.4), color.withOpacity(0.25), Colors.transparent,
      ]).createShader(Rect.fromLTWH(0, y-1.5, size.width, 3)));
  }
  @override bool shouldRepaint(_ScanLinePainter o) => o.progress != progress;
}
 
class _OrbitPainter extends CustomPainter {
  final double orbit, scan;
  final List<Color> colors;
  final Color track;
  _OrbitPainter(this.orbit, this.scan, this.colors, this.track);
  @override
  void paint(Canvas canvas, Size s) {
    final cx = s.width/2; final cy = s.height/2;
    final t = orbit * 2 * math.pi;
    canvas.drawCircle(Offset(cx,cy), 72, Paint()
      ..color = colors.first.withOpacity(0.07)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 16));
    canvas.drawCircle(Offset(cx,cy), 68, Paint()
      ..color = track..strokeWidth = 1.5..style = PaintingStyle.stroke);
    canvas.drawArc(Rect.fromCircle(center: Offset(cx,cy), radius: 68),
      t, 1.8, false, Paint()
        ..shader = SweepGradient(colors: [Colors.transparent, ...colors],
            startAngle: t, endAngle: t+1.8)
            .createShader(Rect.fromCircle(center: Offset(cx,cy), radius: 68))
        ..strokeWidth = 3.0..style = PaintingStyle.stroke..strokeCap = StrokeCap.round);
    final dx = cx + 68 * math.cos(t+1.8); final dy = cy + 68 * math.sin(t+1.8);
    canvas.drawCircle(Offset(dx,dy), 5, Paint()
      ..color = colors.last.withOpacity(0.7)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5));
    canvas.drawCircle(Offset(dx,dy), 3, Paint()..color = Colors.white);
    canvas.drawCircle(Offset(cx,cy), 46, Paint()
      ..color = track.withOpacity(0.5)..strokeWidth = 1..style = PaintingStyle.stroke);
    final op = 0.35 + 0.25*math.sin(scan * 2 * math.pi);
    canvas.drawCircle(Offset(cx,cy), 22, Paint()
      ..color = colors.first.withOpacity(op * 0.25)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10));
    canvas.drawCircle(Offset(cx,cy), 18, Paint()..color = track);
    canvas.drawLine(Offset(cx-7,cy), Offset(cx+7,cy), Paint()
      ..color = colors.first.withOpacity(0.5)..strokeWidth = 1.5);
    canvas.drawLine(Offset(cx,cy-7), Offset(cx,cy+7), Paint()
      ..color = colors.first.withOpacity(0.5)..strokeWidth = 1.5);
    canvas.drawCircle(Offset(cx,cy), 2.5, Paint()..color = colors.first.withOpacity(0.8));
  }
  @override bool shouldRepaint(_OrbitPainter o) => o.orbit != orbit || o.scan != scan;
}
 
class _GaugePainter extends CustomPainter {
  final double value; final Color color, trackColor;
  _GaugePainter(this.value, this.color, this.trackColor);
  @override
  void paint(Canvas c, Size s) {
    final cx = s.width/2; final cy = s.height/2;
    final r = math.min(cx,cy)-6;
    c.drawArc(Rect.fromCircle(center: Offset(cx,cy), radius: r),
      math.pi*0.75, math.pi*1.5, false, Paint()
        ..color = trackColor..strokeWidth = 8..style = PaintingStyle.stroke..strokeCap = StrokeCap.round);
    c.drawArc(Rect.fromCircle(center: Offset(cx,cy), radius: r),
      math.pi*0.75, math.pi*1.5*value, false, Paint()
        ..shader = SweepGradient(colors: const [kGreen,kOrange,kRed],
            stops: const [0,0.5,1], startAngle: math.pi*0.75, endAngle: math.pi*2.25)
            .createShader(Rect.fromCircle(center: Offset(cx,cy), radius: r))
        ..strokeWidth = 8..style = PaintingStyle.stroke..strokeCap = StrokeCap.round);
    final tp = TextPainter(
      text: TextSpan(text: '${(value*100).toStringAsFixed(0)}',
        style: TextStyle(color: color, fontSize: 20, fontWeight: FontWeight.w900)),
      textDirection: TextDirection.ltr)..layout();
    tp.paint(c, Offset(cx-tp.width/2, cy-tp.height/2));
  }
  @override bool shouldRepaint(_GaugePainter o) => o.value != value;
}
 
List<Widget> _corners(Color clr) {
  const sz = 22.0; const th = 2.5;
  Widget c(double? top, double? bottom, double? left, double? right) =>
      Positioned(top: top, bottom: bottom, left: left, right: right,
        child: SizedBox(width: sz, height: sz, child: CustomPaint(
          painter: _CornerPainter(top: top != null, left: left != null,
              color: clr.withOpacity(0.65), thickness: th))));
  return [c(14,null,14,null), c(14,null,null,14), c(null,14,14,null), c(null,14,null,14)];
}
 
class _CornerPainter extends CustomPainter {
  final bool top, left; final Color color; final double thickness;
  const _CornerPainter({required this.top, required this.left,
    required this.color, required this.thickness});
  @override
  void paint(Canvas c, Size s) {
    final p = Paint()..color = color..strokeWidth = thickness
      ..strokeCap = StrokeCap.round..style = PaintingStyle.stroke;
    final x0 = left ? 0.0 : s.width; final y0 = top ? 0.0 : s.height;
    final xE = left ? s.width : 0.0; final yE = top ? s.height : 0.0;
    c.drawLine(Offset(x0,y0), Offset(xE,y0), p);
    c.drawLine(Offset(x0,y0), Offset(x0,yE), p);
  }
  @override bool shouldRepaint(_CornerPainter _) => false;
}

// ignore: unused_element
class _FallRiskHero extends StatelessWidget {
  final double score;
  const _FallRiskHero({required this.score});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [kGreen.withOpacity(0.10), kGreen.withOpacity(0.03)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(24),
      border: Border.all(color: kGreen.withOpacity(0.22), width: 1.5),
      boxShadow: [BoxShadow(color: kGreen.withOpacity(0.08), blurRadius: 20)],
    ),
    child: Row(
      children: [
        // ring
        SizedBox(
          width: 80,
          height: 80,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CustomPaint(
                size: const Size(80, 80),
                painter: _RingPainter(progress: score, color: kGreen),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${(score * 100).toInt()}%',
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: kGreen,
                      letterSpacing: -0.4,
                    ),
                  ),
                  Text(
                    AppStrings.low,
                    style: TextStyle(
                      fontSize: 9,
                      color: kGreen,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: 18),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppStrings.fallRiskScore,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: kPrimary,
                ),
              ),
              const SizedBox(height: 5),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: kGreen.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '✅  ${AppStrings.low} Risk — Excellent Gait',
                  style: TextStyle(
                    fontSize: 12,
                    color: kGreen,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Your walking pattern is stable and balanced. Keep up the great work!',
                style: TextStyle(
                  fontSize: 12,
                  color: kPrimary.withOpacity(0.45),
                  height: 1.45,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _RingPainter extends CustomPainter {
  final double progress;
  final Color color;
  _RingPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = size.width / 2 - 6;
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..color = color.withOpacity(0.10)
        ..strokeWidth = 5
        ..style = PaintingStyle.stroke,
    );
    canvas.drawArc(
      Rect.fromCircle(center: c, radius: r),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      Paint()
        ..color = color
        ..strokeWidth = 5
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke,
    );
  }

  @override
  bool shouldRepaint(_RingPainter o) => o.progress != progress;
}

class ProfilePage extends StatefulWidget {
  final VoidCallback onLanguageChange;
  const ProfilePage({super.key, required this.onLanguageChange});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with SingleTickerProviderStateMixin {
  final name = FirebaseAuth.instance.currentUser!.displayName ?? 'User';
  final user = FirebaseAuth.instance.currentUser!;
  late AnimationController _entry;
  bool _notifications = true;
  // ignore: unused_field
  bool _darkMode = false;

  @override
  void initState() {
    super.initState();
    _entry = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();
  }

  @override
  void dispose() {
    _entry.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            _AnimEntry(_entry, 0, _buildProfileHeader()),
            const SizedBox(height: 24),

            // Personal Info
            _AnimEntry(_entry, 0.2, _buildInfoCard()),
            const SizedBox(height: 16),

            // Language selector
            _AnimEntry(_entry, 0.3, _buildLanguageCard()),
            const SizedBox(height: 16),

            // App settings
            _AnimEntry(_entry, 0.4, _buildAppSettings()),
            const SizedBox(height: 16),

            // Sign out
            _AnimEntry(_entry, 0.5, _buildSignOut()),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1558C0), Color(0xFF1A82E0)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: kPrimary.withOpacity(0.3),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Stack(
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [kAccent.withOpacity(0.7), kPrimary],
                  ),
                  boxShadow: [
                    BoxShadow(color: kAccent.withOpacity(0.3), blurRadius: 16),
                  ],
                ),
                child: const Icon(
                  Icons.person_rounded,
                  color: const Color(0xFF0D1B3E),
                  size: 36,
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.displayName ?? 'User',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF0D1B3E),
                    letterSpacing: -0.4,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  user.email!,
                  style: TextStyle(
                    fontSize: 13,
                    color: const Color(0xFF0D1B3E).withOpacity(0.58),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A6FD4).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {},
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF1A6FD4).withOpacity(0.10),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    final info = [
      (AppStrings.email, user.email!, Icons.email_outlined),
      (AppStrings.password, 'Password', Icons.lock_outlined),
    ];
    return _ProfileCard(
      title: AppStrings.personalInfo,
      icon: Icons.person_outline_rounded,
      child: Column(
        children: info
            .map((item) => _InfoRow(item.$1, item.$2, item.$3))
            .toList(),
      ),
    );
  }

  Widget _buildLanguageCard() {
    return _ProfileCard(
      title: AppStrings.language,
      icon: Icons.language_rounded,
      child: Row(
        children: [
          Expanded(
            child: _LangBtn(
              label: AppStrings.english,
              selected: !AppStrings.isArabic,
              onTap: () {
                AppStrings.isArabic = false;
                setState(() {});
                widget.onLanguageChange();
              },
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _LangBtn(
              label: AppStrings.arabic,
              selected: AppStrings.isArabic,
              onTap: () {
                AppStrings.isArabic = true;
                setState(() {});
                widget.onLanguageChange();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppSettings() {
    return _ProfileCard(
      title: AppStrings.appSettings,
      icon: Icons.settings_outlined,
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) => Column(
          children: [
            _ToggleRow(
              label: AppStrings.notifications,
              icon: Icons.notifications_outlined,
              value: _notifications,
              onChanged: (v) => setState(() => _notifications = v),
            ),
            _Divider2(),
            _ToggleRow(
              label: AppStrings.darkMode,
              icon: Icons.dark_mode_outlined,
              value: themeProvider.isDark, // ← من الـ provider
              onChanged: (v) {
                themeProvider.toggle(v); // ← يعدّل الـ provider
                setState(() => _darkMode = v); // ← يحدّث الـ local state
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSignOut() {
    return GestureDetector(
      onTap: () async {
        await FirebaseAuth.instance.signOut();
        if (!mounted) return;
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const GetStartedPage()),
          (route) => false,
        );
      },
      child: Container(
        width: double.infinity,
        height: 54,
        decoration: BoxDecoration(
          color: kRed.withOpacity(0.1),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: kRed.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.logout_rounded, color: kRed.withOpacity(0.8), size: 18),
            const SizedBox(width: 10),
            Text(
              AppStrings.signOut,
              style: TextStyle(
                color: kRed.withOpacity(0.8),
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AnimEntry extends StatelessWidget {
  final AnimationController ctrl;
  final double offset;
  final Widget child;
  const _AnimEntry(this.ctrl, this.offset, this.child);

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: ctrl,
      builder: (_, __) {
        final t = math.max(0.0, math.min(1.0, (ctrl.value - offset) / 0.45));
        return Transform.translate(
          offset: Offset(0, 24 * (1 - t)),
          child: Opacity(opacity: t, child: child),
        );
      },
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String label;
  final String sub;
  const _SectionHeader({required this.label, required this.sub});

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Text(
        label,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: context.txt,
        ),
      ),
      const Spacer(),
      Text(
        sub,
        style: TextStyle(fontSize: 12, color: context.txtSub.withOpacity(0.32)),
      ),
    ],
  );
}

class _PillBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool secondary;
  const _PillBtn({
    required this.icon,
    required this.label,
    required this.onTap,
    this.secondary = false,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: secondary
            ? const Color(0xFF1A6FD4).withOpacity(0.10)
            : Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: secondary ? Colors.white : kPrimary, size: 16),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: secondary ? Colors.white : kPrimary,
            ),
          ),
        ],
      ),
    ),
  );
}

class _FallRiskCircle extends StatelessWidget {
  final double score;
  final String label;
  final Color color;
  const _FallRiskCircle({
    required this.score,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 80,
    height: 80,
    child: Stack(
      alignment: Alignment.center,
      children: [
        CustomPaint(
          size: const Size(80, 80),
          painter: _RingPainter(progress: score, color: color),
        ),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${(score * 100).toInt()}%',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: color,
                letterSpacing: -0.4,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 9,
                color: const Color(0xFF0D1B3E).withOpacity(0.38),
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

class _LinechartPainter extends CustomPainter {
  final List<double> data;
  final List<String> days;
  _LinechartPainter({required this.data, required this.days});

  @override
  void paint(Canvas canvas, Size size) {
    final min = data.reduce(math.min);
    final max = data.reduce(math.max);
    final range = max - min;
    final pts = List.generate(data.length, (i) {
      final x = i / (data.length - 1) * size.width;
      final y =
          size.height -
          ((data[i] - min) / range) * (size.height * 0.8) -
          size.height * 0.1;
      return Offset(x, y);
    });

    // gradient fill
    final path = Path()..moveTo(pts.first.dx, size.height);
    for (final p in pts) path.lineTo(p.dx, p.dy);
    path
      ..lineTo(pts.last.dx, size.height)
      ..close();
    canvas.drawPath(
      path,
      Paint()
        ..shader = LinearGradient(
          colors: [kPrimary.withOpacity(0.3), kAccent.withOpacity(0.0)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height)),
    );

    // line
    final lp = Path()..moveTo(pts.first.dx, pts.first.dy);
    for (int i = 1; i < pts.length; i++) {
      final cp = Offset((pts[i - 1].dx + pts[i].dx) / 2, pts[i - 1].dy);
      final cp2 = Offset((pts[i - 1].dx + pts[i].dx) / 2, pts[i].dy);
      lp.cubicTo(cp.dx, cp.dy, cp2.dx, cp2.dy, pts[i].dx, pts[i].dy);
    }
    canvas.drawPath(
      lp,
      Paint()
        ..color = kAccent
        ..strokeWidth = 2.5
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );

    // dots
    for (int i = 0; i < pts.length; i++) {
      canvas.drawCircle(pts[i], 4, Paint()..color = kBg);
      canvas.drawCircle(pts[i], 3, Paint()..color = kAccent);
    }
  }

  @override
  bool shouldRepaint(_LinechartPainter o) => false;
}

class _ProfileCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;
  const _ProfileCard({
    required this.title,
    required this.icon,
    required this.child,
  });

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: context.card,
      borderRadius: BorderRadius.circular(22),
      border: Border.all(color: context.border, width: 1.2),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: kAccent, size: 16),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: context.txt,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        child,
      ],
    ),
  );
}

class _InfoRow extends StatelessWidget {
  final String label, value;
  final IconData icon;
  const _InfoRow(this.label, this.value, this.icon);

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 14),
    child: Row(
      children: [
        Icon(icon, color: context.txtSub.withOpacity(0.22), size: 16),
        const SizedBox(width: 12),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: context.txtSub.withOpacity(0.42),
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: context.txt,
          ),
        ),
        const SizedBox(width: 4),
        Icon(
          Icons.chevron_right_rounded,
          color: context.txtSub.withOpacity(0.12),
          size: 16,
        ),
      ],
    ),
  );
}

class _LangBtn extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _LangBtn({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      height: 52,
      decoration: BoxDecoration(
        gradient: selected
            ? const LinearGradient(colors: [kPrimary, kAccent])
            : null,
        color: selected ? null : context.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: selected ? Colors.transparent : context.border,
          width: 1.5,
        ),
        boxShadow: selected
            ? [BoxShadow(color: kPrimary.withOpacity(0.4), blurRadius: 12)]
            : [],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: selected ? Colors.white : context.txt.withOpacity(0.82),
            ),
          ),
          if (selected) ...[
            const SizedBox(width: 6),
            const Icon(
              Icons.check_circle_rounded,
              color: const Color(0xFF0D1B3E),
              size: 15,
            ),
          ],
        ],
      ),
    ),
  );
}

class _ToggleRow extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool value;
  final void Function(bool) onChanged;
  const _ToggleRow({
    required this.label,
    required this.icon,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      children: [
        Icon(icon, color: context.txtSub.withOpacity(0.28), size: 18),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: context.txtSub.withOpacity(0.42),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            onChanged(!value);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            width: 46,
            height: 26,
            decoration: BoxDecoration(
              color: value
                  ? kPrimary
                  : const Color(0xFF1A6FD4).withOpacity(0.08),
              borderRadius: BorderRadius.circular(13),
              border: Border.all(
                color: value ? Colors.transparent : context.border,
              ),
            ),
            child: Stack(
              children: [
                AnimatedAlign(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOutCubic,
                  alignment: value
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.all(3),
                    width: 20,
                    height: 20,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF0D1B3E),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

class _Divider2 extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
      Divider(color: context.border, height: 20, thickness: 1);
}

class CameraScreen extends StatefulWidget {
  final CameraDescription camera;
  const CameraScreen({required this.camera, super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late CameraController _controller;
  late Future<void> _initFuture;

  @override
  void initState() {
    super.initState();
    _controller = CameraController(widget.camera, ResolutionPreset.high);
    _initFuture = _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: FutureBuilder(
        future: _initFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          return Stack(
            children: [
              SizedBox.expand(child: CameraPreview(_controller)),

              Positioned(
                top: 50,
                left: 16,
                child: IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class SensorReading {
  final double x, y, z;
  final DateTime timestamp;
  const SensorReading(this.x, this.y, this.z, this.timestamp);
}

class FogEvent {
  final DateTime time;
  final double duration; // seconds
  final double riskScore;
  final String severity; // 'Low' / 'Moderate' / 'High'
  FogEvent({
    required this.time,
    required this.duration,
    required this.riskScore,
    required this.severity,
  });
}

class SensorManager {
  // Latest raw readings
  SensorReading? accel; // hip proxy (phone in pocket)
  SensorReading? gyro;
  SensorReading? magneto;

  // Streams
  StreamSubscription? _accelSub;
  StreamSubscription? _gyroSub;
  StreamSubscription? _magnetoSub;

  // Sliding window for model (50 samples × 9 features)
  static const int windowSize = 100;
  static const int stepSize = 50;
  final List<List<double>> _window = [];

  final void Function(List<List<double>> window) onWindowReady;
  final void Function(SensorReading a, SensorReading g, SensorReading m)
  onUpdate;

  SensorManager({required this.onWindowReady, required this.onUpdate});

  void start() {
    _accelSub = userAccelerometerEventStream(
      samplingPeriod: const Duration(microseconds: 15625),
    ).listen((e) {
      accel = SensorReading(e.x, e.y, e.z, DateTime.now());
      _tryPushWindow();
    });

    _gyroSub = gyroscopeEventStream(samplingPeriod: SensorInterval.gameInterval)
        .listen((e) {
          gyro = SensorReading(e.x, e.y, e.z, DateTime.now());
          _tryPushWindow();
        });

    _magnetoSub =
        magnetometerEventStream(
          samplingPeriod: SensorInterval.gameInterval,
        ).listen((e) {
          magneto = SensorReading(e.x, e.y, e.z, DateTime.now());
          _tryPushWindow();
        });
  }


DateTime? _lastPushTime;
int _warmupFrames = 0;
bool _warmupDone = false;
static const int _warmupRequired = 150;
  // في SensorManager._tryPushWindow() — طبّق التحويل هنا
  void _tryPushWindow() {
  if (accel == null || gyro == null || magneto == null) return;

  final now = DateTime.now();
  if (_lastPushTime != null &&
      now.difference(_lastPushTime!).inMilliseconds < 15) return;
  _lastPushTime = now;

  List<double> row;

  if (Platform.isIOS) {
    row = [
      accel!.x * 9.81, accel!.y * 9.81, accel!.z * 9.81,
      gyro!.x, gyro!.y, gyro!.z,
      magneto!.x, magneto!.y, magneto!.z,
    ];
  } else {
    // Android في الجيب: Z هو forward، X هو lateral
    row = [
      accel!.z,  // forward/back
      accel!.x,  // left/right
      accel!.y,  // up/down
      gyro!.z,
      gyro!.x,
      gyro!.y,
      magneto!.z,
      magneto!.x,
      magneto!.y,
    ];
    // userAccelerometer بيجي بـ m/s² بدون gravity — لا حاجة لتحويل
  }

  _window.add(row);

    if (!_warmupDone) {
    _warmupFrames++;
    if (_warmupFrames >= _warmupRequired) _warmupDone = true;
    return; 
  }

  if (_window.length >= windowSize) {
    onWindowReady(List.from(_window));
    _window.removeRange(0, stepSize);
  }


   if (_window.length % 50 == 0) {
    print('🔍 Sample: accel=${accel!.x.toStringAsFixed(2)},'
        '${accel!.y.toStringAsFixed(2)},${accel!.z.toStringAsFixed(2)}'
        ' | gyro=${gyro!.x.toStringAsFixed(2)},'
        '${gyro!.y.toStringAsFixed(2)},${gyro!.z.toStringAsFixed(2)}');
  }

    onUpdate(accel!, gyro!, magneto!);
  }


  void stop() {
  _accelSub?.cancel();
  _gyroSub?.cancel();
  _magnetoSub?.cancel();
  _window.clear();
  _warmupFrames = 0;
  _warmupDone = false;
  _lastPushTime = null;
  accel = gyro = magneto = null;
}

  Map<String, double> get magnitudes => {
    'accel': accel == null ? 0 : _mag(accel!),
    'gyro': gyro == null ? 0 : _mag(gyro!),
    'magneto': magneto == null ? 0 : _mag(magneto!),
  };

  double _mag(SensorReading r) => sqrt(r.x * r.x + r.y * r.y + r.z * r.z);
}

class FogDetectorPage extends StatefulWidget {
  const FogDetectorPage({super.key});

  @override
  State<FogDetectorPage> createState() => _FogDetectorPageState();
}

class _FogDetectorPageState extends State<FogDetectorPage> with TickerProviderStateMixin, WidgetsBindingObserver {
  // ── State ──
  bool _monitoring = false;
  double _fogRisk = 0.0; 
  int _stepsToday = 0;
  int _fogEventsCount = 0;
  Duration _sessionDuration = Duration.zero;
  late FogApi _fogApi;
  final List<FogEvent> _events = [];

  // ── Sensors ──
  late SensorManager _sensors;
  SensorReading? _lastAccel;
  SensorReading? _lastGyro;
  SensorReading? _lastMagneto;

  // ── Step counter ──
  StreamSubscription<StepCount>? _stepSub;
  int _stepBase = 0;

  // ── Session timer ──
  Timer? _sessionTimer;
  DateTime? _sessionStart;

  // ── Animations ──
  late AnimationController _pulseCtrl; // risk circle pulse
  late AnimationController _waveCtrl; // background wave
  late AnimationController _fadeCtrl; // initial fade-in
  late Animation<double> _pulseAnim;
  late Animation<double> _waveAnim;
  late Animation<double> _fadeAnim;

  bool _fogActive = false; 
  DateTime? _fogStart;

  List<double> transformReading(
    SensorReading accel,
    SensorReading gyro,
    SensorReading mag,
  ) {
    double ax, ay, az, gx, gy, gz, mx, my, mz;

    if (Platform.isIOS) {
      ax = accel.x * 9.81; 
      ay = accel.y * 9.81;
      az = accel.z * 9.81;
      gx = gyro.x;
      gy = gyro.y;
      gz = gyro.z;
      mx = mag.x;
      my = mag.y;
      mz = mag.z;
    } else {
      ax = accel.y; 
      ay = accel.x;
      az = accel.z;
      gx = gyro.y;
      gy = gyro.x;
      gz = gyro.z;
      mx = mag.y;
      my = mag.x;
      mz = mag.z;
      // التسارع في Android بالفعل بـ m/s²، لا نحتاج تحويل إضافي
    }
    return [ax, ay, az, gx, gy, gz, mx, my, mz];
  }

  @override
  void initState() {
    super.initState();
    String baseUrl;
    if (Platform.isAndroid) {
      
      baseUrl = 'http://172.20.10.3:5002'; 
    } else {
      baseUrl = 'http://172.20.10.3:5002'; 
    }
    _fogApi = FogApi(baseUrl: baseUrl);
    // ...

    WidgetsBinding.instance.addObserver(this);

    _sensors = SensorManager(
      onUpdate: (a, g, m) {
        setState(() {
          _lastAccel = a;
          _lastGyro = g;
          _lastMagneto = m;
        });
      },
      onWindowReady: _onModelWindow,
    );

    // Animations
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    _waveCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();

    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _pulseAnim = Tween(
      begin: 0.96,
      end: 1.04,
    ).animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));
    _waveAnim = Tween(
      begin: 0.0,
      end: 2 * pi,
    ).animate(CurvedAnimation(parent: _waveCtrl, curve: Curves.linear));
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);

    _fadeCtrl.forward();
    _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    final statuses = await [
      Permission.activityRecognition,
      Permission.sensors,
      Permission.sensorsAlways, 
    ].request();

    final allGranted = statuses.values.every(
      (s) => s == PermissionStatus.granted || s == PermissionStatus.limited,
    );

    print('Permissions: $statuses');
    print('All granted: $allGranted');
  }

  final List<double> _riskBuffer = [];

  void _onModelWindow(List<List<double>> window) async {
    if (!_monitoring) return;
    try {
      final raw = await _fogApi.predict(window);
      _riskBuffer.add(raw);
      if (_riskBuffer.length > 5) _riskBuffer.removeAt(0);
      final smoothed = _riskBuffer.reduce((a, b) => a + b) / _riskBuffer.length;
      if (mounted) {
        setState(() => _fogRisk = smoothed);
        _handleFogLogic(smoothed);
      }
    } catch (e) {
      print('API error: $e');
      // يمكن هنا استخدام الحساب التقديري كبديل في حالة فشل الشبكة
      double energy = 0;
      for (final row in window) {
        for (final v in row) energy += v * v;
      }
      final fallbackRisk = (energy / (window.length * 9 * 200)).clamp(0.0, 1.0);
      if (mounted) {
        setState(() => _fogRisk = fallbackRisk);
        _handleFogLogic(fallbackRisk);
      }
    }
  }

  void _handleFogLogic(double risk) {
    const threshold = 0.65;

    if (risk >= threshold && !_fogActive) {
      // FOG ONSET
      _fogActive = true;
      _fogStart = DateTime.now();
      // _triggerAlert();
    } else if (risk < threshold && _fogActive) {
      // FOG END
      _fogActive = false;
      final dur = DateTime.now().difference(_fogStart!).inMilliseconds / 1000;
      setState(() {
        _fogEventsCount++;
        _events.insert(
          0,
          FogEvent(
            time: _fogStart!,
            duration: dur,
            riskScore: risk,
            severity: dur < 3
                ? 'Low'
                : dur < 8
                ? 'Moderate'
                : 'High',
          ),
        );
      });
    }
  }

  // Future<void> _triggerAlert() async {
  //   // Vibration SOS pattern: strong → pause → strong → pause → strong
  //   if (await Vibration.hasVibrator() ?? false) {
  //     Vibration.vibrate(pattern: [0, 400, 200, 400, 200, 800]);
  //   }
  //   // TODO: play audio cue via just_audio
  // }

  // ────────────────────────────────────────────────────────────────────────
  //  MONITORING CONTROL
  // ────────────────────────────────────────────────────────────────────────

  Future<void> _toggleMonitoring() async {
    HapticFeedback.heavyImpact();

    if (!_monitoring) {
      // اطلب permissions أول
      await _requestPermissions();

      // ← ابدأ حتى لو _permissionsOk = false (الـ sensors الأساسية تشتغل بدون permission)
      setState(() => _monitoring = true);
      _sessionStart = DateTime.now();
      _sensors.start();

      _stepSub = Pedometer.stepCountStream.listen(
        (e) {
          if (_stepBase == 0) _stepBase = e.steps;
          setState(() => _stepsToday = e.steps - _stepBase);
        },
        onError: (e) => print('Pedometer error: $e'), // ← لا يوقف الباقي
      );

      _sessionTimer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (mounted)
          setState(() {
            _sessionDuration = DateTime.now().difference(_sessionStart!);
          });
      });
    } else {
      _sensors.stop();
      _stepSub?.cancel();
      _sessionTimer?.cancel();
      setState(() {
        _monitoring = false;
        _fogActive = false;
        _fogRisk = 0.0;
      });
    }
  }

  // ────────────────────────────────────────────────────────────────────────
  //  BUILD
  // ────────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      extendBody: true,
      body: FadeTransition(
        opacity: _fadeAnim,
        child: Stack(
          children: [
            // ── Animated background ──
            AnimatedBuilder(
              animation: _waveAnim,
              builder: (_, __) => CustomPaint(
                size: MediaQuery.of(context).size,
                painter: _WaveBgPainter(
                  phase: _waveAnim.value,
                  active: _monitoring,
                  risk: _fogRisk,
                ),
              ),
            ),

            SafeArea(
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(child: _buildHeader()),
                  SliverToBoxAdapter(child: _buildRiskOrb()),
                  SliverToBoxAdapter(child: const SizedBox(height: 28)),
                  SliverToBoxAdapter(child: _buildMainButton()),
                  SliverToBoxAdapter(child: const SizedBox(height: 32)),
                  SliverToBoxAdapter(child: _buildStatsRow()),
                  SliverToBoxAdapter(child: const SizedBox(height: 24)),
                  SliverToBoxAdapter(child: _buildSensorPanel()),
                  SliverToBoxAdapter(child: const SizedBox(height: 24)),
                  if (_events.isNotEmpty) ...[
                    SliverToBoxAdapter(child: _buildEventsHeader()),
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (ctx, i) => _buildEventCard(_events[i]),
                        childCount: _events.length,
                      ),
                    ),
                  ],
                  const SliverToBoxAdapter(child: SizedBox(height: 100)),
                ],
              ),
            ),

            // ── FOG ALERT BANNER ──
            if (_fogActive && _monitoring)
              _FogAlertBanner(
                onDismiss: () => setState(() => _fogActive = false),
              ),
          ],
        ),
      ),
    );
  }

  // ── Header ──────────────────────────────────────────────────────────────

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: kPrimary.withOpacity(0.12),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: kPrimary.withOpacity(0.25)),
            ),
            child: const Icon(Icons.radar, color: kPrimary, size: 22),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppStrings.fogDetector,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: context.txt,
                  letterSpacing: 2.5,
                ),
              ),
              Text(
                _monitoring
                    ? 'Session  ${_formatClock(_sessionDuration)}'
                    : AppStrings.freezingOfGaitDetector,
                style: TextStyle(fontSize: 12, color: context.txtDim),
              ),
            ],
          ),
          const Spacer(),
          // Live dot
          AnimatedBuilder(
            animation: _pulseCtrl,
            builder: (_, __) => Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _monitoring
                    ? Color.lerp(
                        kGreen,
                        kGreen.withOpacity(0.3),
                        _pulseCtrl.value,
                      )!
                    : context.txtDim,
                boxShadow: _monitoring
                    ? [BoxShadow(color: kGreen.withOpacity(0.5), blurRadius: 8)]
                    : [],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Risk Orb ─────────────────────────────────────────────────────────────

  Widget _buildRiskOrb() {
    final Color riskColor = _fogRisk < 0.35
        ? kGreen
        : _fogRisk < 0.65
        ? kOrange
        : kRed;
    final String riskLabel = _fogRisk < 0.35
        ? AppStrings.safe
        : _fogRisk < 0.65
        ? AppStrings.moderate
        : AppStrings.highRisk;

    return Padding(
      padding: const EdgeInsets.only(top: 36),
      child: Center(
        child: AnimatedBuilder(
          animation: _pulseAnim,
          builder: (_, __) => Transform.scale(
            scale: _monitoring ? _pulseAnim.value : 1.0,
            child: SizedBox(
              width: 220,
              height: 220,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Outer glow ring
                  Container(
                    width: 220,
                    height: 220,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          riskColor.withOpacity(_monitoring ? 0.18 : 0.06),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                  // Progress ring
                  SizedBox(
                    width: 170,
                    height: 170,
                    child: CustomPaint(
                      painter: _RinggPainter(
                        value: _fogRisk,
                        color: riskColor,
                        active: _monitoring,
                        trackColor: context.card2,
                      ),
                    ),
                  ),
                  // Inner content
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${(_fogRisk * 100).toInt()}%',
                        style: TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.w900,
                          color: riskColor,
                          height: 1,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                      const SizedBox(height: 4),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 400),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: riskColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: riskColor.withOpacity(0.35),
                          ),
                        ),
                        child: Text(
                          riskLabel,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: riskColor,
                            letterSpacing: 1.8,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Main Button ──────────────────────────────────────────────────────────

  Widget _buildMainButton() {
    return Center(
      child: GestureDetector(
        onTap: _toggleMonitoring,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          width: 220,
          height: 64,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: _monitoring
                  ? [const Color(0xFFDC2626), const Color(0xFFEF4444)]
                  : [kPrimary, kAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: (_monitoring ? kRed : kPrimary).withOpacity(0.45),
                blurRadius: 30,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: Icon(
                  _monitoring ? Icons.stop_rounded : Icons.play_arrow_rounded,
                  key: ValueKey(_monitoring),
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                _monitoring ? AppStrings.stop : AppStrings.startMonitoring,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Stats Row ────────────────────────────────────────────────────────────

  Widget _buildStatsRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: _StatCard(
              label: AppStrings.steps,
              value: _stepsToday.toString(),
              icon: Icons.directions_walk_rounded,
              color: kGreen,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _StatCard(
              label: AppStrings.fogevent,
              value: _fogEventsCount.toString(),
              icon: Icons.pause_circle_outline_rounded,
              color: kOrange,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _StatCard(
              label: AppStrings.session,
              value: _monitoring ? _formatClock(_sessionDuration) : '--:--',
              icon: Icons.timer_outlined,
              color: kPrimary,
            ),
          ),
        ],
      ),
    );
  }

  // ── Sensor Panel ─────────────────────────────────────────────────────────

  Widget _buildSensorPanel() {
    final mags = _sensors.magnitudes;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: context.card,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: context.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.sensors, color: kAccent, size: 18),
                const SizedBox(width: 10),
                Text(
                  AppStrings.sensorReadings,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: context.txt,
                    letterSpacing: 0.5,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: _monitoring
                        ? kGreen.withOpacity(0.12)
                        : context.card2,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: _monitoring
                          ? kGreen.withOpacity(0.35)
                          : context.border,
                    ),
                  ),
                  child: Text(
                    _monitoring ? 'LIVE' : 'IDLE',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: _monitoring ? kGreen : context.txtDim,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _SensorRow(
              label: AppStrings.accelerometer,
              sublabel: 'Hip / pocket',
              value: mags['accel'] ?? 0,
              maxValue: 20,
              color: kPrimary,
              icon: Icons.phone_android_rounded,
              reading: _lastAccel,
            ),
            const SizedBox(height: 12),
            _SensorRow(
              label: AppStrings.gyroscope,
              sublabel: AppStrings.rotationrate,
              value: mags['gyro'] ?? 0,
              maxValue: 10,
              color: kAccent,
              icon: Icons.rotate_90_degrees_ccw_rounded,
              reading: _lastGyro,
            ),
            const SizedBox(height: 12),
            _SensorRow(
              label: AppStrings.magnetometer,
              sublabel: AppStrings.orientation,
              value: (mags['magneto'] ?? 0) / 10,
              maxValue: 10,
              color: kOrange,
              icon: Icons.explore_rounded,
              reading: _lastMagneto,
            ),
          ],
        ),
      ),
    );
  }

  // ── Events ───────────────────────────────────────────────────────────────

  Widget _buildEventsHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
      child: Row(
        children: [
          const Icon(Icons.history_rounded, color: kPrimary, size: 18),
          const SizedBox(width: 10),
          Text(
            AppStrings.fogevent,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: context.txt,
            ),
          ),
          const Spacer(),
          Text(
            '${_events.length} recorded',
            style: TextStyle(fontSize: 12, color: context.txtDim),
          ),
        ],
      ),
    );
  }

  Widget _buildEventCard(FogEvent e) {
    final Color c = e.severity == 'High'
        ? kRed
        : e.severity == 'Moderate'
        ? kOrange
        : kGreen;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: context.card,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: c.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: c.withOpacity(0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.pause_circle_rounded, color: c, size: 20),
                  Text(
                    '${e.duration.toStringAsFixed(1)}s',
                    style: TextStyle(
                      fontSize: 10,
                      color: c,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppStrings.fogDetected,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: context.txt,
                    ),
                  ),
                  Text(
                    '${_formatTime(e.time)}  ·  ${e.severity} severity',
                    style: TextStyle(fontSize: 12, color: context.txtDim),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: c.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '${(e.riskScore * 100).toInt()}%',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: c,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ────────────────────────────────────────────────────────────────────────
  //  UTILS
  // ────────────────────────────────────────────────────────────────────────

  String _formatClock(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  String _formatTime(DateTime t) {
    final h = t.hour.toString().padLeft(2, '0');
    final m = t.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _pulseCtrl.dispose();
    _waveCtrl.dispose();
    _fadeCtrl.dispose();
    _sensors.stop();
    _stepSub?.cancel();
    _sessionTimer?.cancel();
    super.dispose();
  }
}

// ════════════════════════════════════════════════════════════════════════════
//  SUB-WIDGETS
// ════════════════════════════════════════════════════════════════════════════

// ── Stat Card ────────────────────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color color;
  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      decoration: BoxDecoration(
        color: context.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: context.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(height: 10),
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: context.txt,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          Text(label, style: TextStyle(fontSize: 11, color: context.txtDim)),
        ],
      ),
    );
  }
}

// ── Sensor Row ───────────────────────────────────────────────────────────────

class _SensorRow extends StatelessWidget {
  final String label, sublabel;
  final double value, maxValue;
  final Color color;
  final IconData icon;
  final SensorReading? reading;

  const _SensorRow({
    required this.label,
    required this.sublabel,
    required this.value,
    required this.maxValue,
    required this.color,
    required this.icon,
    required this.reading,
  });

  @override
  Widget build(BuildContext context) {
    final frac = (value / maxValue).clamp(0.0, 1.0);
    return Row(
      children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: context.txt,
                    ),
                  ),
                  const Spacer(),
                  if (reading != null)
                    Text(
                      '${value.toStringAsFixed(1)} m/s²',
                      style: TextStyle(fontSize: 11, color: color),
                    ),
                ],
              ),
              const SizedBox(height: 5),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: frac,
                  minHeight: 4,
                  backgroundColor: context.card2,
                  valueColor: AlwaysStoppedAnimation(color),
                ),
              ),
              Text(
                sublabel,
                style: TextStyle(fontSize: 10, color: context.txtDim),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── FOG Alert Banner ─────────────────────────────────────────────────────────

class _FogAlertBanner extends StatelessWidget {
  final VoidCallback onDismiss;
  const _FogAlertBanner({required this.onDismiss});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              color: kRed,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: kRed.withOpacity(0.5),
                  blurRadius: 30,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.white,
                  size: 26,
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'FREEZING DETECTED',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: 1.5,
                        ),
                      ),
                      Text(
                        'Focus on your cue · Take a step',
                        style: TextStyle(fontSize: 12, color: Colors.white70),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: onDismiss,
                  child: const Icon(
                    Icons.close_rounded,
                    color: Colors.white70,
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
//  PAINTERS
// ════════════════════════════════════════════════════════════════════════════

class _WaveBgPainter extends CustomPainter {
  final double phase;
  final bool active;
  final double risk;

  _WaveBgPainter({
    required this.phase,
    required this.active,
    required this.risk,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (!active) return;
    final baseAlpha = 0.04 + risk * 0.06;
    final color = risk < 0.35
        ? kGreen
        : risk < 0.65
        ? kOrange
        : kRed;

    for (int w = 0; w < 2; w++) {
      final path = Path();
      final offset = w * pi;
      path.moveTo(0, size.height);
      for (double x = 0; x <= size.width; x += 3) {
        final y =
            size.height * 0.75 +
            sin(x * 0.012 + phase + offset) * 22 +
            sin(x * 0.025 + phase * 1.4) * 12;
        if (x == 0) {
          path.lineTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }
      path.lineTo(size.width, size.height);
      path.close();

      canvas.drawPath(
        path,
        Paint()
          ..color = color.withOpacity(baseAlpha - w * 0.015)
          ..style = PaintingStyle.fill,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _WaveBgPainter old) =>
      old.phase != phase || old.risk != risk;
}

class _RinggPainter extends CustomPainter {
  final double value;
  final Color color;
  final bool active;
  final Color trackColor;

  _RinggPainter({
    required this.value,
    required this.color,
    required this.active,
    required this.trackColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 10;
    const startAngle = -pi * 0.75;
    const sweepTotal = pi * 1.5;

    // Track
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepTotal,
      false,
      Paint()
        ..strokeWidth = 14
        ..style = PaintingStyle.stroke
        ..color = trackColor
        ..strokeCap = StrokeCap.round,
    );

    if (value <= 0) return;

    // Value arc
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepTotal * value,
      false,
      Paint()
        ..strokeWidth = 14
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..shader = SweepGradient(
          startAngle: startAngle,
          endAngle: startAngle + sweepTotal,
          colors: [kGreen, kOrange, kRed],
          stops: const [0.0, 0.5, 1.0],
          transform: GradientRotation(startAngle),
        ).createShader(Rect.fromCircle(center: center, radius: radius)),
    );
  }

  @override
  bool shouldRepaint(covariant _RinggPainter old) =>
      old.value != value || old.color != color;
}

class FallRiskScreen extends StatefulWidget {
  const FallRiskScreen({Key? key}) : super(key: key);
  @override
  _FallRiskScreenState createState() => _FallRiskScreenState();
}

class _FallRiskScreenState extends State<FallRiskScreen>
    with TickerProviderStateMixin {
  // ── State ──────────────────────────────────────────────────────────────────
  final Map<String, double> _values = {};
  bool _isLoading = false;
  double _risk = 0.0;
  String _riskLabel = '---';
  Color _riskColor = kPrimary;
  bool _hasResult = false;
  late List<String> selectionKeys;

  final _ageCtrl = TextEditingController();
  final _bmiCtrl = TextEditingController();
  final _medsCtrl = TextEditingController();

  late AnimationController _pulseCtrl;
  late AnimationController _resultCtrl;
  late Animation<double> _pulseAnim;
  late Animation<double> _resultAnim;
  late Animation<double> _progressAnim;

  // Model feature order — must NOT be changed
  static final _fieldKeys = [
    'Age',
    'BMI',
    'History_of_Falls',
    'Secondary_Diagnosis',
    'Ambulatory_Aid',
    'IV_Therapy',
    'Gait_Status',
    'Mental_Status',
    'Vision_Impairment',
    'Osteoporosis',
    'Medications_Count',
  ];

  // ── Lifecycle ──────────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();

    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    _pulseAnim = Tween(
      begin: 0.92,
      end: 1.08,
    ).animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));

    _resultCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _resultAnim = CurvedAnimation(
      parent: _resultCtrl,
      curve: Curves.easeOutBack,
    );
    _progressAnim = Tween<double>(begin: 0, end: 0).animate(_resultCtrl);
  }

  @override
  void dispose() {
    _ageCtrl.dispose();
    _bmiCtrl.dispose();
    _medsCtrl.dispose();
    _pulseCtrl.dispose();
    _resultCtrl.dispose();
    super.dispose();
  }

  // ── Validation ─────────────────────────────────────────────────────────────
  bool _isFormComplete() {
    if ((_values['Age'] ?? -1) < 0) return false;
    if ((_values['BMI'] ?? -1) < 0) return false;
    if ((_values['Medications_Count'] ?? -1) < 0) return false;

    const selectionKeys = [
      'History_of_Falls',
      'Secondary_Diagnosis',
      'Ambulatory_Aid',
      'IV_Therapy',
      'Gait_Status',
      'Mental_Status',
      'Vision_Impairment',
      'Osteoporosis',
    ];
    for (final k in selectionKeys) {
      if (!_values.containsKey(k)) return false;
    }
    return true;
  }

  // ── Prediction ─────────────────────────────────────────────────────────────
  Future<void> _calculateRisk() async {
    _values['Age'] = double.tryParse(_ageCtrl.text) ?? -1;
    _values['BMI'] = double.tryParse(_bmiCtrl.text) ?? -1;
    _values['Medications_Count'] = double.tryParse(_medsCtrl.text) ?? -1;

    if (!_isFormComplete()) {
      _showSnack('Please complete all fields before calculating.', kOrange);
      return;
    }

    final age = _values['Age']!;
    final bmi = _values['BMI']!;
    final meds = _values['Medications_Count']!;

    if (age < 0 || age > 120) {
      _showSnack('Age must be between 0 and 120', kRed);
      return;
    }
    if (bmi < 10 || bmi > 50) {
      _showSnack('BMI must be between 10 and 50', kRed);
      return;
    }
    if (meds < 0 || meds > 20) {
      _showSnack('Medications count must be 0–20', kRed);
      return;
    }

    setState(() => _isLoading = true);
    _pulseCtrl.repeat(reverse: true);
    HapticFeedback.mediumImpact();

    try {
      final features = _fieldKeys.map((k) => _values[k]!).toList();

      String baseUrl;
      if (Platform.isAndroid) {
        baseUrl = 'http://172.20.10.3:5000';
      } else if (Platform.isIOS) {
        baseUrl = ' http://172.20.10.3:5000';
      } else {
        baseUrl = 'http://172.20.10.3:5000';
      }

      final api = FallRiskApi(baseUrl: baseUrl);
      final risk = await api.predictRisk(features);

      _progressAnim = Tween<double>(begin: 0, end: risk).animate(
        CurvedAnimation(parent: _resultCtrl, curve: Curves.easeOutCubic),
      );

      setState(() {
        _risk = risk;
        _riskLabel = risk < 0.3
            ? AppStrings.low
            : risk < 0.7
            ? AppStrings.moderate
            : AppStrings.high;
        _riskColor = risk < 0.3
            ? kGreen
            : risk < 0.7
            ? kOrange
            : kRed;
        _isLoading = false;
        _hasResult = true;
      });

      // ✅ أضف السطر ده هنا
      context.read<FallRiskProvider>().updateRisk(risk);

      _pulseCtrl.stop();
      _resultCtrl.forward(from: 0);
      HapticFeedback.heavyImpact();
    } catch (e) {
      setState(() => _isLoading = false);
      _pulseCtrl.stop();
      _showSnack('Error: ${e.toString()}', kRed);
    }
  }

  void _showSnack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: const TextStyle(fontWeight: FontWeight.w600)),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  // ── Build ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(child: _buildHeader()),
            SliverToBoxAdapter(child: const SizedBox(height: 24)),
            SliverToBoxAdapter(child: _buildResultCard()),
            SliverToBoxAdapter(child: const SizedBox(height: 28)),
            SliverToBoxAdapter(
              child: _buildSectionLabel(AppStrings.patientInfo),
            ),
            SliverToBoxAdapter(child: const SizedBox(height: 12)),
            SliverToBoxAdapter(child: _buildVitalsRow()),
            SliverToBoxAdapter(child: const SizedBox(height: 28)),
            SliverToBoxAdapter(
              child: _buildSectionLabel(AppStrings.clinicalHistory),
            ),
            SliverToBoxAdapter(child: const SizedBox(height: 12)),
            SliverToBoxAdapter(
              child: _buildBinaryCard(
                'History_of_Falls',
                Icons.history,
                AppStrings.historyOfFalls,
                AppStrings.hasThePatientFallenBefore,
                [AppStrings.no, AppStrings.yes],
              ),
            ),
            SliverToBoxAdapter(child: const SizedBox(height: 12)),
            SliverToBoxAdapter(
              child: _buildBinaryCard(
                'Secondary_Diagnosis',
                Icons.medical_information_outlined,
                AppStrings.secondaryDiagnosis,
                AppStrings.anySecondaryConditionPresent,
                [AppStrings.no, AppStrings.yes],
              ),
            ),
            SliverToBoxAdapter(child: const SizedBox(height: 12)),
            SliverToBoxAdapter(
              child: _buildBinaryCard(
                'IV_Therapy',
                Icons.vaccines_outlined,
                AppStrings.ivTherapy,
                AppStrings.isPatientReceivingIVTherapy,
                [AppStrings.no, AppStrings.yes],
              ),
            ),
            SliverToBoxAdapter(child: const SizedBox(height: 28)),
            SliverToBoxAdapter(
              child: _buildSectionLabel(AppStrings.functionalStatus),
            ),
            SliverToBoxAdapter(child: const SizedBox(height: 12)),
            SliverToBoxAdapter(
              child: _buildTriCard(
                'Ambulatory_Aid',
                Icons.accessible_rounded,
                AppStrings.ambulatoryAid,
                [AppStrings.none, AppStrings.cane, AppStrings.walker],
              ),
            ),
            SliverToBoxAdapter(child: const SizedBox(height: 12)),
            SliverToBoxAdapter(
              child: _buildTriCard(
                'Gait_Status',
                Icons.directions_walk_rounded,
                AppStrings.gaitStatus,
                [AppStrings.normal, AppStrings.abnormal, AppStrings.severe],
              ),
            ),
            SliverToBoxAdapter(child: const SizedBox(height: 28)),
            SliverToBoxAdapter(
              child: _buildSectionLabel(AppStrings.conditions),
            ),
            SliverToBoxAdapter(child: const SizedBox(height: 12)),
            SliverToBoxAdapter(
              child: _buildBinaryCard(
                'Mental_Status',
                Icons.psychology_outlined,
                AppStrings.mentalStatus,
                AppStrings.isCognitiveFunctionImpaired,
                [AppStrings.normal, AppStrings.impaired],
              ),
            ),
            SliverToBoxAdapter(child: const SizedBox(height: 12)),
            SliverToBoxAdapter(
              child: _buildBinaryCard(
                'Vision_Impairment',
                Icons.visibility_outlined,
                AppStrings.visionImpairment,
                AppStrings.doesThePatientHaveVisionIssues,
                [AppStrings.no, AppStrings.yes],
              ),
            ),
            SliverToBoxAdapter(child: const SizedBox(height: 12)),
            SliverToBoxAdapter(
              child: _buildBinaryCard(
                'Osteoporosis',
                Icons.accessibility_new_outlined,
                AppStrings.osteoporosis,
                AppStrings.hasOsteoporosisBeenDiagnosed,
                [AppStrings.no, AppStrings.yes],
              ),
            ),
            SliverToBoxAdapter(child: const SizedBox(height: 28)),
            SliverToBoxAdapter(child: _buildMedicationsCard()),
            SliverToBoxAdapter(child: const SizedBox(height: 32)),
            SliverToBoxAdapter(child: _buildCalculateButton()),
            SliverToBoxAdapter(child: const SizedBox(height: 52)),
          ],
        ),
      ),
    );
  }

  // ── Header ─────────────────────────────────────────────────────────────────
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [kPrimary, kAccent],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: kPrimary.withOpacity(0.35),
                  blurRadius: 14,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: const Icon(
              Icons.health_and_safety,
              color: Colors.white,
              size: 26,
            ),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppStrings.fallRiskAssessment,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: context.txt,
                  letterSpacing: 0.4,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                AppStrings.morseScaleDescription,
                style: TextStyle(
                  fontSize: 11.5,
                  color: context.txtDim,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Result Card ────────────────────────────────────────────────────────────
  Widget _buildResultCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: AnimatedBuilder(
        animation: _pulseAnim,
        builder: (_, __) => Transform.scale(
          scale: _isLoading ? _pulseAnim.value : 1.0,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: _hasResult
                    ? [
                        _riskColor.withOpacity(0.08),
                        _riskColor.withOpacity(0.02),
                      ]
                    : [context.surface, context.card2],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: _hasResult
                    ? _riskColor.withOpacity(0.3)
                    : context.border,
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: (_hasResult ? _riskColor : kPrimary).withOpacity(0.08),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: _hasResult
                ? _buildResultContent()
                : _buildPlaceholderContent(),
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholderContent() {
    return Row(
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: context.border, width: 3),
            color: context.card2,
          ),
          child: Center(
            child: Text(
              '—',
              style: TextStyle(
                fontSize: 24,
                color: context.txtDim,
                fontWeight: FontWeight.w300,
              ),
            ),
          ),
        ),
        const SizedBox(width: 18),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppStrings.noassessmentyet,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: context.txt,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                AppStrings.fillInAllFieldsAndTapCalculateRiskToSeeResults,
                style: TextStyle(
                  fontSize: 12.5,
                  color: context.txtDim,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildResultContent() {
    return AnimatedBuilder(
      animation: _resultAnim,
      builder: (_, __) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SizedBox(
                width: 80,
                height: 80,
                child: AnimatedBuilder(
                  animation: _progressAnim,
                  builder: (_, __) => Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 80,
                        height: 80,
                        child: CircularProgressIndicator(
                          value: _progressAnim.value,
                          strokeWidth: 8,
                          backgroundColor: _riskColor.withOpacity(0.15),
                          valueColor: AlwaysStoppedAnimation<Color>(_riskColor),
                        ),
                      ),
                      Text(
                        '${(_progressAnim.value * 100).toInt()}%',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: _riskColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ScaleTransition(
                      scale: _resultAnim,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: _riskColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(
                            color: _riskColor.withOpacity(0.35),
                          ),
                        ),
                        child: Text(
                          _riskLabel.toUpperCase(),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: _riskColor,
                            letterSpacing: 1.4,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _risk < 0.3
                          ? 'Standard precautions are sufficient.'
                          : _risk < 0.7
                          ? 'Implement fall prevention protocol.'
                          : 'Immediate high-risk interventions required.',
                      style: TextStyle(
                        fontSize: 12.5,
                        color: context.txtDim,
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          AnimatedBuilder(
            animation: _progressAnim,
            builder: (_, __) => ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: _progressAnim.value,
                minHeight: 6,
                backgroundColor: _riskColor.withOpacity(0.12),
                valueColor: AlwaysStoppedAnimation<Color>(_riskColor),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Section Label ──────────────────────────────────────────────────────────
  Widget _buildSectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 16,
            decoration: BoxDecoration(
              color: kPrimary,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            label.toUpperCase(),
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: kPrimary,
              letterSpacing: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  // ── Vitals Row ─────────────────────────────────────────────────────────────
  Widget _buildVitalsRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: _buildNumericInput(
              _ageCtrl,
              AppStrings.age,
              AppStrings.years,
              Icons.cake_outlined,
              '18–120',
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildNumericInput(
              _bmiCtrl,
              AppStrings.bmi,
              'kg/m²',
              Icons.monitor_weight_outlined,
              '10–50',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNumericInput(
    TextEditingController ctrl,
    String label,
    String unit,
    IconData icon,
    String hint,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: context.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: context.border),
        boxShadow: [
          BoxShadow(
            color: kPrimary.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: kPrimary),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: context.txt,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          TextField(
            controller: ctrl,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
            ],
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: context.txt,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(
                fontSize: 14,
                color: context.txtDim.withOpacity(0.5),
                fontWeight: FontWeight.w400,
              ),
              suffix: Text(
                unit,
                style: TextStyle(fontSize: 11, color: context.txtDim),
              ),
              border: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ],
      ),
    );
  }

  // ── Binary Card ────────────────────────────────────────────────────────────
  Widget _buildBinaryCard(
    String key,
    IconData icon,
    String title,
    String subtitle,
    List<String> options,
  ) {
    final selected = _values[key];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: context.card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: context.border),
          boxShadow: [
            BoxShadow(
              color: kPrimary.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: kPrimary.withOpacity(0.10),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, size: 16, color: kPrimary),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          color: context.txt,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: TextStyle(fontSize: 11, color: context.txtDim),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: List.generate(options.length, (i) {
                final isSelected = selected == i.toDouble();
                // First option = "safe/no" → green; second = "risk/yes" → red
                final chipColor = i == 0 ? kGreen : kRed;
                return Expanded(
                  child: GestureDetector(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() => _values[key] = i.toDouble());
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      curve: Curves.easeInOut,
                      margin: EdgeInsets.only(
                        right: i < options.length - 1 ? 8 : 0,
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 11),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? chipColor.withOpacity(0.15)
                            : context.card2,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isSelected
                              ? chipColor.withOpacity(0.6)
                              : context.border,
                          width: isSelected ? 1.5 : 1,
                        ),
                      ),
                      child: Center(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 200),
                              child: isSelected
                                  ? Icon(
                                      Icons.check_circle_rounded,
                                      size: 15,
                                      color: chipColor,
                                      key: ValueKey('c$i'),
                                    )
                                  : Icon(
                                      Icons.radio_button_unchecked,
                                      size: 15,
                                      color: context.txtDim,
                                      key: ValueKey('u$i'),
                                    ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              options[i],
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: isSelected
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                                color: isSelected ? chipColor : context.txtDim,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  // ── Triple Card ────────────────────────────────────────────────────────────
  Widget _buildTriCard(
    String key,
    IconData icon,
    String title,
    List<String> options,
  ) {
    final selected = _values[key];
    const colors = [kGreen, kOrange, kRed];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: context.card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: context.border),
          boxShadow: [
            BoxShadow(
              color: kPrimary.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: kPrimary.withOpacity(0.10),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, size: 16, color: kPrimary),
                ),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: context.txt,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: List.generate(3, (i) {
                final isSelected = selected == i.toDouble();
                final c = colors[i];
                return Expanded(
                  child: GestureDetector(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() => _values[key] = i.toDouble());
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      curve: Curves.easeInOut,
                      margin: EdgeInsets.only(right: i < 2 ? 8 : 0),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected ? c.withOpacity(0.15) : context.card2,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isSelected
                              ? c.withOpacity(0.6)
                              : context.border,
                          width: isSelected ? 1.5 : 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 200),
                            child: isSelected
                                ? Icon(
                                    Icons.check_circle_rounded,
                                    size: 18,
                                    color: c,
                                    key: ValueKey('s$i'),
                                  )
                                : Icon(
                                    Icons.circle_outlined,
                                    size: 18,
                                    color: context.txtDim.withOpacity(0.4),
                                    key: ValueKey('u$i'),
                                  ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            options[i],
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: isSelected
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              color: isSelected ? c : context.txtDim,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  // ── Medications Stepper ────────────────────────────────────────────────────
  Widget _buildMedicationsCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: context.card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: context.border),
          boxShadow: [
            BoxShadow(
              color: kPrimary.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: kPrimary.withOpacity(0.10),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.medication_outlined,
                    size: 16,
                    color: kPrimary,
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.medicationsCount,
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: context.txt,
                      ),
                    ),
                    Text(
                      AppStrings.totalNumberOfCurrentMedications,
                      style: TextStyle(fontSize: 11, color: context.txtDim),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _stepBtn(Icons.remove_rounded, () {
                  final cur = int.tryParse(_medsCtrl.text) ?? 0;
                  if (cur > 0) {
                    setState(() => _medsCtrl.text = (cur - 1).toString());
                  }
                }),
                Expanded(
                  child: Center(
                    child: TextField(
                      controller: _medsCtrl,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: context.txt,
                      ),
                      decoration: InputDecoration(
                        hintText: '0',
                        hintStyle: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w300,
                          color: context.txtDim.withOpacity(0.4),
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                        isDense: true,
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                ),
                _stepBtn(Icons.add_rounded, () {
                  final cur = int.tryParse(_medsCtrl.text) ?? 0;
                  if (cur < 20) {
                    setState(() => _medsCtrl.text = (cur + 1).toString());
                  }
                }),
              ],
            ),
            const SizedBox(height: 12),
            Builder(
              builder: (_) {
                final val =
                    (int.tryParse(_medsCtrl.text) ?? 0).clamp(0, 20) / 20.0;
                final barColor = val < 0.3
                    ? kGreen
                    : val < 0.7
                    ? kOrange
                    : kRed;
                return ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: val,
                    minHeight: 5,
                    backgroundColor: barColor.withOpacity(0.12),
                    valueColor: AlwaysStoppedAnimation<Color>(barColor),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _stepBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: context.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: context.border),
        ),
        child: Icon(icon, size: 20, color: kPrimary),
      ),
    );
  }

  // ── Calculate Button ───────────────────────────────────────────────────────
  Widget _buildCalculateButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GestureDetector(
        onTap: _isLoading ? null : _calculateRisk,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 58,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [kPrimary, kAccent],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: kPrimary.withOpacity(0.4),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Center(
            child: _isLoading
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(width: 12),
                      Text(
                        AppStrings.calculateing,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.auto_awesome_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                      SizedBox(width: 10),
                      Text(
                        AppStrings.calculateRisk,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

// fall_risk_provider.dart

class FallRiskProvider extends ChangeNotifier {
  double? _risk;
  String _riskLabel = '---';
  Color _riskColor = kPrimary; // نفس الـ kPrimary بتاعك

  double? get risk => _risk;
  String get riskLabel => _riskLabel;
  Color get riskColor => _riskColor;
  bool get hasResult => _risk != null;

  void updateRisk(double risk) {
    _risk = risk;
    _riskLabel = risk < 0.3
        ? AppStrings.lowrisk
        : risk < 0.7
        ? AppStrings.moderaterisk
        : AppStrings.highRisk;
    _riskColor = risk < 0.3
        ? kGreen
        : risk < 0.7
        ? kOrange
        : kRed;
    notifyListeners();
  }
}

class ThemeProvider extends ChangeNotifier {
  bool _isDark = false;
  bool get isDark => _isDark;

  void toggle(bool val) {
    _isDark = val;
    notifyListeners();
  }
}
