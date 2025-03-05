# Reel AI

This project was created in 2 weeks as part of the GauntletAI program.

A modern AI-powered video creation, editing, and translation platform built with Flutter and Firebase.

## Features

### 📹 Advanced Video Recording
- **High-Quality Camera Integration**: Capture professional-grade videos directly within the app
- **Real-time Recording Controls**: Intuitive interface for recording with visual feedback
- **Permission Handling**: Seamless camera and microphone permission management

### 🎬 Powerful Video Editing
- **Video Trimming & Cutting**: Precisely edit your video content
- **Filter Application**: Apply various visual filters to enhance your videos
- **Subtitle Generation**: AI-powered subtitle creation and customization
- **Multi-language Support**: Generate and display subtitles in multiple languages

### 🤖 AI-Enhanced Capabilities
- **Automated Processing**: Background processing of videos for various AI enhancements
- **Smart Content Analysis**: AI-powered analysis of video content
- **Metadata Generation**: Automatic generation of relevant video metadata

### 👤 User Authentication
- **Secure Login/Signup**: Firebase Authentication integration
- **User Profile Management**: Manage your account and preferences
- **Privacy Controls**: Control who can view your content

### 📱 Modern UI/UX
- **Synthwave-Inspired Design**: Visually appealing interface with modern aesthetics
- **Responsive Layout**: Works seamlessly across different device sizes
- **Intuitive Navigation**: Easy-to-use GoRouter navigation system

### 🔄 Content Management
- **Video Library**: Browse and manage your created videos
- **Upload Progress Tracking**: Real-time feedback on video uploads
- **Video Metadata Editing**: Customize titles, descriptions, and other metadata

## Technical Stack

### Frontend
- **Flutter**: Cross-platform UI framework
- **Dart**: Programming language
- **Riverpod**: State management
- **Freezed**: Immutable state models
- **Hooks**: Functional component patterns
- **GoRouter**: Navigation and routing

### Backend & Services
- **Firebase Authentication**: User management
- **Cloud Firestore**: NoSQL database
- **Firebase Storage**: Media storage
- **Cloud Functions**: Serverless backend logic

### Media Processing
- **Camera**: Native camera integration
- **Video Player**: Video playback capabilities
- **Chewie**: Enhanced video player controls
- **FFmpeg**: Video processing and manipulation

## Getting Started

### Prerequisites
- Flutter SDK (latest stable version)
- Dart SDK (^3.6.1)
- Firebase project setup
- Android Studio / VS Code with Flutter extensions

### Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/yourusername/reel_ai.git
   cd reel_ai
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Run the code generation for Freezed, Riverpod, and JSON serialization:
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```

4. Connect to your Firebase project:
   - Create a Firebase project in the Firebase Console
   - Configure Android/iOS apps in Firebase
   - Download and add the configuration files to your project

5. Run the app:
   ```bash
   flutter run
   ```

## Project Structure

```
reel_ai/
├─ lib/
│  ├─ common/           # Shared utilities, widgets, and services
│  │  ├─ constants/     # App-wide constants
│  │  ├─ router/        # Navigation configuration
│  │  ├─ services/      # Shared services
│  │  ├─ theme/         # App theming
│  │  ├─ utils/         # Utility functions
│  │  └─ widgets/       # Reusable widgets
│  ├─ features/         # Feature modules
│  │  ├─ auth/          # Authentication
│  │  ├─ camera/        # Video recording
│  │  ├─ home/          # Main screens
│  │  ├─ settings/      # User settings
│  │  └─ videos/        # Video management and editing
│  └─ main.dart         # App entry point
├─ assets/              # Static assets
├─ functions/           # Firebase Cloud Functions
└─ ...
```

## Acknowledgements

- [Flutter](https://flutter.dev/)
- [Firebase](https://firebase.google.com/)
- [Riverpod](https://riverpod.dev/)
- [GoRouter](https://pub.dev/packages/go_router)
- [Camera](https://pub.dev/packages/camera)
- [Video Player](https://pub.dev/packages/video_player)
- [Chewie](https://pub.dev/packages/chewie)
- [FFmpeg Kit Flutter](https://pub.dev/packages/ffmpeg_kit_flutter)
