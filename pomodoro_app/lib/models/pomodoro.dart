class Pomodoro {

  final String id;
  final String userId;
  final String? taskId;
  final int duration;
  final bool completed;
  final DateTime createdAt;

  Pomodoro({
    required this.id,
    required this.userId,
    this.taskId,
    required this.duration,
    required this.completed,
    required this.createdAt,
  });

  factory Pomodoro.fromJson(Map<String, dynamic> json) {
    return Pomodoro(
      id: json["_id"],
      userId: json["userId"],
      taskId: json["taskId"],
      duration: json["duration"] ?? 0,
      completed: json["completed"] ?? false,
      createdAt: DateTime.parse(json["createdAt"]).toLocal(),
    );
  }

}