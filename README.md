<<<<<<< HEAD
# 🐾 PawSense: Smart IoT Pet Care
**Bridging the gap between pets and owners through intelligent monitoring.**

[![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=flat&logo=Flutter&logoColor=white)](https://flutter.dev)
[![Firebase](https://img.shields.io/badge/Firebase-039BE5?style=flat&logo=Firebase&logoColor=white)](https://firebase.google.com)
[![Hardware](https://img.shields.io/badge/Hardware-ESP32-E7352C.svg?style=flat)](https://www.espressif.com/)

## 📖 Overview
**PawSense** is an integrated IoT and mobile solution designed to streamline remote pet monitoring. By combining **Machine Learning-driven sound classification** with automated hardware, the system ensures proactive pet wellbeing. 

Whether you're at the office or traveling, PawSense listens for distress and provides the tools to care for your pet from anywhere in the world.


## ✨ Key Features
* **🔊 Acoustic Distress Detection:** Real-time ML sound analysis to identify barking, whimpering, or specific distress signals.
* **🥣 Remote Resource Management:** Manually trigger or schedule food and water dispensing via integrated **ESP32-controlled servos**.
* **🔔 Instant Push Notifications:** Receive immediate mobile alerts the moment unusual activity or distress is detected.
* **📊 Activity Dashboard:** A centralized interface to monitor environmental factors, hydration levels, and feeding history.
* **🔐 Secure Ecosystem:** Private user accounts via Firebase Authentication to ensure only you control your home’s IoT devices.


## 🛠️ Tech Stack
| Component | Technology | Use Case |
| :--- | :--- | :--- |
| **Mobile App** | Flutter & Dart | Cross-platform UI/UX |
| **Microcontroller** | ESP32 | Hardware control & Sensor data |
| **Backend/DB** | Firebase | Real-time DB & Cloud Messaging |
| **ML Engine** | TensorFlow Lite | Edge-based sound classification |


## 🚀 Getting Started

### 📋 Prerequisites

* Flutter SDK installed
* Arduino IDE (for ESP32)
* Firebase Project

### 📱 Mobile App Setup (Flutter)

1. **Clone the Repo:**
   `git clone (https://github.com/Alttabs25/PawSense---IoT-Enabled-Pet-Care-Monitoring-System-)

2. **Install Deps:**
   `flutter pub get`

3. **Firebase Config:**
   Put `google-services.json` in `android/app/`.

4. **Run:**
   `flutter run`


### ⚙️ IoT Hardware Setup (ESP32)

1. **Libraries:** Install `Firebase ESP32 Client` in Arduino IDE.

2. **Flash:** Open `pawsense_iot.ino`, enter WiFi/Firebase credentials, and upload to ESP32.


## 🏗️ System Architecture

**The Workflow:**
ESP32 captures audio -> ML classifies sound -> Data sent to Firebase -> Flutter App receives update and notifies user.


## 🤝 Contributors

* **RC Pinca** - rcpinca.it@tip.edu.ph
* **Justine Bryan A. Nabuya** - qjbanabuya@tip.edu.ph
* **Marion Jay M. Basilio** - qmjmbasilio@tip.edu.ph
* **Arfred S. Salonga** - qassalonga@tip.edu.ph
* **Lemuel V. Tapac** - qlmvtapac@tip.edu.ph 
=======
# pawsense

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:


For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
>>>>>>> d40ad6b (Pawsense App)
# PawSense: Smart IoT Pet Care Monitoring System

PawSense is a Flutter + Firebase app for monitoring and caring for pets remotely. It provides pet status, feeding controls, activity logs, and Firebase-backed user profiles.

## Features

- Firebase authentication
- Firestore-backed user and pet profile data
- Feed Now flow with food and water actions
- Home dashboard with pet status, bark count, food level, and water level cards
- Multi-platform Flutter support

## Firebase

This project is configured for the Firebase project `pawsense-8e8a3`.

See [FIREBASE_SETUP.md](FIREBASE_SETUP.md) for the setup notes and deployment details.

## Run Locally

```bash
flutter pub get
flutter run
```

## Web Deployment

The app can be built and deployed to Firebase Hosting with:

```bash
flutter build web
firebase deploy --only hosting,firestore:rules,firestore:indexes
```
