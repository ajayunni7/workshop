class Todo {
  final int? id;
  final String title;
  final bool isComplete;
  final DateTime createdAt;
  
  Todo({
    this.id,
    required this.title,
    this.isComplete = false,
    required this.createdAt,
  });
  
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      // SQLite doesn't have a boolean type, so we store it as 0 or 1
      'isComplete': isComplete ? 1 : 0,
      'createdAt': createdAt.toIso8601String(),
    };
  }
  
  static Todo fromMap(Map<String, dynamic> map) {
    return Todo(
      id: map['id'] as int?,
      title: map['title'] as String,
      isComplete: map['isComplete'] == 1,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }
}
