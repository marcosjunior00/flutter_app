class Task {
  int? id;
  int userId; // ID do usuário que criou a tarefa
  String title;
  String project;
  String date;
  bool completed;

  Task({
    this.id,
    required this.userId,
    required this.title,
    required this.project,
    required this.date,
    required this.completed,
  });

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'] as int?,
      userId: map['user_id'] ?? map['userId'] ?? 0,
      title: map['title'] as String,
      project: map['project'] as String,
      date: map['date'] as String,
      completed: map['completed'] is bool 
          ? map['completed'] as bool 
          : (map['completed'] as int) == 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'project': project,
      'date': date,
      'completed': completed ? 1 : 0,
    };
  }

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json["id"],
      userId: json["user_id"] ?? json["userId"] ?? 0,
      title: json["title"],
      project: json["project"],
      date: json["date"],
      completed: json["completed"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "user_id": userId,
      "title": title,
      "project": project,
      "date": date,
      "completed": completed,
    };
  }
}
