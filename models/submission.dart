class Submission {
  final int submissionId;
  final int workId;
  final String taskTitle;
  final String submissionText;
  final String submittedAt;

  Submission({
    required this.submissionId,
    required this.workId,
    required this.taskTitle,
    required this.submissionText,
    required this.submittedAt,
  });

  factory Submission.fromJson(Map<String, dynamic> json) {
    return Submission(
      submissionId: json['submission_id'] as int,
      workId: json['work_id'] as int,
      taskTitle: json['task_title'] as String,
      submissionText: json['submission_text'] as String,
      submittedAt: json['submitted_at'] as String,
    );
  }
}