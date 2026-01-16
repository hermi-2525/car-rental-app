import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';

class StorageService {
  final _supabase = Supabase.instance.client;

  // Upload image and return URL
  Future<String> uploadImage(XFile file, String path) async {
    try {
      // Use the provided path as the storage path.
      // E.g. if path is "cars/123.jpg", it will be stored at "cars/123.jpg" in the bucket.
      final storagePath = path;

      if (kIsWeb) {
        final bytes = await file.readAsBytes();
        await _supabase.storage
            .from('images')
            .uploadBinary(
              storagePath,
              bytes,
              fileOptions: const FileOptions(upsert: true),
            );
      } else {
        await _supabase.storage
            .from('images')
            .upload(
              storagePath,
              File(file.path),
              fileOptions: const FileOptions(upsert: true),
            );
      }

      final imageUrl = _supabase.storage
          .from('images')
          .getPublicUrl(storagePath);
      return imageUrl;
    } catch (e) {
      throw Exception('Error uploading image: $e');
    }
  }
}
