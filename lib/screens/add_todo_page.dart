import 'package:flutter/material.dart';
import '../models/todo.dart';
import '../database/database_helper.dart';

// AddTodoPage provides a form to create a new task.
// It's a StatefulWidget because it needs to manage the state of the text input field.
class AddTodoPage extends StatefulWidget {
  const AddTodoPage({super.key});

  @override
  State<AddTodoPage> createState() => _AddTodoPageState();
}

class _AddTodoPageState extends State<AddTodoPage> {
  // A TextEditingController lets us read the text that the user types into the TextField.
  final TextEditingController _titleController = TextEditingController();
  
  // We need access to the database helper to save the new task.
  final DatabaseHelper dbHelper = DatabaseHelper();

  // dispose is called when this widget is removed from the screen permanently.
  @override
  void dispose() {
    // Always dispose controllers to free up memory!
    _titleController.dispose();
    super.dispose();
  }

  // Handle adding a new todo to the database when the user clicks "Add Task"
  Future<void> _addTodo() async {
    // .trim() removes any extra spaces from the beginning or end of the text.
    final title = _titleController.text.trim();
    
    // Ensure the user actually typed something before saving.
    if (title.isEmpty) {
      // Show a temporary message (SnackBar) at the bottom of the screen
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a title')),
      );
      return; // Stop the function here so we don't save an empty task.
    }

    // Create a new Todo object. 
    // We don't provide an ID because the database will generate one automatically.
    final newTodo = Todo(
      title: title,
      createdAt: DateTime.now(), // Get the exact current time
    );

    // Save it to the database
    await dbHelper.insertTodo(newTodo);
    
    // mounted checks if this screen is still visible to the user.
    // We shouldn't try to navigate if the user already closed the screen.
    if (mounted) {
      // Navigator.pop closes the current screen (the bottom sheet).
      // We pass 'true' back to the previous screen (HomePage) so it knows a task was added.
      Navigator.pop(context, true);
    }
  }

  // Build the UI for the add task form.
  @override
  Widget build(BuildContext context) {
    return Padding(
      // Add padding for keyboard
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 24,
        right: 24,
        top: 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Add Todo',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _titleController,
            decoration: InputDecoration(
              hintText: 'What do you need to do?',
              filled: true,
              fillColor: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.5),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.primary,
                  width: 2,
                ),
              ),
            ),
            autofocus: true,
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: _addTodo,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Add Task'),
              ),
            ],
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
