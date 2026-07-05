import 'package:flutter/material.dart';
import '../models/todo.dart';
import '../database/database_helper.dart';
import 'add_todo_page.dart';
import 'edit_todo_page.dart';

// HomePage is a StatefulWidget because its data (the list of todos) can change
// over time, requiring the UI to rebuild and reflect those changes.
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

// _HomePageState holds the mutable data and the build method for HomePage.
class _HomePageState extends State<HomePage> {
  // State variables
  List<Todo> todos = []; // Holds the list of tasks currently displayed on screen
  final DatabaseHelper dbHelper = DatabaseHelper(); // Access to our SQLite database

  // initState is called exactly once when this widget is first created.
  @override
  void initState() {
    super.initState();
    // We fetch the todos from the database as soon as the screen loads.
    loadTodos();
  }

  // Fetches the latest list of todos from the database and updates the UI.
  Future<void> loadTodos() async {
    final result = await dbHelper.getAllTodos(); // Get data from DB
    
    // setState tells Flutter that the data has changed, forcing it to call
    // the build() method again to redraw the screen with the new data.
    setState(() {
      todos = result;
    });
  }

  // The build method describes what the UI should look like based on current state.
  @override
  Widget build(BuildContext context) {
    // Theme holds all the color and typography settings we defined in main.dart
    final theme = Theme.of(context);
    
    // Scaffold provides the basic visual structure for a material design screen
    // (like AppBars, Drawers, and FloatingActionButtons).
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: const Text(
          "My Tasks",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
        elevation: 0,
        backgroundColor: Colors.transparent,
        scrolledUnderElevation: 0,
      ),
      // If there are no todos, we show a friendly "Empty State" message.
      body: todos.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.task_alt,
                    size: 80,
                    color: theme.colorScheme.primary.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "No tasks yet",
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Add a task to get started",
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            )
            // If there ARE todos, we use a ListView.builder.
            // This is efficient because it only builds the list items that are currently visible on screen.
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: todos.length, // How many items to display
              itemBuilder: (context, index) { // How to build each item
                final todo = todos[index]; // Get the specific task for this row
                final isCompleted = todo.isComplete;
                
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  // InkWell adds a nice ripple animation when the item is tapped
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () async {
                      // When a task is tapped, open the Edit screen in a Bottom Sheet
                      final result = await showModalBottomSheet<bool>(
                        context: context,
                        isScrollControlled: true,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                        ),
                        builder: (context) => EditTodoPage(todo: todo),
                      );
                      
                      if (result == true) {
                        loadTodos();
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: isCompleted 
                            ? theme.colorScheme.surfaceContainerHighest.withOpacity(0.4)
                            : theme.colorScheme.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isCompleted 
                              ? Colors.transparent
                              : theme.colorScheme.outlineVariant.withOpacity(0.5),
                        ),
                      ),
                      child: Row(
                        children: [
                          // Custom styled checkbox behavior
                          GestureDetector(
                            onTap: () async {
                              final updatedTodo = Todo(
                                id: todo.id,
                                title: todo.title,
                                isComplete: !todo.isComplete,
                                createdAt: todo.createdAt,
                              );
                              await dbHelper.updateTodo(updatedTodo);
                              loadTodos();
                            },
                            child: Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isCompleted 
                                    ? theme.colorScheme.primary 
                                    : Colors.transparent,
                                border: Border.all(
                                  color: isCompleted 
                                      ? theme.colorScheme.primary 
                                      : theme.colorScheme.outline,
                                  width: 2,
                                ),
                              ),
                              child: isCompleted 
                                  ? Icon(Icons.check, size: 16, color: theme.colorScheme.onPrimary)
                                  : null,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              todo.title,
                              style: theme.textTheme.titleMedium?.copyWith(
                                decoration: isCompleted ? TextDecoration.lineThrough : null,
                                color: isCompleted 
                                    ? theme.colorScheme.onSurfaceVariant 
                                    : theme.colorScheme.onSurface,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.delete_outline,
                              color: theme.colorScheme.error.withOpacity(0.8),
                            ),
                            onPressed: () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Delete Task?'),
                                  content: const Text('This action cannot be undone.'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context, false),
                                      child: const Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () => Navigator.pop(context, true),
                                      style: TextButton.styleFrom(
                                        foregroundColor: theme.colorScheme.error,
                                      ),
                                      child: const Text('Delete'),
                                    ),
                                  ],
                                ),
                              );
                              
                              if (confirm == true && todo.id != null) {
                                await dbHelper.deleteTodo(todo.id!);
                                loadTodos();
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
      // The button in the bottom right corner used to add new tasks.
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          // showModalBottomSheet slides a new widget up from the bottom of the screen.
          // We wait for it to return a result (true if a task was added).
          final result = await showModalBottomSheet<bool>(
            context: context,
            isScrollControlled: true, // Allows the sheet to take up more screen space if needed
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            builder: (context) => const AddTodoPage(),
          );
          
          // If the AddTodoPage returned true, it means a task was saved.
          // So we need to fetch the updated list from the database.
          if (result == true) {
            loadTodos();
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Task'),
        elevation: 4,
      ),
    );
  }
}
