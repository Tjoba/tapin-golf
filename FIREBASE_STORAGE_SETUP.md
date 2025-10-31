# Firebase Storage Setup Guide

## Issue
Getting error: `[firebase_storage/object-not-found] No object exists at the desired reference.`

## Root Cause
This error typically occurs when:
1. Firebase Storage bucket doesn't exist
2. Storage security rules are too restrictive
3. Storage isn't properly initialized in Firebase Console

## Solution Steps

### 1. Firebase Console Setup

1. **Go to Firebase Console**: https://console.firebase.google.com/
2. **Select your project**: `tapin-a79e6`
3. **Navigate to Storage**: Click "Storage" in the left sidebar
4. **Initialize Storage** (if not done):
   - Click "Get started"
   - Choose "Start in production mode" 
   - Select storage location (recommend: us-central1)

### 2. Configure Storage Rules

In Firebase Console > Storage > Rules tab, replace the default rules with:

```javascript
rules_version = '2';

service firebase.storage {
  match /b/{bucket}/o {
    // Allow users to upload profile images
    match /profile_images/{userId}_{timestamp}.jpg {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Alternative: More permissive rule for testing
    // match /{allPaths=**} {
    //   allow read, write: if request.auth != null;
    // }
  }
}
```

### 3. Verify Storage Bucket

Your storage bucket should be: `tapin-a79e6.firebasestorage.app`

This is correctly configured in your `firebase_options.dart` file.

### 4. Test the Upload

After configuring the rules:
1. Hot restart your app: `flutter run` or press 'R' in terminal
2. Try uploading a profile picture
3. Check the detailed error messages in console

### 5. Troubleshooting

If still getting errors, try these debugging steps:

1. **Check Firebase Project Status**:
   - Ensure billing is enabled (required for Storage)
   - Verify project is active

2. **Test with Permissive Rules** (temporarily):
   ```javascript
   rules_version = '2';
   service firebase.storage {
     match /b/{bucket}/o {
       match /{allPaths=**} {
         allow read, write: if request.auth != null;
       }
     }
   }
   ```

3. **Check Network Connectivity**:
   - Ensure device has internet connection
   - Test on different networks

4. **Verify Authentication**:
   - Ensure user is properly logged in
   - Check auth token is valid

### 6. Enhanced Debug Information

The app now provides detailed error information:
- Firebase error codes and messages
- Storage bucket verification
- Connection testing
- User-friendly error explanations

## Quick Fix Commands

If you need to recreate Firebase configuration:

```bash
# Install Firebase CLI (if not installed)
npm install -g firebase-tools

# Login to Firebase
firebase login

# Configure FlutterFire
dart pub global activate flutterfire_cli
flutterfire configure
```

## Expected Behavior After Fix

✅ Profile picture uploads should work
✅ Detailed error messages if issues occur  
✅ Proper user feedback during upload process
✅ Progress indicators during upload