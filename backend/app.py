"""
Echo — Flask Backend API

AI-powered memory assistant backend.
Endpoints follow the API design at docs/api_design.md.
"""

import os
from datetime import datetime, timezone

from flask import Flask, request, jsonify
from flask_cors import CORS
import firebase_admin
from firebase_admin import credentials, firestore

from parser import parse_memory
from auth import require_auth


# ─── Firebase Initialization ─────────────────────────────────────────────────

# Path to the Firebase Admin SDK key
# In production, use environment variable FIREBASE_CREDENTIALS
cred_path = os.environ.get(
    "FIREBASE_CREDENTIALS",
    os.path.join(os.path.dirname(__file__), "firebase-admin-key.json"),
)

cred = credentials.Certificate(cred_path)
firebase_admin.initialize_app(cred)
db = firestore.client()


# ─── Flask App ────────────────────────────────────────────────────────────────

app = Flask(__name__)
CORS(app)  # Allow Flutter app to make requests


# ─── Health Check ─────────────────────────────────────────────────────────────

@app.route("/health", methods=["GET"])
def health():
    """Health check endpoint — no auth required."""
    return jsonify({
        "status": "ok",
        "version": "1.0.0",
    })


# ─── Parse Memory (AI Endpoint) ──────────────────────────────────────────────

@app.route("/api/parse", methods=["POST"])
@require_auth
def parse(uid):
    """
    Parse natural language text into structured memory data.

    Request:  {"text": "Remind me to buy coffee tomorrow"}
    Response: {"task": "Buy coffee", "date": "2026-06-06", "trigger": "time"}
    """
    data = request.get_json()

    if not data or "text" not in data:
        return jsonify({"error": "Missing 'text' field in request body"}), 400

    text = data["text"].strip()

    if not text:
        return jsonify({"error": "Text cannot be empty"}), 400

    result = parse_memory(text)

    if "error" in result:
        return jsonify({"error": result["error"]}), 400

    return jsonify(result), 200


# ─── Create Memory ───────────────────────────────────────────────────────────

@app.route("/api/memories", methods=["POST"])
@require_auth
def create_memory(uid):
    """
    Save a parsed memory to Firestore.

    Request body:
        {
            "original_text": "Remind me to buy coffee tomorrow",
            "task": "Buy coffee",
            "reminder_date": "2026-06-06",
            "reminder_type": "time"
        }
    """
    data = request.get_json()

    if not data:
        return jsonify({"error": "Missing request body"}), 400

    required_fields = ["original_text", "task", "reminder_date", "reminder_type"]
    for field in required_fields:
        if field not in data:
            return jsonify({"error": f"Missing required field: {field}"}), 400

    # Build the memory document
    memory_doc = {
        "uid": uid,
        "original_text": data["original_text"],
        "task": data["task"],
        "reminder_date": data["reminder_date"],
        "reminder_type": data["reminder_type"],
        "completed": False,
        "created_at": datetime.now(timezone.utc).isoformat(),
    }

    # Add to Firestore
    doc_ref = db.collection("memories").add(memory_doc)
    memory_id = doc_ref[1].id

    return jsonify({
        "memory_id": memory_id,
        "message": "Memory created successfully",
    }), 201


# ─── List Memories ───────────────────────────────────────────────────────────

@app.route("/api/memories", methods=["GET"])
@require_auth
def list_memories(uid):
    """
    Get all memories for the authenticated user, newest first.

    Query params:
        completed (bool, optional) — filter by completion status
        limit (int, optional, default=20) — max results
    """
    memories_ref = db.collection("memories")

    # Filter by user
    query = memories_ref.where("uid", "==", uid)

    # Optional: filter by completed status
    completed_param = request.args.get("completed")
    if completed_param is not None:
        completed = completed_param.lower() == "true"
        query = query.where("completed", "==", completed)

    # Order by created_at descending
    query = query.order_by("created_at", direction=firestore.Query.DESCENDING)

    # Limit results
    limit = request.args.get("limit", 20, type=int)
    query = query.limit(limit)

    # Execute query
    docs = query.stream()

    memories = []
    for doc in docs:
        memory = doc.to_dict()
        memory["memory_id"] = doc.id
        memories.append(memory)

    return jsonify({"memories": memories}), 200


# ─── Get Single Memory ──────────────────────────────────────────────────────

@app.route("/api/memories/<memory_id>", methods=["GET"])
@require_auth
def get_memory(memory_id, uid):
    """Get a single memory by ID."""
    doc = db.collection("memories").document(memory_id).get()

    if not doc.exists:
        return jsonify({"error": "Memory not found"}), 404

    memory = doc.to_dict()

    # Ensure the memory belongs to the authenticated user
    if memory.get("uid") != uid:
        return jsonify({"error": "Forbidden"}), 403

    memory["memory_id"] = doc.id
    return jsonify(memory), 200


# ─── Update Memory ───────────────────────────────────────────────────────────

@app.route("/api/memories/<memory_id>", methods=["PATCH"])
@require_auth
def update_memory(memory_id, uid):
    """
    Update a memory (e.g., mark as completed).

    Request body (partial update):
        {"completed": true}
    """
    doc_ref = db.collection("memories").document(memory_id)
    doc = doc_ref.get()

    if not doc.exists:
        return jsonify({"error": "Memory not found"}), 404

    memory = doc.to_dict()

    # Ensure the memory belongs to the authenticated user
    if memory.get("uid") != uid:
        return jsonify({"error": "Forbidden"}), 403

    data = request.get_json()
    if not data:
        return jsonify({"error": "Missing request body"}), 400

    # Only allow updating specific fields
    allowed_fields = ["task", "reminder_date", "reminder_type", "completed"]
    update_data = {k: v for k, v in data.items() if k in allowed_fields}

    if not update_data:
        return jsonify({"error": "No valid fields to update"}), 400

    doc_ref.update(update_data)

    return jsonify({"message": "Memory updated successfully"}), 200


# ─── Delete Memory ───────────────────────────────────────────────────────────

@app.route("/api/memories/<memory_id>", methods=["DELETE"])
@require_auth
def delete_memory(memory_id, uid):
    """Delete a memory."""
    doc_ref = db.collection("memories").document(memory_id)
    doc = doc_ref.get()

    if not doc.exists:
        return jsonify({"error": "Memory not found"}), 404

    memory = doc.to_dict()

    # Ensure the memory belongs to the authenticated user
    if memory.get("uid") != uid:
        return jsonify({"error": "Forbidden"}), 403

    doc_ref.delete()

    return jsonify({"message": "Memory deleted successfully"}), 200


# ─── Run ─────────────────────────────────────────────────────────────────────

if __name__ == "__main__":
    port = int(os.environ.get("PORT", 5000))
    app.run(debug=True, host="0.0.0.0", port=port)
