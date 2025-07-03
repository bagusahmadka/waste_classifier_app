# ♻️ Waste Classifier App

A Flutter-based mobile application that classifies types of waste using a custom-trained AI model. This app is designed to support sustainable waste management by helping users identify recyclable materials through image recognition.

## 📱 Features

- 🧠 Image classification using TensorFlow Lite
- 📸 Camera integration for real-time photo capture
- 🖼️ Option to classify waste from gallery images
- 📊 Confidence score display for predictions
- 💡 Educational purpose to promote eco-awareness
- 🌐 Works offline once the model is bundled

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (latest stable)
- Android Studio / VSCode / Xcode (for iOS)
- Physical or virtual device with camera support

### Installation

```bash
git clone https://github.com/bagusahmadka/waste_classifier_app.git
cd waste_classifier_app
flutter pub get
flutter run

🧠 AI Model
This app uses a custom-trained TensorFlow Lite model to classify different types of waste. The model is stored in the assets/model/ folder and was trained using the TrashNet Dataset.

The model classifies the following categories:

Cardboard

Glass

Metal

Paper

Plastic

Trash (other)

📚 Dataset & Reference
This app’s AI model was trained using the TrashNet Dataset available on the TU Wien Research Data Repository:

Dataset Title: TrashNet Dataset for Waste Classification
Authors: Hendrik Göbel, Martin Hepp
Publisher: TU Wien Research Data Repository
DOI: 10.34726/2736
Dataset URL: https://researchdata.tuwien.ac.at/records/27k90-dvw73

