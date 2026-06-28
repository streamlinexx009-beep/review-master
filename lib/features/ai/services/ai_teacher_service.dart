import 'package:supabase_flutter/supabase_flutter.dart';

class AiTeacherService {
  AiTeacherService(this.client);

  final SupabaseClient client;

  Future<Map<String, dynamic>> run({
    required String action,
    required Map<String, dynamic> payload,
  }) async {
    final response = await client.functions.invoke(
      'ai-teacher-tools',
      body: {
        'action': action,
        ...payload,
      },
    );

    final data = response.data;
    if (data is Map<String, dynamic>) {
      if (data['error'] != null) {
        throw Exception(data['error'].toString());
      }
      return data;
    }

    if (data is Map) {
      final converted = Map<String, dynamic>.from(data);
      if (converted['error'] != null) {
        throw Exception(converted['error'].toString());
      }
      return converted;
    }

    throw Exception('Invalid AI response.');
  }
}
