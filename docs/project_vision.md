# Echo

> **Your second memory.**

Echo is an AI-powered memory assistant that lets users speak naturally, and it remembers things for them at the right time and place.

---

## Target Users

- Students
- Professionals
- Busy people
- People who forget small things

## Problem

People remember things at the wrong moment.

## Solution

Capture thoughts instantly and let AI organize them.

---

## MVP (Version 1) — Scope

Build the smallest working version possible.

### ✅ Included

| Feature              | Description                                              |
| -------------------- | -------------------------------------------------------- |
| Login / Register     | Firebase Auth (email & password)                         |
| Add Memory (Text)    | User types a natural-language reminder                   |
| AI Extraction        | Backend parses task, date, and type from the input       |
| Memory List          | Home screen shows all saved memories                     |
| Local Notifications  | App schedules reminders on the device                    |

### ❌ Not in V1

- Voice input
- Location-based reminders
- Google Maps integration
- Web dashboard

---

## Example Flow

**User enters:**

> "Remind me to buy coffee tomorrow."

**AI extracts:**

```json
{
  "task": "Buy coffee",
  "date": "2026-06-06",
  "trigger": "time"
}
```

The memory is saved and a local notification is scheduled.

---

## Tech Stack

| Layer            | Technology                |
| ---------------- | ------------------------- |
| Mobile           | Flutter                   |
| Backend          | Flask (Python)            |
| Database         | Firebase Firestore        |
| Authentication   | Firebase Auth             |
| AI / NLP         | Python (regex, dateparser)|
| Notifications    | flutter_local_notifications |

**Later additions:** Ollama (local LLM), voice input, geofencing.

---

## UI Pages (V1)

1. Splash
2. Login
3. Register
4. Home (Memory List)
5. Add Memory
6. Memory Details
7. Profile

---

## Deployment Strategy

### Mobile (Android)

```
Flutter → Android APK → Test on phone
Flutter → AAB file → Google Play Console → Production
```

Google Play Developer account: ~US$25 one-time fee.

### Backend

| Service         | Free Tier | Notes          |
| --------------- | --------- | -------------- |
| **Render**      | ✅        | Recommended    |
| Railway         | ✅        | Very easy      |
| Fly.io          | ✅        | Good           |
| PythonAnywhere  | ✅        | Simple         |

**Target URL:** `https://echo-api.onrender.com`

### Architecture

```
Flutter App
     │
     ▼
Flask API (Render)
     │
     ▼
Firestore
```

### Domain (optional, later)

- `echo-memory.app`
- `myecho.app`

---

## Future Architecture

```
                 Flutter App
                      │
        ┌─────────────┴─────────────┐
        │                           │
  Firebase Auth              Flask API (Render)
        │                           │
    Firestore             NLP / AI Processing
        │                           │
        └─────────────┬─────────────┘
                      │
           Local Notifications
```

### Future Features

- Voice input
- Geofencing (location-based reminders)
- Google Maps integration
- Local LLM with Ollama
- AI memory summaries
- Web dashboard