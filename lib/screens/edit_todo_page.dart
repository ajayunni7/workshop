import 'package:flutter/material.dart';
import '../models/todo.dart';
import '../database/database_helper.dart';

class EditTodoPage extends StatefulWidget {
  final Todo todo;
  
  const EditTodoPage({super.key, required this.todo});

  @override
  State<EditTodoPage> createState() => _EditTodoPageState();
}

class _EditTodoPageState extends State<EditTodoPage> {
  late TextEditingController _titleController;
  late DatabaseHelper dbHelper;

  @override
  void initState() {
    super.initState();
    // Pre-populate with current todo title
    _titleController = TextEditingController(text: widget.todo.title);
    dbHelper = DatabaseHelper();
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Todo'),
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
          onPressed: () async {
            if (_titleController.text.trim().isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Please enter a title')),
              );
              return;
            }
            
            // Create updated todo with new title
            final updatedTodo = Todo(
              id: widget.todo.id,
              title: _titleController.text.trim(),
              isComplete: widget.todo.isComplete,
              createdAt: widget.todo.createdAt,
            );
            
            // Update in database
            await dbHelper.updateTodo(updatedTodo);
            
            if (!context.mounted) return;
            // Pop with true result
            Navigator.pop(context, true);
          },
          child: const Text('Update'),
        ),
      ],
    );
  }
}
