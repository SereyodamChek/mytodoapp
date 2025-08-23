import 'package:cloud_firestore/cloud_firestore.dart';

class Todo {
  final String id;
  final String title;
  final bool isCompleted;
  final DateTime? createdAt;

  Todo({
    required this.id,
    required this.title,
    required this.isCompleted,
    this.createdAt,
  });

  factory Todo.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Todo(
      id: doc.id,
      title: data['title'] ?? '',
      isCompleted: data['isCompleted'] ?? false,
      createdAt: data['createdAt']?.toDate(),
    );
  }

  get isDone => null;
}
