class ExamAttemptModel {
  final String id;

  final String examId;

  final String? examTitle;

  final double score;

  final bool passed;

  final int? rankPosition;

  const ExamAttemptModel({
    required this.id,
    required this.examId,
    this.examTitle,
    required this.score,
    required this.passed,
    this.rankPosition,
  });

  factory ExamAttemptModel.fromMap(
    Map<String, dynamic> map,
  ) {
    return ExamAttemptModel(
      id: map['id'],
      examId: map['exam_id'],
      examTitle:
          map['exams'] != null
              ? map['exams']['title']
              : null,
      score:
          (map['score'] as num)
              .toDouble(),
      passed:
          map['passed'],
      rankPosition:
          map['rank_position'],
    );
  }
}