# 🐾 PawSense: Smart IoT Pet Care
**Bridging the gap between pets and owners through intelligent monitoring.**

[![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=flat&logo=Flutter&logoColor=white)](https://flutter.dev)
[![Firebase](https://img.shields.io/badge/Firebase-039BE5?style=flat&logo=Firebase&logoColor=white)](https://firebase.google.com)
[![Hardware](https://img.shields.io/badge/Hardware-ESP32-E7352C.svg?style=flat)](https://www.espressif.com/)

## 📖 Overview
**PawSense** is an integrated IoT and mobile solution designed to streamline remote pet monitoring. By combining **Machine Learning-driven sound classification** with automated hardware, the system ensures proactive pet wellbeing. 

Whether you're at the office or traveling, PawSense listens for distress and provides the tools to care for your pet from anywhere in the world.

---

## ✨ Key Features
* **🔊 Acoustic Distress Detection:** Real-time ML sound analysis to identify barking, whimpering, or specific distress signals.
* **🥣 Remote Resource Management:** Manually trigger or schedule food and water dispensing via integrated **ESP32-controlled servos**.
* **🔔 Instant Push Notifications:** Receive immediate mobile alerts the moment unusual activity or distress is detected.
* **📊 Activity Dashboard:** A centralized interface to monitor environmental factors, hydration levels, and feeding history.
* **🔐 Secure Ecosystem:** Private user accounts via Firebase Authentication to ensure only you control your home’s IoT devices.

---

## 🛠️ Tech Stack
| Component | Technology | Use Case |
| :--- | :--- | :--- |
| **Mobile App** | Flutter & Dart | Cross-platform UI/UX |
| **Microcontroller** | ESP32 | Hardware control & Sensor data |
| **Backend/DB** | Firebase | Real-time DB & Cloud Messaging |
| **ML Engine** | TensorFlow Lite | Edge-based sound classification |

---

## 🚀 Getting Started

### 📱 Mobile App Setup
1. **Clone the Repository:**
   ```bash
   git clone [https://github.com/your-username/pawsense.git](https://github.com/your-username/pawsense.git)
   cd pawsense
