# Echo — API Design

> Flask REST API endpoints for the Echo MVP.

**Base URL (production):** `https://echo-api.onrender.com`
**Base URL (local dev):** `http://localhost:5000`

---

## Authentication

All endpoints (except health check) require a valid **Firebase ID Token** in the `Authorization` header:

```
Authorization: Bearer <firebase_id_token>
```

The backend verifies the token using the Firebase Admin SDK and extracts the user's `uid`.

---

## Endpoints

### Health Check

```
GET /health
```

No auth required. Returns API status.

**Response:**

```json
{
  "status": "ok",
  "version": "1.0.0"
}
```

---

### Parse Memory

The core AI endpoint. Accepts natural-language text and returns structured data.

```
POST /api/parse
```

**Request body:**

```json
{
  "text": "Remind me to submit my assignment tomorrow at 8 PM"
}
```

**Response (200):**

```json
{
  "task": "Submit assignment",
  "date": "2026-06-06T20:00:00",
  "trigger": "time"
}
```

**Error (400):**

```json
{
  "error": "Could not parse the input text"
}
```

**Implementation notes (V1):**
- Uses Python `regex` and `dateparser` for extraction
- No external AI APIs required
- Future: replace with Ollama or other LLM

---

### Create Memory

Save a parsed memory to Firestore.

```
POST /api/memories
```

**Request body:**

```json
{
  "original_text": "Remind me to submit my assignment tomorrow at 8 PM",
  "task": "Submit assignment",
  "reminder_date": "2026-06-06T20:00:00",
  "reminder_type": "time"
}
```

**Response (201):**

```json
{
  "memory_id": "mem_abc123",
  "message": "Memory created successfully"
}
```

---

### List Memories

Get all memories for the authenticated user, newest first.

```
GET /api/memories
```

**Query parameters (optional):**

| Param       | Type    | Default | Description                    |
| ----------- | ------- | ------- | ------------------------------ |
| `completed` | boolean | —       | Filter by completion status    |
| `limit`     | int     | 20      | Max results to return          |

**Response (200):**

```json
{
  "memories": [
    {
      "memory_id": "mem_abc123",
      "original_text": "Remind me to submit my assignment tomorrow at 8 PM",
      "task": "Submit assignment",
      "reminder_date": "2026-06-06T20:00:00",
      "reminder_type": "time",
      "completed": false,
      "created_at": "2026-06-05T01:20:00Z"
    }
  ]
}
```

---

### Get Memory

Get a single memory by ID.

```
GET /api/memories/<memory_id>
```

**Response (200):**

```json
{
  "memory_id": "mem_abc123",
  "original_text": "Remind me to submit my assignment tomorrow at 8 PM",
  "task": "Submit assignment",
  "reminder_date": "2026-06-06T20:00:00",
  "reminder_type": "time",
  "completed": false,
  "created_at": "2026-06-05T01:20:00Z"
}
```

**Error (404):**

```json
{
  "error": "Memory not found"
}
```

---

### Update Memory

Update a memory (e.g., mark as completed).

```
PATCH /api/memories/<memory_id>
```

**Request body (partial update):**

```json
{
  "completed": true
}
```

**Response (200):**

```json
{
  "message": "Memory updated successfully"
}
```

---

### Delete Memory

```
DELETE /api/memories/<memory_id>
```

**Response (200):**

```json
{
  "message": "Memory deleted successfully"
}
```

---

## Error Handling

All errors follow a consistent format:

```json
{
  "error": "Human-readable error message"
}
```

| HTTP Code | Meaning                |
| --------- | ---------------------- |
| 200       | Success                |
| 201       | Created                |
| 400       | Bad request / invalid input |
| 401       | Unauthorized (missing or invalid token) |
| 403       | Forbidden (accessing another user's data) |
| 404       | Resource not found     |
| 500       | Internal server error  |

---

## Flutter Integration

```dart
// Example: Parse a memory
final response = await http.post(
  Uri.parse('$baseUrl/api/parse'),
  headers: {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $idToken',
  },
  body: jsonEncode({'text': userInput}),
);
```

---

## Future Endpoints

| Method | Endpoint              | Purpose                        |
| ------ | --------------------- | ------------------------------ |
| POST   | `/api/parse-voice`    | Accept audio, transcribe + parse |
| GET    | `/api/memories/summary` | AI-generated weekly summary   |
| POST   | `/api/memories/bulk`  | Create multiple memories at once |
