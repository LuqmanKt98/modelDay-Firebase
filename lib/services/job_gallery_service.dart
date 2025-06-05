import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/job_gallery.dart';

class JobGalleryService {
  static const String tableName = 'JobGallery';

  static Future<List<JobGallery>> list() async {
    try {
      final supabase = Supabase.instance.client;
      final response = await supabase
          .from(tableName)
          .select('*')
          .order('created_date', ascending: false);

      return (response as List)
          .map((gallery) => JobGallery.fromJson(gallery))
          .toList();
    } catch (e) {
      debugPrint('Error fetching job galleries: $e');
      return [];
    }
  }

  static Future<JobGallery?> getById(String id) async {
    try {
      final supabase = Supabase.instance.client;
      final response =
          await supabase.from(tableName).select('*').eq('id', id).single();

      return JobGallery.fromJson(response);
    } catch (e) {
      debugPrint('Error fetching job gallery: $e');
      return null;
    }
  }

  static Future<JobGallery?> create(Map<String, dynamic> galleryData) async {
    try {
      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final data = {
        ...galleryData,
        'id': _generateUuid(),
        'created_date': DateTime.now().toIso8601String(),
        'created_by': user.id,
      };

      final response =
          await supabase.from(tableName).insert(data).select().single();

      return JobGallery.fromJson(response);
    } catch (e) {
      debugPrint('Error creating job gallery: $e');
      return null;
    }
  }

  static Future<JobGallery?> update(
      String id, Map<String, dynamic> galleryData) async {
    try {
      final supabase = Supabase.instance.client;
      final data = {
        ...galleryData,
        'updated_date': DateTime.now().toIso8601String(),
      };

      final response = await supabase
          .from(tableName)
          .update(data)
          .eq('id', id)
          .select()
          .single();

      return JobGallery.fromJson(response);
    } catch (e) {
      debugPrint('Error updating job gallery: $e');
      return null;
    }
  }

  static Future<bool> delete(String id) async {
    try {
      final supabase = Supabase.instance.client;
      await supabase.from(tableName).delete().eq('id', id);
      return true;
    } catch (e) {
      debugPrint('Error deleting job gallery: $e');
      return false;
    }
  }

  static Future<List<JobGallery>> getByDateRange(
      DateTime startDate, DateTime endDate) async {
    try {
      final supabase = Supabase.instance.client;
      final response = await supabase
          .from(tableName)
          .select('*')
          .gte('date', startDate.toIso8601String().split('T')[0])
          .lte('date', endDate.toIso8601String().split('T')[0])
          .order('date', ascending: true);

      return (response as List)
          .map((gallery) => JobGallery.fromJson(gallery))
          .toList();
    } catch (e) {
      debugPrint('Error fetching job galleries by date range: $e');
      return [];
    }
  }

  static Future<List<JobGallery>> search(String query) async {
    try {
      final supabase = Supabase.instance.client;
      final response = await supabase
          .from(tableName)
          .select('*')
          .or('name.ilike.%$query%,photographer_name.ilike.%$query%,location.ilike.%$query%')
          .order('date', ascending: false);

      return (response as List)
          .map((gallery) => JobGallery.fromJson(gallery))
          .toList();
    } catch (e) {
      debugPrint('Error searching job galleries: $e');
      return [];
    }
  }

  static String _generateUuid() {
    // Simple UUID v4 generator
    const chars = '0123456789abcdef';
    final random = DateTime.now().millisecondsSinceEpoch;
    var uuid = '';

    for (int i = 0; i < 32; i++) {
      if (i == 8 || i == 12 || i == 16 || i == 20) {
        uuid += '-';
      }
      uuid += chars[(random + i) % chars.length];
    }

    return uuid;
  }
}
