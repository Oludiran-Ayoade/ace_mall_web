# Ace Mall Staff Management App

A beautiful staff management application for Ace Mall with 13+ branches.

## Features

- **Animated Intro Page**: Beautiful green gradient splash screen with smooth animations
- **Sign In Page**: Clean authentication interface with email and password fields
- **Sign Up Page**: Complete registration form with validation
- **Modern UI**: Green color scheme matching Ace SuperMarket branding
- **Smooth Navigation**: Seamless transitions between pages

## Pages

### 1. Intro Page (`intro_page.dart`)
- Green gradient background (bright to dark green)
- Animated shopping cart icon with scale and fade effects
- "Ace SuperMarket" branding with tagline "...serving your needs"
- Auto-navigates to sign-in page after 3 seconds

### 2. Sign In Page (`signin_page.dart`)
- Email and password input fields
- Password visibility toggle
- "Forgot Password?" link
- Green sign-in button
- Link to sign-up page

### 3. Sign Up Page (`signup_page.dart`)
- Full name, email, password, and confirm password fields
- Form validation
- Password visibility toggles
- Green sign-up button
- Link to sign-in page

## Getting Started

### Prerequisites
- Flutter SDK installed
- Dart SDK installed
- An IDE (VS Code, Android Studio, or IntelliJ)

### Running the App

```bash
# Get dependencies
flutter pub get

# Run on Chrome
flutter run -d chrome

# Run on macOS
flutter run -d macos

# Run on iOS simulator
flutter run -d ios

# Run on Android emulator
flutter run -d android
```

## Project Structure

```
lib/
├── main.dart           # App entry point with routing
└── pages/
    ├── intro_page.dart    # Animated splash screen
    ├── signin_page.dart   # Sign in page
    └── signup_page.dart   # Sign up page
```

## Color Scheme

- **Primary Green**: `#4CAF50`
- **Dark Green**: `#2E7D32`
- **White**: `#FFFFFF`
- **Grey**: Various shades for text and borders

## Technologies Used

- **Flutter**: UI framework
- **Dart**: Programming language
- **Material Design 3**: Design system
