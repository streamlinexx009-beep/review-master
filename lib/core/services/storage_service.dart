import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';

class StorageService {
  StorageService._();

  static final SupabaseClient _client =
      Supabase.instance.client;

  static Future<String> uploadFile({
    required String bucket,
    required String path,
    required Uint8List bytes,
  }) async {

    await _client.storage
        .from(bucket)
        .uploadBinary(
          path,
          bytes,
          fileOptions:
              const FileOptions(
            upsert: true,
          ),
        );

    return _client.storage
        .from(bucket)
        .getPublicUrl(path);
  }
}