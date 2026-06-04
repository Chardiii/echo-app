/// Echo — Memory Service
///
/// Handles CRUD operations for memories via Firestore and the Flask API.

import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import '../core/constants.dart';
import 'auth_service.dart';

class Memory {
  final String id;
  final String uid;
  final String originalText;
  final String task;
  final String? reminderDate;
  final String reminderType;
  final bool completed;
  final DateTime createdAt;

  Memory({
    required this.id,
    required this.uid,
    required this.originalText,
    required this.task,
    this.reminderDate,
    required this.reminderType,
    required this.completed,
    required this.createdAt,
  });

  factory Memory.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Memory(
      id: doc.id,
      uid: data['uid'] ?? '',
      originalText: data['original_text'] ?? '',
      task: data['task'] ?? '',
      reminderDate: data['reminder_date'],
      reminderType: data['reminder_type'] ?? 'time',
      completed: data['completed'] ?? false,
      createdAt: data['created_at'] is Timestamp
          ? (data['created_at'] as Timestamp).toDate()
          : DateTime.tryParse(data['created_at'] ?? '') ?? DateTime.now(),
    );
  }

  factory Memory.fromJson(Map<String, dynamic> json) {
    return Memory(
      id: json['memory_id'] ?? '',
      uid: json['uid'] ?? '',
      originalText: json['original_text'] ?? '',
      task: json['task'] ?? '',
      reminderDate: json['reminder_date'],
      reminderType: json['reminder_type'] ?? 'time',
      completed: json['completed'] ?? false,
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
    );
  }
}

class MemoryService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthService _authService = AuthService();

  // Use local URL for development, switch to production URL for release
  final String _baseUrl = AppConstants.apiBaseUrl;

  /// Parse natural language text via the Flask API
  Future<Map<String, dynamic>> parseMemory(String text) async {
    final token = await _authService.getIdToken();
    if (token == null) throw Exception('Not authenticated');

    final response = await http.post(
      Uri.parse('$_baseUrl/api/parse'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'text': text}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['error'] ?? 'Failed to parse memory');
    }
  }

  /// Create a new memory in Firestore
  Future<String> createMemory({
    required String originalText,
    required String task,
    required String? reminderDate,
    required String reminderType,
  }) async {
    final user = _authService.currentUser;
    if (user == null) throw Exception('Not authenticated');

    final doc = await _firestore.collection('memories').add({
      'uid': user.uid,
      'original_text': originalText,
      'task': task,
      'reminder_date': reminderDate,
      'reminder_type': reminderType,
      'completed': false,
      'created_at': FieldValue.serverTimestamp(),
    });

    return doc.id;
  }

  /// Get all memories for the current user
  Stream<List<Memory>> getMemories() {
    final user = _authService.currentUser;
    if (user == null) return Stream.value([]);

    return _firestore
        .collection('memories')
        .where('uid', isEqualTo: user.uid)
        .snapshots()
        .map((snapshot) {
          final list = snapshot.docs.map((doc) => Memory.fromFirestore(doc)).toList();
          // Sort locally: newest first
          list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return list;
        });
  }

  /// Get memory count stats for the current user
  Future<Map<String, int>> getStats() async {
    final user = _authService.currentUser;
    if (user == null) return {'total': 0, 'completed': 0, 'pending': 0};

    final snapshot = await _firestore
        .collection('memories')
        .where('uid', isEqualTo: user.uid)
        .get();

    final total = snapshot.docs.length;
    final completed =
        snapshot.docs.where((d) => d.data()['completed'] == true).length;

    return {
      'total': total,
      'completed': completed,
      'pending': total - completed,
    };
  }

  /// Toggle memory completion
  Future<void> toggleCompleted(String memoryId, bool completed) async {
    await _firestore.collection('memories').doc(memoryId).update({
      'completed': completed,
    });
  }

  /// Delete a memory
  Future<void> deleteMemory(String memoryId) async {
    await _firestore.collection('memories').doc(memoryId).delete();
  }
}
