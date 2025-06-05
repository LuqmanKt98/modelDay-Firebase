import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/agency.dart';

class AgenciesService {
  static const String tableName = 'Agency';

  static Future<List<Agency>> list() async {
    try {
      final supabase = Supabase.instance.client;
      final response = await supabase
          .from(tableName)
          .select('*')
          .order('created_date', ascending: false);

      return (response as List)
          .map((agency) => Agency.fromJson(agency))
          .toList();
    } catch (e) {
      debugPrint('Error fetching agencies: $e');
      return [];
    }
  }

  static Future<Agency?> getById(String id) async {
    try {
      final supabase = Supabase.instance.client;
      final response =
          await supabase.from(tableName).select('*').eq('id', id).single();

      return Agency.fromJson(response);
    } catch (e) {
      debugPrint('Error fetching agency: $e');
      return null;
    }
  }

  static Future<Agency?> create(Map<String, dynamic> agencyData) async {
    try {
      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final data = {
        ...agencyData,
        'id': _generateUuid(),
        'created_date': DateTime.now().toIso8601String(),
        'created_by': user.id,
      };

      final response =
          await supabase.from(tableName).insert(data).select().single();

      return Agency.fromJson(response);
    } catch (e) {
      debugPrint('Error creating agency: $e');
      return null;
    }
  }

  static Future<Agency?> update(
      String id, Map<String, dynamic> agencyData) async {
    try {
      final supabase = Supabase.instance.client;
      final data = {
        ...agencyData,
        'updated_date': DateTime.now().toIso8601String(),
      };

      final response = await supabase
          .from(tableName)
          .update(data)
          .eq('id', id)
          .select()
          .single();

      return Agency.fromJson(response);
    } catch (e) {
      debugPrint('Error updating agency: $e');
      return null;
    }
  }

  static Future<bool> delete(String id) async {
    try {
      final supabase = Supabase.instance.client;
      await supabase.from(tableName).delete().eq('id', id);
      return true;
    } catch (e) {
      debugPrint('Error deleting agency: $e');
      return false;
    }
  }

  static Future<List<Agency>> search(String query) async {
    try {
      final supabase = Supabase.instance.client;
      final response = await supabase
          .from(tableName)
          .select('*')
          .or('name.ilike.%$query%,city.ilike.%$query%,country.ilike.%$query%')
          .order('name', ascending: true);

      return (response as List)
          .map((agency) => Agency.fromJson(agency))
          .toList();
    } catch (e) {
      debugPrint('Error searching agencies: $e');
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
