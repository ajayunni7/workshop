import 'package:flutter/material.dart';
import '../models/todo.dart';
import '../database/database_helper.dart';

// EditTodoPage is similar to AddTodoPage, but it takes an existing Todo object
// to modify, rather than creating a brand new one.
class EditTodoPage extends StatefulWidget {
  // The task we want to edit, passed in from the HomePage.
  final Todo todo;
  
  // We require the 'todo' parameter when this widget is created.
  const EditTodoPage({super.key, required this.todo});

  @override
  State<EditTodoPage> createState() => _EditTodoPageState();
}

class _EditTodoPageState extends State<EditTodoPage> {
  // Use 'late' because we will initialize these variables inside initState(),
  // which runs after the widget is constructed but before build().
  late TextEditingController _titleController;
  late DatabaseHelper dbHelper;

  // initState runs exactly once when this screen is opened.
  @override
  void initState() {
    super.initState();
    // Pre-populate the text field with the existing task's title.
    // We access the properties of the parent widget using 'widget.propertyName'.
    _titleController = TextEditingController(text: widget.todo.title);
    dbHelper = DatabaseHelper();
  }

  // Clean up memory when this widget is closed.
  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  // Build the UI for the edit task form.
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
            'Edit Todo',
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
                onPressed: () async {
                  // Ensure they didn't clear out the title completely.
                  if (_titleController.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please enter a title')),
                    );
                    return; // Stop the function here
                  }
                  
                  // Create a NEW Todo object with the updated title, but KEEP 
                  // the original ID, completion status, and creation date.
                  final updatedTodo = Todo(
                    id: widget.todo.id, // Important: keeping the same ID tells the DB to update, not create!
                    title: _titleController.text.trim(),
                    isComplete: widget.todo.isComplete,
                    createdAt: widget.todo.createdAt,
                  );
                  
                  // Send the updated task to the database.
                  await dbHelper.updateTodo(updatedTodo);
                  
                  // Ensure the screen hasn't been closed before we try to pop it.
                  if (!context.mounted) return;
                  
                  // Pop the bottom sheet and return 'true' to signal a successful edit.
                  Navigator.pop(context, true);
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Save Changes'),
              ),
            ],
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
