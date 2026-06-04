# Echo — Database Design

> Firestore (NoSQL) collections for the Echo MVP.

---

## Collections

### `users`

Stores user profile information. Document ID = Firebase Auth UID.

| Field     | Type     | Description              |
| --------- | -------- | ------------------------ |
| `uid`     | string   | Firebase Auth UID (key)  |
| `name`    | string   | Display name             |
| `email`   | string   | Email address            |

**Example document** (`users/abc123`):

```json
{
  "uid": "abc123",
  "name": "Richard",
  "email": "richard@example.com"
}
```

---

### `memories`

Stores each memory/reminder. Document ID = auto-generated.

| Field            | Type      | Description                                      |
| ---------------- | --------- | ------------------------------------------------ |
| `memory_id`      | string    | Auto-generated document ID                       |
| `uid`            | string    | Owner's Firebase Auth UID                        |
| `original_text`  | string    | Raw text entered by the user                     |
| `task`           | string    | AI-extracted task description                    |
| `reminder_date`  | string    | ISO date/datetime for the reminder               |
| `reminder_type`  | string    | Trigger type: `"time"` (V1 only)                 |
| `completed`      | boolean   | Whether the user marked it done                  |
| `created_at`     | timestamp | Server timestamp when the memory was created     |

**Example document** (`memories/mem_001`):

```json
{
  "uid": "abc123",
  "original_text": "Remind me to buy shampoo tomorrow",
  "task": "Buy shampoo",
  "reminder_date": "2026-06-06",
  "reminder_type": "time",
  "completed": false,
  "created_at": "2026-06-05T01:20:00Z"
}
```

---

## Firestore Rules (V1 — basic)

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    // Users can only read/write their own profile
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }

    // Users can only read/write their own memories
    match /memories/{memoryId} {
      allow read, write: if request.auth != null && request.resource.data.uid == request.auth.uid;
      allow create: if request.auth != null && request.resource.data.uid == request.auth.uid;
    }
  }
}
```

---

## Indexes

For the MVP, one composite index is needed:

| Collection | Fields                          | Purpose                          |
| ---------- | ------------------------------- | -------------------------------- |
| `memories` | `uid` ASC, `created_at` DESC   | List a user's memories by newest |

---

## Future Considerations

- **`location`** field (GeoPoint) for geofenced reminders
- **`tags`** array for categorization
- **`voice_url`** string for stored voice recordings
- **`summary`** string for AI-generated memory summaries
