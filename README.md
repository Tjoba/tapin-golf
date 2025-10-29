# tapin_golf

# Tapin Golf Mobile App

A Flutter mobile golf application with Firebase backend for user profiles and data storage.

## Features

### 🏌️‍♂️ Core Features
- **4 Main Sections**: Home, Play, Book, and You
- **Bottom Navigation**: Easy switching between sections
- **User Authentication**: Email/password signup and login
- **User Profiles**: Comprehensive profile management with handicap tracking

### 🔥 Firebase Integration
- **Authentication**: Secure user signup/login with Firebase Auth
- **Firestore Database**: User profile storage and real-time updates
- **Profile Management**: Edit name, handicap, and home club

### 📱 User Profile Features
- Display name and email management
- Golf handicap tracking
- Home club information
- Profile picture support (placeholder ready)
- Real-time profile updates

## Project Structure

```
lib/
├── main.dart                 # Main app entry point with navigation
├── models/
│   └── user_profile.dart     # User profile data model
└── services/
    ├── auth_service.dart     # Firebase Authentication service
    └── firestore_service.dart # Firestore database service
```

## Setup Instructions

### Prerequisites
- Flutter SDK installed
- Firebase project created
- VS Code with Flutter extensions

### Firebase Setup
1. **Create Firebase Project**: Go to [Firebase Console](https://console.firebase.google.com/)
2. **Enable Authentication**: 
   - Go to Authentication > Sign-in method
   - Enable Email/Password provider
3. **Create Firestore Database**: 
   - Go to Firestore Database
   - Create database in test mode
4. **Add your app**:
   - For Web: Add web app and copy config to `lib/firebase_options.dart`
   - For Android: Download `google-services.json` to `android/app/`
   - For iOS: Download `GoogleService-Info.plist` to `ios/Runner/`

### Running the App

```bash
# Install dependencies
flutter pub get

# Run on Chrome (web)
flutter run -d chrome

# Run on iOS simulator
flutter run -d ios

# Run on Android emulator
flutter run -d android
```

### VS Code Tasks
- **Flutter: Run App** - Launches the app with hot reload

## Development

### User Profile Flow
1. **Unauthenticated**: Shows sign-in prompt
2. **Sign Up**: Creates user account and profile in Firestore
3. **Sign In**: Loads existing user profile
4. **Profile Management**: Edit handicap, home club, and display name
5. **Sign Out**: Clears authentication state

### Database Structure

**Users Collection** (`/users/{uid}`)
```javascript
{
  "uid": "user_unique_id",
  "email": "user@example.com",
  "displayName": "User Name",
  "photoUrl": "optional_photo_url",
  "handicap": 15,
  "homeClub": "Country Club Name",
  "createdAt": "2024-01-01T00:00:00.000Z",
  "updatedAt": "2024-01-01T00:00:00.000Z"
}
```

## Next Steps

Ready to add content to:
- **Home Screen**: Dashboard with recent rounds, weather, etc.
- **Play Screen**: Round tracking, scorecard, GPS features
- **Book Screen**: Tee time booking, course reservations

## Technologies Used

- **Flutter**: Cross-platform mobile framework
- **Dart**: Programming language
- **Firebase Auth**: User authentication
- **Firestore**: NoSQL database
- **Material Design 3**: UI design system
