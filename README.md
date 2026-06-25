# Gait-AI-

# 🚶‍♂️ GaitAI – AI-Powered Intelligent Gait Analysis & Fall Risk Assessment

## Overview

GaitAI is an AI-powered healthcare platform that transforms a smartphone into an intelligent gait analysis system capable of:

* Fall Risk Assessment
* Gait Pattern Analysis
* Freezing of Gait (FOG) Detection
* Gait Anomaly Localization
* Longitudinal Mobility Monitoring

The system combines Computer Vision, Machine Learning, Deep Learning, Mobile Development, and Cloud Computing to provide accessible gait analysis without requiring expensive clinical equipment.

---

## Problem Statement

Traditional gait analysis systems rely on specialized laboratories, motion capture systems, and wearable sensors that are costly and inaccessible for continuous monitoring.

GaitAI addresses this challenge by enabling users to perform gait assessments directly from smartphone-recorded videos.

---

## Key Features

### AI-Powered Gait Analysis

Extracts critical gait metrics including:

* Stride Length
* Cadence
* Walking Speed
* Symmetry Score
* Knee Angle
* Hip Angle
* Composite Risk Score

### Fall Risk Prediction

Clinical risk assessment using machine learning models trained on patient demographic and medical features.

### Freezing of Gait Detection

Deep learning model designed to identify FOG episodes commonly associated with Parkinson's Disease.

### Explainable Gait Anomaly Detection

Detects and localizes abnormal gait behavior using:

* LSTM Autoencoder
* AnoGAN Architecture

Providing both temporal and spatial explanations of gait abnormalities.

### Mobile Healthcare Platform

* Android Support
* iOS Support
* Secure Authentication
* Analysis History Tracking
* Cloud Storage Integration

---

## System Architecture

Mobile Application (Flutter)

↓

Firebase Authentication & Storage

↓

Flask Backend APIs

↓

AI Processing Engine

↓

Analysis Results & Reports

---

## Technology Stack

### Mobile Development

* Flutter
* Dart

<img width="326" height="729" alt="image" src="https://github.com/user-attachments/assets/feae26df-c94b-415f-9180-74c7dad5edae" /> <img width="345" height="733" alt="image" src="https://github.com/user-attachments/assets/12fe81cd-73f2-4825-94cb-839c27d36c1f" /> <img width="322" height="738" alt="image" src="https://github.com/user-attachments/assets/e99f1b04-c9b0-422d-992c-bc4f117565e8" /> <img width="338" height="732" alt="image" src="https://github.com/user-attachments/assets/6b6fc265-b2fb-41a8-a7f9-2b2a6d48b613" /> <img width="333" height="727" alt="image" src="https://github.com/user-attachments/assets/0ecd689d-2d0a-49c2-977d-651eeb6af204" /> <img width="330" height="729" alt="image" src="https://github.com/user-attachments/assets/38ddc287-ee9c-415b-a485-1aff3788978f" /> <img width="335" height="734" alt="image" src="https://github.com/user-attachments/assets/f4324777-4c95-4c4b-a75d-2365f423f6c8" />





### Backend

* Flask
* REST APIs

### Cloud Services

* Firebase Authentication
* Cloud Firestore
* Firebase Storage

### AI & Machine Learning

* Python
* OpenCV
* TensorFlow
* Keras
* Scikit-Learn
* MediaPipe

### Deep Learning Models

* HistGradientBoostingClassifier
* FOG Detection Network
* LSTM Autoencoder
* AnoGAN

---

## AI Models

### 1. Fall Risk Prediction Model

Predicts patient fall risk using demographic and clinical features.

**Model:** HistGradientBoostingClassifier

**Performance:**

* 94% Accuracy
* 100% Recall for High-Risk Cases
<img width="351" height="719" alt="image" src="https://github.com/user-attachments/assets/d8f93097-94d0-45d9-a482-c788c0f77e69" />


### 2. GaitAnalyzer

Computer Vision pipeline that extracts gait metrics directly from walking videos.

Techniques:

* Optical Flow
* Background Subtraction
* Motion Tracking
* Feature Engineering
<img width="330" height="731" alt="image" src="https://github.com/user-attachments/assets/1c2f9910-e257-4b38-b4e1-8dfdd39d20bc" />

### 3. FOG Detection Model

Deep Learning model for detecting Freezing of Gait episodes.

Framework:

* TensorFlow / Keras
<img width="335" height="728" alt="image" src="https://github.com/user-attachments/assets/d85a81b3-9330-4375-b08a-ba16665159e5" />

### 4. Gait Anomaly Localization

Explainable AI module based on:

* LSTM Autoencoder
* AnoGAN

Used for identifying abnormal gait behavior and affected body regions.
<img width="340" height="648" alt="image" src="https://github.com/user-attachments/assets/7ceb75fe-2d63-4ea0-84b8-1d226c6f4e81" />

---

## Challenges Solved

* Heavy AI computation on mobile devices
* Video processing latency
* Model deployment and integration
* Real-time analysis requirements
* Secure healthcare data management

---

## Future Improvements

* 3D Pose Estimation
* Clinical Dataset Expansion
* Real-Time Feedback System
* Healthcare Professional Dashboard
* Remote Patient Monitoring

---

## Impact

GaitAI demonstrates how Artificial Intelligence can be integrated with mobile healthcare systems to deliver affordable, scalable, and accessible mobility assessment solutions.

The platform aims to support older adults, Parkinson's patients, rehabilitation programs, and healthcare professionals through continuous gait monitoring and early risk detection.

---

## Contributors

* Abdelrahman Ahmed Mahmoud
* Mohammed Ashraf Sallal
* Yomna Ahmed Omar
* Maryam Torayem Hilmy
* Nadia Hesham Shalan
* Raneem Mohammed Magdy

Faculty of Artificial Intelligence
Delta University for Science & Technology
