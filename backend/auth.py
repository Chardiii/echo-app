"""
Echo — Firebase Authentication Middleware

Verifies Firebase ID tokens from the Authorization header.
Extracts the user's UID and attaches it to the request context.
"""

from functools import wraps

from flask import request, jsonify
from firebase_admin import auth


def require_auth(f):
    """
    Decorator that verifies the Firebase ID token from the
    Authorization header. On success, passes `uid` as a keyword
    argument to the wrapped function.

    Usage:
        @app.route("/api/memories")
        @require_auth
        def list_memories(uid):
            ...
    """

    @wraps(f)
    def decorated(*args, **kwargs):
        # Extract the token from "Bearer <token>"
        auth_header = request.headers.get("Authorization", "")

        if not auth_header.startswith("Bearer "):
            return jsonify({"error": "Missing or invalid Authorization header"}), 401

        token = auth_header.split("Bearer ")[1].strip()

        if not token:
            return jsonify({"error": "Empty token"}), 401

        try:
            # Verify the token with Firebase Admin SDK
            decoded_token = auth.verify_id_token(token)
            uid = decoded_token["uid"]
        except auth.ExpiredIdTokenError:
            return jsonify({"error": "Token has expired"}), 401
        except auth.InvalidIdTokenError:
            return jsonify({"error": "Invalid token"}), 401
        except Exception as e:
            return jsonify({"error": f"Authentication failed: {str(e)}"}), 401

        # Pass the uid to the route function
        kwargs["uid"] = uid
        return f(*args, **kwargs)

    return decorated
