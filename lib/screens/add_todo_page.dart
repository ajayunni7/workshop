import 'package:flutter/material.dart';
import '../models/todo.dart';
import '../database/database_helper.dart';

class AddTodoPage extends StatefulWidget {
  const AddTodoPage({super.key});

  @override
  State<AddTodoPage> createState() => _AddTodoPageState();
}

class _AddTodoPageState extends State<AddTodoPage> {
  final TextEditingController _titleController = TextEditingController();
  final DatabaseHelper dbHelper = DatabaseHelper();

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  // Handle adding a new todo to the database
  Future<void> _addTodo() async {
    final title = _titleController.text.trim();
    
    // Ensure the title isn't empty
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a title')),
      );
      return;
    }

    // Create the new todo model
    final newTodo = Todo(
      title: title,
      createdAt: DateTime.now(),
    );

    // Insert into the database
    await dbHelper.insertTodo(newTodo);
    
    // Navigate back to the previous screen, returning true to indicate success
    if (mounted) {
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Todo'),
      content: TextField(
        controller: _titleController,
        decoration: const InputDecoration(
          hintText: 'Enter todo title',
          border: OutlineInputBorder(),
        ),
        autofocus: true,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: _addTodo,
          child: const Text('Add'),
        ),
      ],
    );
  }
}
