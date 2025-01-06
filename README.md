# Flutter Firebase Project

## Overview
This is a **Flutter Firebase Project** that integrates Flutter for the frontend and Firebase for backend services like authentication, Firestore, and cloud functions. The project is built to be scalable and provides essential configurations for seamless development and deployment.

### Screenshots

<p align='center'>
  <img src="https://github.com/ShadhirFawz/Fuilio_App/blob/master/assets/Screenshots/Screenshot_20250106_123144.jpg" alt="Screenshot 1" width="200" />
  <img src="https://github.com/ShadhirFawz/Fuilio_App/blob/master/assets/Screenshots/Screenshot_20250106_162833.jpg" alt="Screenshot 2" width="200" />
  <img src="https://github.com/ShadhirFawz/Fuilio_App/blob/master/assets/Screenshots/Screenshot_20250106_123831.jpg" alt="Screenshot 3" width="200" />
  <img src="https://github.com/ShadhirFawz/Fuilio_App/blob/master/assets/Screenshots/Screenshot_20250106_162851.jpg" alt="Screenshot 4" width="200" />
  <img src="https://github.com/ShadhirFawz/Fuilio_App/blob/master/assets/Screenshots/Screenshot_20250106_164852.jpg" alt="Screenshot 5" width="200" />
</p>
  
---

## Table of Contents
1. [Features](#features)
2. [Requirements](#requirements)
3. [Installation](#installation)
4. [Firebase Configuration](#firebase-configuration)
5. [Running the Project](#running-the-project)
6. [Project Structure](#project-structure)
7. [Available Commands](#available-commands)
8. [Contributing](#contributing)

---

## Features
- Firebase Authentication
- Cloud Firestore integration
- Responsive design (Mobile)
- Exoense Tracking and Data Visualizations
- Refuel Tracking and Data Visualizations
- Password Encryption
- Multiple Vehicle Support
- Create, Read, Delete and Update basic functionalities

---

## Requirements
- **Flutter SDK**: Version `^3.24.6`
- **Dart SDK**: Version `^3.5.4`
- **Firebase CLI**: Version `^13.29.1`
- IDE (e.g., Android Studio, VS Code) with Flutter/Dart plugins
- A valid Firebase project set up

---

## Installation ✅

#Clone the Repository
```bash
git clone https://github.com/yourusername/flutter-firebase-project.git
cd flutter-firebase-project
```

#Install Dependencies
- Run the following command to fetch all dependencies:

```bash
flutter pub get
```
---

## Firebase Configuration
1. Create a Firebase project in the Firebase Console.
2. Enable the required services:
- Firestore Database
- Authentication
- Cloud Functions (if applicable)
3. Download the google-services.json file for Android and GoogleService-Info.plist for iOS:
- Place the google-services.json in the android/app directory.
- Place the GoogleService-Info.plist in the ios/Runner directory.
4. Update the firebase_options.dart file:
- Generate this file using the flutterfire configure command:
```bash
firebase login
flutterfire configure
```
---

## Running the Project
Run on Emulator or Physical Device
1. To build and run the app:
```bash
flutter run
```
2. To run on a specific platform (e.g., Android or iOS):
```bash
flutter run -d <platform>
```
Replace <platform> with android, ios, chrome, etc.

#Building the App
- Build APK:
```bash
flutter build apk --release
```
- Build for iOS:
```bash
flutter build ios --release
```

---

## Project Structure
```plaintext
lib/
├── models/               # Data models
├── services/             # Firebase and other services
├── screens/              # App screens/UI
├── widgets/              # Reusable components
└── main.dart             # App entry point
```

---

## Available Commands
Lint the Code
```bash
flutter analyze
```
Format the Code
```bash
flutter format .
```
Run Tests
```bash
flutter test
```
Clean Build Files
```bash
flutter clean
```

---
## Contributing
🚶 Contributions are welcome! To contribute:

#Fork the repository.
- Create a new branch for your feature:
```bash
git checkout -b feature-name
```
- Commit and push your changes:
```bash
git commit -m "Add new feature"
git push origin feature-name
```
