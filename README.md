# 👻 Echo

> **Your Second Memory.**
>
> Echo is an AI-powered personal memory assistant that helps users capture thoughts naturally and reminds them at the right time and place.

---

## 📖 Overview

People often remember important things at the wrong moment:

- "I need to buy toothpaste."
- "I should ask Mark about the project."
- "Don't forget to pay the internet bill tomorrow."

Unfortunately, these thoughts are easily forgotten.

**Echo** allows users to simply type or speak what they need to remember, while the system automatically understands the intent and organizes it into actionable reminders.

Instead of forcing users to manually create tasks, dates, and categories, Echo transforms natural language into structured memories.

---

## ✨ Features (MVP)

### 🔐 Authentication
- Email & Password Login
- Secure Firebase Authentication

### 📝 Smart Memory Capture
Users can enter reminders naturally.

Example:

> "Remind me to buy groceries tomorrow."

Echo automatically extracts:
- Task
- Date
- Reminder Type

---

### 🤖 AI Memory Processing

Natural language is converted into structured data.

Example:

Input:

> "Remind me to pay the electricity bill on Friday."

Output:

- Task: Pay electricity bill
- Date: Friday
- Category: Finance

---

### 📋 Memory Dashboard

View all active memories in one place.

- Pending
- Completed
- Archived (future feature)

---

### 🔔 Reminder Notifications

Receive local notifications when reminders become due.

---

## 🚀 Planned Features

### 🎤 Voice Input
Speak naturally instead of typing.

Example:

> "Echo, remind me to bring my charger when I leave home."

---

### 📍 Location-Based Reminders

Examples:

- Remind me to buy coffee when I get to the mall.
- Remind me to submit documents when I arrive at school.

---

### 🧠 Context Memory

Echo remembers relationships between information.

Example:

> "I lent Mark ₱500."

Later:

> "What should I remember about Mark?"

Echo can summarize previous memories.

---

### 📅 Daily AI Summary

Every evening:

```
Today:
✓ Submitted assignment
✓ Paid internet bill

Remaining:
• Buy groceries
• Call Mom
```

---

### 📸 Image & Receipt Recognition

Take a picture of:
- Receipts
- Notes
- Documents

Echo extracts useful information automatically.

---

## 🏗️ Tech Stack

### Mobile
- Flutter

### Backend
- Python Flask

### Database
- Firebase Firestore

### Authentication
- Firebase Authentication

### AI / NLP
- Python
- Regex
- Dateparser
- spaCy

### Notifications
- flutter_local_notifications

### Future AI Engine
- Ollama
- Gemma 3B / Phi-3 Mini

---

## 📂 Project Structure

```
echo/
│
├── mobile/
│   ├── lib/
│   ├── screens/
│   ├── services/
│   ├── widgets/
│   └── models/
│
├── backend/
│   ├── app.py
│   ├── routes/
│   ├── ai/
│   └── utils/
│
└── docs/
    ├── project_vision.md
    ├── api_design.md
    └── database_design.md
```

---

## 🗺️ Development Roadmap

### Phase 1 — MVP
- [x] Project Planning
- [ ] Flutter Setup
- [ ] Firebase Integration
- [ ] User Authentication
- [ ] Firestore Database
- [ ] Add Memory
- [ ] AI Parser
- [ ] Reminder Notifications

---

### Phase 2 — Smart Features
- [ ] Voice Input
- [ ] Location Reminders
- [ ] Smart Categories
- [ ] Daily Summary

---

### Phase 3 — AI Assistant
- [ ] Context Memory
- [ ] Local LLM Integration
- [ ] Image Recognition
- [ ] Calendar Integration

---

## 🎯 Project Goal

Echo aims to become an intelligent "second brain" that helps users capture, organize, and recall important information effortlessly.

Rather than adapting to rigid productivity systems, users simply express their thoughts naturally, while Echo handles the organization behind the scenes.

---

## 💡 Inspiration

Many productivity applications require users to think like a computer:

- Create task
- Set date
- Choose category
- Configure reminder

Echo flips this experience.

Users simply say:

> "Remind me to buy flowers when I'm near the market because it's Mom's birthday."

Echo takes care of the rest.

---

## 🔒 Status

🚧 Currently under active development.

This project is being built as a portfolio project and experimental AI productivity application.

---

## 👨‍💻 Developer

**Richard Veluz**

Bachelor of Science in Information Technology

GitHub: *(Add your GitHub profile here)*

---

## 📄 License

This project is licensed under the MIT License.

Feel free to fork, study, and contribute.
