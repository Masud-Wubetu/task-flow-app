class Priority { static const high = 'high'; static const medium = 'medium'; static const low = 'low'; }

class TodoModel {
  final int id;
  final int userId;
  final String title;
  bool completed;
  final String priority;
  final DateTime createdAt;

  TodoModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.completed,
    this.priority = Priority.medium,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory TodoModel.fromJson(Map<String, dynamic> json) {
    return TodoModel(
      id:        json['id'] as int,
      userId:    json['userId'] as int,
      title:     json['title'] as String,
      completed: json['completed'] as bool,
      priority:  _priorityFromId(json['id'] as int),
    );
  }

  Map<String, dynamic> toJson() => {
    'id':        id,
    'userId':    userId,
    'title':     title,
    'completed': completed,
  };

  TodoModel copyWith({
    String? title,
    bool? completed,
    String? priority,
  }) => TodoModel(
    id:        id,
    userId:    userId,
    title:     title ?? this.title,
    completed: completed ?? this.completed,
    priority:  priority ?? this.priority,
    createdAt: createdAt,
  );

  static String _priorityFromId(int id) {
    if (id % 3 == 0) return Priority.high;
    if (id % 3 == 1) return Priority.medium;
    return Priority.low;
  }
}
