# Firebase Console Setup Instructions

## 🎯 **IMPORTANT: Complete these steps in your Firebase Console**

### 1. **Enable Authentication**
1. Go to [Firebase Console](https://console.firebase.google.com/project/tapin-a79e6)
2. Click **Authentication** in the left sidebar
3. Click **Get started** (if first time)
4. Go to **Sign-in method** tab
5. Click **Email/Password** provider
6. **Enable** both options:
   - ✅ Email/Password
   - ✅ Email link (passwordless sign-in) - Optional
7. Click **Save**

### 2. **Enable Firestore Database**
1. In Firebase Console, click **Firestore Database**
2. Click **Create database**
3. **Select mode**: Start in **test mode** (for development)
4. **Select location**: Choose closest to your users
5. Click **Done**

### 3. **Configure Security Rules (Optional - for production)**
```javascript
// Firestore Security Rules (replace default test rules)
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can only read/write their own profile
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

## ✅ **Your Project is Now Configured:**

- **Project ID**: `tapin-a79e6`
- **App IDs**:
  - Android: `1:222192939392:android:3317c2a5fabe3d6a2c1165`
  - iOS: `1:222192939392:ios:2b0a1b1f614169892c1165`
  - Web: `1:222192939392:web:85807f0716305f7a2c1165`

## 🚀 **Test Your Setup:**

1. Run your app: `flutter run -d chrome`
2. Navigate to "You" tab
3. Try signing up with a test email
4. Check Firebase Console > Authentication > Users (should see new user)
5. Check Firestore Database > Data (should see user profile)

## 🔧 **Next Steps:**

- Enable additional sign-in providers (Google, Apple, etc.)
- Set up push notifications
- Configure app distribution
- Add more Firestore collections for golf data

Your Firebase backend is ready! 🎉