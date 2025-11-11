class Task {
  int id;
  String title;
  String project;
  String date;
  bool completed;

  Task({
    required this.id,
    required this.title,
    required this.project,
    required this.date,
    required this.completed,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json["id"],
      title: json["title"],
      project: json["project"],
      date: json["date"],
      completed: json["completed"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "title": title,
      "project": project,
      "date": date,
      "completed": completed,
    };
  }
}
