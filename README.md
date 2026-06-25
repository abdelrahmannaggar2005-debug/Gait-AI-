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

### 2. GaitAnalyzer

Computer Vision pipeline that extracts gait metrics directly from walking videos.

Techniques:

* Optical Flow
* Background Subtraction
* Motion Tracking
* Feature Engineering

### 3. FOG Detection Model

Deep Learning model for detecting Freezing of Gait episodes.

Framework:

* TensorFlow / Keras

### 4. Gait Anomaly Localization

Explainable AI module based on:

* LSTM Autoencoder
* AnoGAN

Used for identifying abnormal gait behavior and affected body regions.

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
