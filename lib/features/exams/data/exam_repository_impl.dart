import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/exam_attempt_answer_model.dart';
import '../models/exam_attempt_model.dart';
import '../models/exam_model.dart';
import '../models/exam_question_model.dart';
import 'exam_repository.dart';

class ExamRepositoryImpl implements ExamRepository {
  final SupabaseClient client;

  ExamRepositoryImpl(this.client);

  @override
  Future<List<ExamModel>> getExams() async {
    final data = await client.from('exams').select().order('created_at');

    return data.map<ExamModel>((e) => ExamModel.fromMap(e)).toList();
  }

  @override
  Future<List<ExamQuestionModel>> getQuestions(String examId) async {
    try {
      final data = await client.rpc(
        'get_exam_questions_safe',
        params: {'p_exam_id': examId},
      );

      return List<Map<String, dynamic>>.from(data)
          .map<ExamQuestionModel>((e) => ExamQuestionModel.fromMap(e))
          .toList();
    } on PostgrestException catch (error) {
      final missingRpc = error.code == '42883' ||
          error.message.toLowerCase().contains('get_exam_questions_safe');

      if (!missingRpc) {
        rethrow;
      }
    }

    final data = await client
        .from('exam_questions')
        .select()
        .eq('exam_id', examId)
        .order('created_at');

    return data.map<ExamQuestionModel>((e) => ExamQuestionModel.fromMap(e)).toList();
  }

  @override
  Future<void> createExam({
    required String title,
    required String description,
    required String subjectId,
    required int passingScore,
    required int timeLimit,
  }) async {
    final user = client.auth.currentUser;

    if (user == null) {
      throw Exception('User not authenticated');
    }

    await client.from('exams').insert({
      'title': title.trim(),
      'description': description.trim(),
      'subject_id': subjectId,
      'passing_score': passingScore,
      'time_limit': timeLimit,
      'created_by': user.id,
    });
  }

  @override
  Future<void> createQuestion({
    required String examId,
    required String questionText,
    required String optionA,
    required String optionB,
    required String optionC,
    required String optionD,
    required String correctAnswer,
  }) async {
    await client.from('exam_questions').insert({
      'exam_id': examId,
      'question_text': questionText.trim(),
      'option_a': optionA.trim(),
      'option_b': optionB.trim(),
      'option_c': optionC.trim(),
      'option_d': optionD.trim(),
      'correct_answer': correctAnswer.trim(),
    });
  }

  @override
  Future<Map<String, dynamic>> submitExam({
    required String examId,
    required double score,
    required bool passed,
    required List<Map<String, dynamic>> answers,
  }) async {
    final user = client.auth.currentUser;

    if (user == null) {
      throw Exception('User not authenticated');
    }

    final sanitizedAnswers = answers.map((answer) {
      return {
        'question_id': answer['question_id'],
        'selected_answer': answer['selected_answer'],
      };
    }).toList();

    try {
      final result = await client.rpc(
        'submit_exam_attempt_secure_result',
        params: {
          'p_exam_id': examId,
          'p_answers': sanitizedAnswers,
        },
      );

      return _asMap(result);
    } on PostgrestException catch (error) {
      final missingRpc = error.code == '42883' ||
          error.message.toLowerCase().contains('submit_exam_attempt_secure_result');

      if (!missingRpc) {
        rethrow;
      }
    }

    try {
      await client.rpc(
        'submit_exam_attempt_secure',
        params: {
          'p_exam_id': examId,
          'p_answers': sanitizedAnswers,
        },
      );

      return {
        'score': score,
        'passed': passed,
        'correct_answers': answers.where((answer) => answer['is_correct'] == true).length,
        'total_questions': answers.length,
      };
    } on PostgrestException catch (error) {
      final missingRpc = error.code == '42883' ||
          error.message.toLowerCase().contains('submit_exam_attempt_secure');

      if (!missingRpc) {
        rethrow;
      }
    }

    return _submitExamLegacy(
      examId: examId,
      score: score,
      passed: passed,
      answers: answers,
      studentId: user.id,
    );
  }

  Future<Map<String, dynamic>> _submitExamLegacy({
    required String examId,
    required double score,
    required bool passed,
    required List<Map<String, dynamic>> answers,
    required String studentId,
  }) async {
    final attempt = await client
        .from('exam_attempts')
        .insert({
          'exam_id': examId,
          'student_id': studentId,
          'score': score,
          'passed': passed,
        })
        .select('id')
        .single();

    final attemptId = attempt['id'] as String;
    final answerRows = answers.map((answer) {
      return {
        'attempt_id': attemptId,
        'question_id': answer['question_id'],
        'selected_answer': answer['selected_answer'],
        'correct_answer': answer['correct_answer'],
        'is_correct': answer['is_correct'],
      };
    }).toList();

    if (answerRows.isNotEmpty) {
      await client.from('exam_attempt_answers').insert(answerRows);
    }

    return {
      'attempt_id': attemptId,
      'score': score,
      'passed': passed,
      'correct_answers': answerRows.where((answer) => answer['is_correct'] == true).length,
      'total_questions': answerRows.length,
    };
  }

  Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map<String, dynamic>) {
      return value;
    }

    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }

    return <String, dynamic>{};
  }

  @override
  Future<List<ExamAttemptModel>> getMyAttempts() async {
    final user = client.auth.currentUser;

    if (user == null) {
      throw Exception('User not authenticated');
    }

    final response = await client
        .from('exam_attempts')
        .select('''
          *,
          exams (
            title
          )
        ''')
        .eq('student_id', user.id)
        .order('created_at', ascending: false);

    return response.map<ExamAttemptModel>((e) => ExamAttemptModel.fromMap(e)).toList();
  }

  @override
  Future<List<ExamAttemptAnswerModel>> getAttemptAnswers(String attemptId) async {
    final response = await client
        .from('exam_attempt_answers')
        .select('''
          *,
          exam_questions (
            question_text,
            option_a,
            option_b,
            option_c,
            option_d
          )
        ''')
        .eq('attempt_id', attemptId);

    return response
        .map<ExamAttemptAnswerModel>((e) => ExamAttemptAnswerModel.fromMap(e))
        .toList();
  }
}
