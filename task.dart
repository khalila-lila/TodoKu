class TaskModel {
  final int? id;
  final String title;
  final String priority;
  final String dueDate;
  final bool isDone;

  TaskModel({
    this.id,
    required this.title,
    required this.priority,
    required this.dueDate,
    required this.isDone,
  });

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['id'],
      title: json['title'],
      priority: json['priority'],
      dueDate: json['due_date'],
      isDone: json['is_done'] == 1, // konversi int ke bool
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'priority': priority,
      'due_date': dueDate,
      'is_done': isDone ? 1 : 0, // konversi bool ke int
    };
  }
}
