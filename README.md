# Wander Finds

An AI-powered personalized guide to help you discover hidden gems.


## Table of Contents

- [Introduction](#Introduction)
- [Getting Started](#getting-started)
- [How to Run the Application](#how-to-run-the-application)
- [Android Studio Setup](#android-studio-setup)
- [Location Services](#location-services)
- [Google Takeout Data](#google-takeout-data)
- [Backend Details](#back-end)
- [Team Members](#Team-Members)


## Introduction

Wander Finds is your personal AI guide that generates personalized recommendations based on your Google Maps data and interests. Once you provide Wander Finds with your preferences and Google Takeout uploads, it generates a profile description that you can update. When generating recommendations, Wander Finds takes into account your interests, profile, search queries, and even weather factors to tailor results to you. The top 12 results are chosen by Gemini to help narrow down your options. Wander Finds also acts as a personal AI tour guide, allowing you to easily look up a place’s context and information with a click. Our mobile app, developed with Flutter and Firebase, is available on both Android and iOS devices. Wander Finds is built with inclusivity, simplicity, and security in mind.


## Getting Started

This project is built using the Flutter framework. Follow the instructions below to set up the project on your local machine and get started.

## How to Run the Application

1. **Clone the Repository**: Start by cloning the project repository to your local machine using Git.

   ```bash
   git clone https://github.com/yianan261/GeminiFrontend.git
   ```
   
2. **Install Dependencies**: Ensure you have Flutter installed on your machine. Run the following command to install all required dependencies.
   ```bash
    flutter pub get
   ```
3. Run the Application: After setting up your environment (see the Android Studio Setup section below), you can run the application using the following command:
   ```bash
     flutter run
   ```
Alternatively, you can run the app directly from Android Studio by selecting the target device and clicking the Run button.

## Android Studio Setup

1. Install Android Studio: Download and install Android Studio.
2. Configure Flutter with Android Studio: Open Android Studio and go to File > Settings > Plugins. Search for 'Flutter' and 'Dart' plugins and install them.
3. Set Up Android Emulator: Go to AVD Manager in Android Studio, create a new virtual device, and select your preferred configuration.
4. Connect a Physical Device (Optional): If you prefer testing on a physical Android device, ensure USB debugging is enabled on your device, and then connect it to your computer. Run the same flutter run command, and the app will launch on your device.

## Location Services

To provide you with the best possible recommendations based on your current location, we kindly ask you to enable location services on your device. This will allow the app to suggest places nearby.

## Google Takeout Data

We're working to customize your recommended places using your Google Takeout data. By sharing this data, we can generate suggestions that are more accurately tailored to your preferences and interests. To learn more about Google Takeout and how to export your data, visit the [Google Takeout website](https://support.google.com/accounts/answer/3024190?hl=en).

## Back end
https://github.com/yianan261/GeminiCompetition_Backend

## Team Members
1. Lana Phuong
2. Kelvin Christian
3. Yian Chen
4. Kasi Viswanath Vandanapu
