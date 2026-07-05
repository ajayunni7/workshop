// A Model class represents the data structure of an entity in our app.
// Here, the Todo class represents a single task.
class Todo {
  // Properties of a Todo item.
  // 'id' is optional (?) because a new Todo won't have an ID until it's saved in the database.
  final int? id;
  
  // The description of the task.
  final String title;
  
  // Tracks whether the task is finished.
  final bool isComplete;
  
  // The timestamp of when the task was created.
  final DateTime createdAt;
  
  // Constructor for the Todo class.
  // 'required' means a value MUST be provided when creating a Todo object.
  // We provide a default value (false) for isComplete.
  Todo({
    this.id,
    required this.title,
    this.isComplete = false,
    required this.createdAt,
  });
  
  // Helper method to convert a Todo object into a Map (a dictionary-like structure).
  // This is necessary because SQLite databases can only store basic data types,
  // not complex Dart objects. We "serialize" the object into a Map.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      // SQLite doesn't have a boolean type, so we convert true/false to 1/0
      'isComplete': isComplete ? 1 : 0,
      // Convert the DateTime object to a standardized String format
      'createdAt': createdAt.toIso8601String(),
    };
  }
  
  // Helper method to convert a Map back into a Todo object.
  // This is a "factory" method (static) that takes database data and "deserializes" it.
  static Todo fromMap(Map<String, dynamic> map) {
    return Todo(
      id: map['id'] as int?,
      title: map['title'] as String,
      // Convert the integer 1 back to a boolean 'true', and 0 to 'false'
      isComplete: map['isComplete'] == 1,
      // Convert the String timestamp back into a Dart DateTime object
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }
}
