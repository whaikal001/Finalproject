class Task {
  final int id;
  final String title;
  final String description;
  final String dateAssigned;
  final String dueDate;
  final String status;

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.dateAssigned,
    required this.dueDate,
    required this.status,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'] as int,
      title: json['title'] as String,
      description: json['description'] as String,
      dateAssigned: json['date_assigned'] as String,
      dueDate: json['due_date'] as String,
      status: json['status'] as String,
    );
  }
}