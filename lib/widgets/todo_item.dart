import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/firebase_service.dart';
import '../models/todo_model.dart';

class TodoItem extends StatelessWidget {
  final Todo todo;

  const TodoItem({Key? key, required this.todo}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(todo.id),
      background: Container(color: Colors.red),
      onDismissed: (direction) {
        context.read<FirebaseService>().deleteTodo(todo.id);
      },
      child: ListTile(
        leading: Checkbox(
          value: todo.isCompleted,
          onChanged: (value) {
            context.read<FirebaseService>().toggleTodoCompletion(
              todo.id,
              todo.isCompleted,
            );
          },
        ),
        title: Text(
          todo.title,
          style: TextStyle(
            color: Colors.white,
            decoration: todo.isCompleted ? TextDecoration.lineThrough : null,
          ),
        ),
        trailing: IconButton(
          icon: Icon(Icons.delete, color: Colors.red),
          onPressed: () {
            context.read<FirebaseService>().deleteTodo(todo.id);
          },
        ),
      ),
    );
  }
}
