import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/todo.dart';

class DatabaseHelper {
  // Singleton pattern to ensure only one instance of the database exists
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  // Getter for the database, initializes it if it hasn't been already
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  // Opens or creates the database
  Future<Database> _initDatabase() async {
    // Get the default databases location on the device
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'todos.db');

    // Open the database, creating the table if it doesn't exist
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await _createTable(db);
      },
    );
  }

  // Creates the todos table
  Future<void> _createTable(Database db) async {
    await db.execute('''
      CREATE TABLE todos (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        isComplete INTEGER DEFAULT 0,
        createdAt TEXT NOT NULL
      )
    ''');
  }

  // Adds a new todo to the database
  Future<int> insertTodo(Todo todo) async {
    final db = await database;
    return await db.insert(
      'todos',
      todo.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Retrieves all todos from the database
  Future<List<Todo>> getAllTodos() async {
    final db = await database;
    // Query the table for all records
    final List<Map<String, dynamic>> maps = await db.query('todos');

    // Convert the List<Map<String, dynamic>> into a List<Todo>
    return List.generate(maps.length, (i) {
      return Todo.fromMap(maps[i]);
    });
  }

  // Updates an existing todo by id
  Future<int> updateTodo(Todo todo) async {
    final db = await database;
    return await db.update(
      'todos',
      todo.toMap(),
      where: 'id = ?',
      whereArgs: [todo.id],
    );
  }

  // Deletes a todo by id
  Future<int> deleteTodo(int id) async {
    final db = await database;
    return await db.delete('todos', where: 'id = ?', whereArgs: [id]);
  }
}
//done