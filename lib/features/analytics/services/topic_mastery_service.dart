import 'package:supabase_flutter/supabase_flutter.dart';

class TopicMasteryService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Update quiz mastery after quiz completion
  Future<void> updateQuizMastery({
    required String studentId,
    required String topicId,
    required double score,
  }) async {
    await _updateMastery(
      studentId: studentId,
      topicId: topicId,
      quizScore: score,
    );
  }

  /// Update exam mastery after exam completion
  Future<void> updateExamMastery({
    required String studentId,
    required String topicId,
    required double score,
  }) async {
    await _updateMastery(
      studentId: studentId,
      topicId: topicId,
      examScore: score,
    );
  }

  /// Update practice mastery after practice quiz completion
  Future<void> updatePracticeMastery({
    required String studentId,
    required String topicId,
    required double score,
  }) async {
    await _updateMastery(
      studentId: studentId,
      topicId: topicId,
      practiceScore: score,
    );
  }

  /// Update flashcard mastery after review session
  Future<void> updateFlashcardMastery({
    required String studentId,
    required String topicId,
    required double score,
  }) async {
    await _updateMastery(
      studentId: studentId,
      topicId: topicId,
      flashcardScore: score,
    );
  }

  Future<void> _updateMastery({
    required String studentId,
    required String topicId,
    double? quizScore,
    double? examScore,
    double? flashcardScore,
    double? practiceScore,
  }) async {
    final existing = await _supabase
        .from('topic_mastery')
        .select()
        .eq('student_id', studentId)
        .eq('topic_id', topicId)
        .maybeSingle();

    if (existing == null) {
      await _createMasteryRecord(
        studentId: studentId,
        topicId: topicId,
        quizScore: quizScore,
        examScore: examScore,
        flashcardScore: flashcardScore,
        practiceScore: practiceScore,
      );

      return;
    }

    double currentQuiz =
        (existing['quiz_mastery'] as num?)?.toDouble() ?? 0;

    double currentExam =
        (existing['exam_mastery'] as num?)?.toDouble() ?? 0;

    double currentFlashcard =
        (existing['flashcard_mastery'] as num?)?.toDouble() ?? 0;

    double currentPractice =
        (existing['practice_mastery'] as num?)?.toDouble() ?? 0;

    int quizzesTaken =
        (existing['quizzes_taken'] as num?)?.toInt() ?? 0;

    int examsTaken =
        (existing['exams_taken'] as num?)?.toInt() ?? 0;

    int flashcardsReviewed =
        (existing['flashcards_reviewed'] as num?)?.toInt() ?? 0;

    int practiceQuizzesTaken =
        (existing['practice_quizzes_taken'] as num?)?.toInt() ?? 0;

    if (quizScore != null) {
      currentQuiz =
          ((currentQuiz * quizzesTaken) + quizScore) /
          (quizzesTaken + 1);

      quizzesTaken++;
    }

    if (examScore != null) {
      currentExam =
          ((currentExam * examsTaken) + examScore) /
          (examsTaken + 1);

      examsTaken++;
    }

    if (flashcardScore != null) {
      currentFlashcard =
          ((currentFlashcard * flashcardsReviewed) +
                  flashcardScore) /
              (flashcardsReviewed + 1);

      flashcardsReviewed++;
    }

    if (practiceScore != null) {
      currentPractice =
          ((currentPractice * practiceQuizzesTaken) +
                  practiceScore) /
              (practiceQuizzesTaken + 1);

      practiceQuizzesTaken++;
    }

    final overallMastery = calculateOverallMastery(
      flashcardMastery: currentFlashcard,
      quizMastery: currentQuiz,
      examMastery: currentExam,
      practiceMastery: currentPractice,
    );

    final masteryLevel =
        calculateMasteryLevel(overallMastery);

    await _supabase.from('topic_mastery').update({
      'flashcard_mastery': currentFlashcard,
      'quiz_mastery': currentQuiz,
      'exam_mastery': currentExam,
      'practice_mastery': currentPractice,
      'overall_mastery': overallMastery,
      'mastery_level': masteryLevel,
      'quizzes_taken': quizzesTaken,
      'exams_taken': examsTaken,
      'flashcards_reviewed': flashcardsReviewed,
      'practice_quizzes_taken': practiceQuizzesTaken,
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('id', existing['id']);
  }

  Future<void> _createMasteryRecord({
    required String studentId,
    required String topicId,
    double? quizScore,
    double? examScore,
    double? flashcardScore,
    double? practiceScore,
  }) async {
    final flashcardMastery = flashcardScore ?? 0;
    final quizMastery = quizScore ?? 0;
    final examMastery = examScore ?? 0;
    final practiceMastery = practiceScore ?? 0;

    final overallMastery = calculateOverallMastery(
      flashcardMastery: flashcardMastery,
      quizMastery: quizMastery,
      examMastery: examMastery,
      practiceMastery: practiceMastery,
    );

    await _supabase.from('topic_mastery').insert({
      'student_id': studentId,
      'topic_id': topicId,
      'flashcard_mastery': flashcardMastery,
      'quiz_mastery': quizMastery,
      'exam_mastery': examMastery,
      'practice_mastery': practiceMastery,
      'overall_mastery': overallMastery,
      'mastery_level':
          calculateMasteryLevel(overallMastery),
      'quizzes_taken': quizScore != null ? 1 : 0,
      'exams_taken': examScore != null ? 1 : 0,
      'flashcards_reviewed':
          flashcardScore != null ? 1 : 0,
      'practice_quizzes_taken':
          practiceScore != null ? 1 : 0,
    });
  }

  double calculateOverallMastery({
    required double flashcardMastery,
    required double quizMastery,
    required double examMastery,
    required double practiceMastery,
  }) {
    return double.parse(
      (
        (flashcardMastery * 0.20) +
        (quizMastery * 0.30) +
        (examMastery * 0.30) +
        (practiceMastery * 0.20)
      ).toStringAsFixed(2),
    );
  }

  String calculateMasteryLevel(double score) {
    if (score >= 90) {
      return 'Expert';
    }

    if (score >= 80) {
      return 'Mastered';
    }

    if (score >= 70) {
      return 'Proficient';
    }

    if (score >= 60) {
      return 'Developing';
    }

    return 'Needs Improvement';
  }

  Future<Map<String, dynamic>?> getTopicMastery({
    required String studentId,
    required String topicId,
  }) async {
    return await _supabase
        .from('topic_mastery')
        .select()
        .eq('student_id', studentId)
        .eq('topic_id', topicId)
        .maybeSingle();
  }
}