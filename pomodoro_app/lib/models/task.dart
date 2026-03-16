class Task {

  final String id;
  final String title;

  int totalPomodoro;
  int completedPomodoro;

  bool completed;
  Task({
    required this.id,
    required this.title,
    required this.totalPomodoro,
    required this.completedPomodoro,
    required this.completed,
  });

  factory Task.fromJson(Map<String, dynamic> json) {

    return Task(
      id: json["_id"],
      title: json["title"],
      totalPomodoro: json["totalPomodoro"] ?? 1,
      completedPomodoro: json["completedPomodoro"] ?? 0,
      completed: json["completed"] ?? false,
    );

  }
}