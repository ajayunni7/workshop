import 'package:flutter/material.dart';
import '../models/todo.dart';
import '../database/database_helper.dart';
import 'add_todo_page.dart';
import 'edit_todo_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // State variables
  List<Todo> todos = [];
  final DatabaseHelper dbHelper = DatabaseHelper();

  @override
  void initState() {
    super.initState();
    // Fetch todos from database when screen loads
    loadTodos();
  }

  // Refreshes the list on screen by fetching from database
  Future<void> loadTodos() async {
    final result = await dbHelper.getAllTodos();
    setState(() {
      todos = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Todo App"),
      ),
      body: todos.isEmpty
          ? const Center(
              child: Text("No todos. Add one!"),
            )
          : ListView.builder(
              itemCount: todos.length,
              itemBuilder: (context, index) {
                final todo = todos[index];
                return ListTile(
                  leading: Checkbox(
                    value: todo.isComplete,
                    onChanged: (bool? value) async {
                      final updatedTodo = Todo(
                        id: todo.id,
                        title: todo.title,
                        isComplete: !todo.isComplete,
                        createdAt: todo.createdAt,
                      );
                      await dbHelper.updateTodo(updatedTodo);
                      loadTodos();
                    },
                  ),
                  title: GestureDetector(
                    onTap: () async {
                      // Open EditTodoPage
                      final result = await showDialog<bool>(
                        context: context,
                        builder: (context) => EditTodoPage(todo: todo),
                      );
                      
                      if (result == true) {
                        // Refresh list after edit
                        loadTodos();
                      }
                    },
                    child: Text(
                      todo.title,
                      style: TextStyle(
                        decoration: todo.isComplete 
                            ? TextDecoration.lineThrough 
                            : TextDecoration.none,
                        color: todo.isComplete ? Colors.grey : Colors.black,
                      ),
                    ),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Delete Todo?'),
                          content: const Text('This action cannot be undone.'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
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
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await showDialog(
            context: context,
            builder: (context) => const AddTodoPage(),
          );
          
          if (result == true) {
            // User successfully added a new todo, refresh the list
            loadTodos();
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
