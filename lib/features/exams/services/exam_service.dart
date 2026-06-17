import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/exam_model.dart';

class ExamService {
  final SupabaseClient _client =
      Supabase.instance.client;

  Future<List<ExamModel>> getExams() async {
    final response =
        await _client
            .from('exams')
            .select()
            .order('title');

    return response
        .map<ExamModel>(
          (exam) =>
              ExamModel.fromMap(exam),
        )
        .toList();
  }
}