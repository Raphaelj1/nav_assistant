# Smart Navigation Assistant for Visually Impaired Individuals

A mobile-based assistive system that uses deep learning and on-device AI to help visually impaired users understand their surroundings in real time through object detection, depth estimation, and voice interaction.

The system is designed with an offline-first approach and runs core perception tasks directly on-device using optimized models.

---

## 🚀 Key Features

- Real-time object detection using YOLOv8n segmentation (TFLite)
- Depth estimation using MiDaS (TFLite)
- Structured object perception with bounding boxes and segmentation masks
- Offline voice control (wake word + speech-to-intent)
- Calibration system for improved depth accuracy
- Modular AI pipeline architecture
- Fully offline-capable core inference system

---

## 🧠 System Architecture

The system is built using a modular pipeline architecture:

```
Input Layer
├── Camera Feed (CameraService)
├── Voice Input (Wake Word + Speech-to-Intent)
↓

Perception Layer
├── Object Perception Module
│ ├── YOLOv8 Segmentation
│ ├── Bounding Box + Mask Generation
│
├── Depth Estimation Module
│ ├── MiDaS Model Inference
│ ├── Calibration-based scaling
↓

Decision Layer
├── MainController
├── PipelineController
↓

Output Layer
├── Voice feedback system
├── Audio alerts
├── UI state updates
```

---

## 🏗️ Project Structure

```
lib/
├── app/ # App configuration and routing
├── constants/ # App-wide constants and config
├── core/ # Core model manager and system logic
├── models/ # Shared data models
│
├── modules/ # AI and system modules
│ ├── depth_estimation/
│ ├── object_perception/
│ ├── scene_recognition/ (experimental / not fully implemented)
│ ├── voice_control/
│ └── feedback/
│
├── screens/ # UI screens and controllers
│ ├── welcome/
│ ├── calibration/
│ ├── main_ui/
│ └── settings/
│
├── services/ # Device-level services
├── storage/ # Local persistence (calibration + preferences)
├── utils/ # Image processing and helpers
└── main.dart
```

---

## ⚙️ How It Works

1. Camera feed is captured through `CameraService`
2. YOLOv8 segmentation detects and classifies objects
3. MiDaS estimates depth for spatial understanding
4. Calibration data adjusts raw depth values
5. `PipelineController` manages the sequential orchestration of camera, perception, and feedback
6. `MainController` triggers pipeline actions via voice or gestures.
7. Voice + audio feedback is generated for the user

---

## 🎯 Core Modules

### 🟢 Object Perception

Handles:

- YOLOv8n segmentation inference
- Bounding box extraction
- Object classification
- Mask generation

Located in:
`lib/modules/object_perception/`

---

### 🔵 Depth Estimation

Handles:

- MiDaS model inference
- Calibration-based scaling
- Object distance estimation

Located in:
`lib/modules/depth_estimation/`

---

### 🟣 Voice Control

Handles:

- Wake word detection
- Speech-to-intent parsing
- Command routing

Located in:
`lib/modules/voice_control/`

---

### ⚪ Scene Recognition (Experimental)

Module exists but is not fully implemented.

Currently reserved for future environmental classification features.

---

## 🧩 Design Principles

- Offline-first execution
- Modular AI pipeline design
- Separation of perception, fusion, and decision layers
- Lightweight mobile inference using TFLite
- Scalable controller-based architecture

---

## 📱 Platform

- Flutter (Android + cross-platform support)
- TensorFlow Lite for inference
- Fully offline-capable system

---

## ⚠️ Limitations

- Scene recognition module is not implemented yet
- Depth estimation is relative, not absolute
- Performance depends on device hardware capabilities
- Real-time inference may vary on low-end devices

---

## 📌 Future Improvements

- Complete scene recognition module
- Improve multi-object tracking
- Sensor fusion (camera + IMU)
- Path prediction for navigation assistance
- Haptic feedback integration
- Model optimization for faster inference

---

## 👨‍💻 Author

Final Year Computer Science Project focused on assistive AI systems, edge computing, and real-time perception pipelines.

---

## 📜 License

For academic and research use only.
