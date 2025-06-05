import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/direct_options.dart';

class DirectOptionsService {
  static const String tableName = 'DirectOptions';

  static Future<List<DirectOptions>> list() async {
    try {
      final supabase = Supabase.instance.client;
      final response = await supabase
          .from(tableName)
          .select('*')
          .order('created_date', ascending: false);

      return (response as List)
          .map((option) => DirectOptions.fromJson(option))
          .toList();
    } catch (e) {
      debugPrint('Error fetching direct options: $e');
      return [];
    }
  }

  static Future<DirectOptions?> getById(String id) async {
    try {
      final supabase = Supabase.instance.client;
      final response =
          await supabase.from(tableName).select('*').eq('id', id).single();

      return DirectOptions.fromJson(response);
    } catch (e) {
      debugPrint('Error fetching direct option: $e');
      return null;
    }
  }

  static Future<DirectOptions?> create(Map<String, dynamic> optionData) async {
    try {
      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final data = {
        ...optionData,
        'id': _generateUuid(),
        'created_date': DateTime.now().toIso8601String(),
        'created_by': user.id,
      };

      final response =
          await supabase.from(tableName).insert(data).select().single();

      return DirectOptions.fromJson(response);
    } catch (e) {
      debugPrint('Error creating direct option: $e');
      return null;
    }
  }

  static Future<DirectOptions?> update(
      String id, Map<String, dynamic> optionData) async {
    try {
      final supabase = Supabase.instance.client;
      final data = {
        ...optionData,
        'updated_date': DateTime.now().toIso8601String(),
      };

      final response = await supabase
          .from(tableName)
          .update(data)
          .eq('id', id)
          .select()
          .single();

      return DirectOptions.fromJson(response);
    } catch (e) {
      debugPrint('Error updating direct option: $e');
      return null;
    }
  }

  static Future<bool> delete(String id) async {
    try {
      final supabase = Supabase.instance.client;
      await supabase.from(tableName).delete().eq('id', id);
      return true;
    } catch (e) {
      debugPrint('Error deleting direct option: $e');
      return false;
    }
  }

  static Future<List<DirectOptions>> getByDateRange(
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
          .map((option) => DirectOptions.fromJson(option))
          .toList();
    } catch (e) {
      debugPrint('Error fetching direct options by date range: $e');
      return [];
    }
  }

  static Future<List<DirectOptions>> search(String query) async {
    try {
      final supabase = Supabase.instance.client;
      final response = await supabase
          .from(tableName)
          .select('*')
          .or('client_name.ilike.%$query%,option_type.ilike.%$query%,location.ilike.%$query%')
          .order('date', ascending: false);

      return (response as List)
          .map((option) => DirectOptions.fromJson(option))
          .toList();
    } catch (e) {
      debugPrint('Error searching direct options: $e');
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
