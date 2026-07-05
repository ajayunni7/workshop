import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/todo.dart';

// DatabaseHelper handles all interactions with the local SQLite database.
class DatabaseHelper {
  // Singleton pattern: This ensures that only one instance of the DatabaseHelper 
  // exists throughout the entire app. It prevents multiple connections to the database,
  // which could cause memory leaks or data corruption.
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  
  // Factory constructor returns the existing instance instead of creating a new one.
  factory DatabaseHelper() => _instance;
  
  // A private constructor used internally by the singleton pattern.
  DatabaseHelper._internal();

  // The actual database instance. It's nullable (?) because it takes time to initialize.
  static Database? _database;

  // Getter for the database. It initializes the database the very first time it is accessed.
  // We use 'async' because database operations take time and we don't want to freeze the app.
  Future<Database> get database async {
    // If we already opened the database, just return it.
    if (_database != null) return _database!;
    
    // Otherwise, initialize it and then return it.
    _database = await _initDatabase();
    return _database!;
  }

  // Opens or creates the database file on the device.
  Future<Database> _initDatabase() async {
    // getDatabasesPath() finds the correct folder to store databases on iOS/Android.
    final dbPath = await getDatabasesPath();
    // join() safely combines the folder path and the file name ('todos.db').
    final path = join(dbPath, 'todos.db');

    // openDatabase creates the file if it doesn't exist, and opens it.
    return await openDatabase(
      path,
      version: 1, // The database version (useful for future upgrades)
      onCreate: (db, version) async {
        // onCreate is only called if the database file didn't exist before.
        await _createTable(db);
      },
    );
  }

  // Creates the 'todos' table structure using standard SQL syntax.
  Future<void> _createTable(Database db) async {
    // execute() runs an SQL command directly.
    await db.execute('''
      CREATE TABLE todos (
        id INTEGER PRIMARY KEY AUTOINCREMENT, -- Auto-generates a unique ID
        title TEXT NOT NULL,                  -- The task name, cannot be empty
        isComplete INTEGER DEFAULT 0,         -- 0 for false, 1 for true
        createdAt TEXT NOT NULL               -- Stored as a string (ISO 8601)
      )
    ''');
  }

  // CREATE: Adds a new todo to the database.
  Future<int> insertTodo(Todo todo) async {
    final db = await database; // Wait to get the database connection
    
    // insert() takes the table name and a Map of the data.
    return await db.insert(
      'todos',
      todo.toMap(), // Converts the Todo object to a Map
      conflictAlgorithm: ConflictAlgorithm.replace, // Overwrites if the ID already exists
    );
  }

  // READ: Retrieves all todos from the database.
  Future<List<Todo>> getAllTodos() async {
    final db = await database;
    
    // query() returns a list of rows, where each row is a Map of column names to values.
    final List<Map<String, dynamic>> maps = await db.query('todos');

    // Convert the List of Maps back into a List of Todo objects so our app can use them.
    return List.generate(maps.length, (i) {
      return Todo.fromMap(maps[i]);
    });
  }

  // UPDATE: Updates an existing todo's data.
  Future<int> updateTodo(Todo todo) async {
    final db = await database;
    
    // update() takes the table name, the new data (as a Map), and a WHERE clause 
    // to specify exactly which row should be updated.
    return await db.update(
      'todos',
      todo.toMap(),
      where: 'id = ?',        // Find the row where the ID matches...
      whereArgs: [todo.id],   // ...this specific ID. We use '?' to prevent SQL injection attacks.
    );
  }

  // DELETE: Removes a todo from the database.
  Future<int> deleteTodo(int id) async {
    final db = await database;
    
    // delete() removes rows matching the WHERE clause.
    return await db.delete(
      'todos', 
      where: 'id = ?', 
      whereArgs: [id]
    );
  }
}
//done