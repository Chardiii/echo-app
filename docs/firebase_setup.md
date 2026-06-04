# Echo — Firebase Setup Guide

> Step-by-step guide to set up Firebase for the Echo project.

---

## Step 1: Create a Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click **"Create a project"** (or "Add project")
3. Project name: **`Echo`**
4. Disable Google Analytics (not needed for MVP) — or enable it if you want, it's optional
5. Click **"Create project"**
6. Wait for it to finish, then click **"Continue"**

---

## Step 2: Enable Authentication

1. In the Firebase Console sidebar, click **Build → Authentication**
2. Click **"Get started"**
3. Go to the **"Sign-in method"** tab
4. Enable **Email/Password**:
   - Click on "Email/Password"
   - Toggle the **first switch ON** (Email/Password)
   - Leave the second switch OFF (Email link / passwordless)
   - Click **"Save"**

That's all you need for V1. Later you can add Google Sign-In, etc.

---

## Step 3: Create Firestore Database

1. In the sidebar, click **Build → Firestore Database**
2. Click **"Create database"**
3. Choose a location closest to your users:
   - For Philippines: **`asia-southeast1` (Singapore)**
   - This **cannot be changed later**, so choose carefully
4. Start in **Test mode** (for development)
   - This allows open read/write for 30 days
   - We'll add proper security rules before deploying

---

## Step 4: Set Up Firestore Security Rules

After creating the database, go to the **"Rules"** tab and replace the default rules with:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    // Users can only read/write their own profile
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }

    // Users can only access their own memories
    match /memories/{memoryId} {
      allow read, update, delete: if request.auth != null
        && resource.data.uid == request.auth.uid;
      allow create: if request.auth != null
        && request.resource.data.uid == request.auth.uid;
    }
  }
}
```

Click **"Publish"** to save.

> ⚠️ Keep test mode rules during development if you want easier debugging. Switch to the rules above before deploying.

---

## Step 5: Add an Android App to Firebase

1. On the Firebase Console home page, click the **Android icon** (🤖)
2. Fill in:
   - **Android package name:** `com.echo.memoryapp`
     - This must match what you'll use in Flutter. Pick something unique.
   - **App nickname:** `Echo Android`
   - **Debug signing certificate (SHA-1):** Skip for now (needed later for Google Sign-In)
3. Click **"Register app"**

### Download the config file

4. Download **`google-services.json`**
5. Place it in your Flutter project at:

```
Echo/
  mobile/
    android/
      app/
        google-services.json   ← HERE
```

6. Click **"Next"** through the remaining steps (we'll add the Flutter SDK, not native Android SDK)
7. Click **"Continue to console"**

---

## Step 6: Generate a Firebase Admin SDK Key (for Flask Backend)

1. In the Firebase Console, click the **⚙️ gear icon** → **"Project settings"**
2. Go to the **"Service accounts"** tab
3. Make sure **"Firebase Admin SDK"** is selected
4. Click **"Generate new private key"**
5. Confirm and download the JSON file
6. Rename it to **`firebase-admin-key.json`**
7. Place it in your backend folder:

```
Echo/
  backend/
    firebase-admin-key.json   ← HERE
```

> 🚨 **IMPORTANT:** This file contains secret credentials. **NEVER commit it to GitHub.**

---

## Step 7: Add to .gitignore

Create or update `.gitignore` in your project root to protect sensitive files:

```gitignore
# Firebase credentials — NEVER commit these
backend/firebase-admin-key.json
mobile/android/app/google-services.json

# Python
__pycache__/
*.pyc
.env
venv/

# Flutter
mobile/.dart_tool/
mobile/build/
mobile/.flutter-plugins
mobile/.flutter-plugins-dependencies

# IDE
.idea/
.vscode/
*.iml
```

---

## Step 8: Create Firestore Collections (Optional)

You can either create collections manually or let the app create them automatically when users sign up / add memories.

**To create manually (for testing):**

1. Go to **Firestore Database** in the console
2. Click **"Start collection"**
3. Collection ID: **`users`**
4. Add a test document:
   - Document ID: `test_user_001`
   - Fields:
     - `uid` (string): `test_user_001`
     - `name` (string): `Test User`
     - `email` (string): `test@example.com`
5. Repeat for a **`memories`** collection:
   - Document ID: auto-generate
   - Fields:
     - `uid` (string): `test_user_001`
     - `original_text` (string): `Remind me to buy coffee tomorrow`
     - `task` (string): `Buy coffee`
     - `reminder_date` (string): `2026-06-06`
     - `reminder_type` (string): `time`
     - `completed` (boolean): `false`

---

## Step 9: Verify Your Setup

### Checklist

- [ ] Firebase project created
- [ ] Authentication → Email/Password enabled
- [ ] Firestore database created (asia-southeast1)
- [ ] Security rules published (or in test mode for dev)
- [ ] Android app registered with package name `com.echo.memoryapp`
- [ ] `google-services.json` downloaded (will place in Flutter project later)
- [ ] Firebase Admin SDK key downloaded → `backend/firebase-admin-key.json`
- [ ] `.gitignore` updated to exclude secret files

---

## What's Next?

Once Firebase is set up, the next steps are:

1. **Set up Flutter project** in `mobile/` with Firebase packages
2. **Set up Flask backend** in `backend/` with Firebase Admin SDK
3. **Build the UI screens** (Splash, Login, Register, Home, etc.)

---

## Quick Reference

| Item                     | Value                          |
| ------------------------ | ------------------------------ |
| Firebase Project Name    | Echo                           |
| Android Package Name     | `com.echo.memoryapp`           |
| Firestore Region         | `asia-southeast1` (Singapore)  |
| Auth Method              | Email/Password                 |
| Admin Key Location       | `backend/firebase-admin-key.json` |
| Config File Location     | `mobile/android/app/google-services.json` |
