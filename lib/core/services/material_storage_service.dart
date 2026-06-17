import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';

class MaterialStorageService {
  static final _client =
      Supabase.instance.client;

  static Future<String> uploadPdf({
    required Uint8List bytes,
    required String fileName,
  }) async {
    final path =
        'materials/$fileName';

    await _client.storage
        .from('materials')
        .uploadBinary(
          path,
          bytes,
          fileOptions:
              const FileOptions(
            upsert: true,
          ),
        );

    return _client.storage
        .from('materials')
        .getPublicUrl(path);
  }
}