import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/polaroid.dart';

class PolaroidsService {
  final SupabaseClient _supabase = Supabase.instance.client;
  static const String tableName = 'Polaroid';

  static Future<List<Polaroid>> list() async {
    try {
      final supabase = Supabase.instance.client;
      final response = await supabase
          .from(tableName)
          .select('*')
          .order('created_date', ascending: false);

      return (response as List)
          .map((polaroid) => Polaroid.fromJson(polaroid))
          .toList();
    } catch (e) {
      debugPrint('Error fetching polaroids: $e');
      return [];
    }
  }

  Future<List<Polaroid>> getPolaroids() async {
    try {
      final response = await _supabase
          .from(tableName)
          .select('*')
          .order('created_date', ascending: false);

      return (response as List)
          .map((polaroid) => Polaroid.fromJson(polaroid))
          .toList();
    } catch (e) {
      debugPrint('Error fetching polaroids: $e');
      return [];
    }
  }

  Future<Polaroid?> getPolaroidById(String id) async {
    try {
      final response =
          await _supabase.from(tableName).select('*').eq('id', id).single();

      return Polaroid.fromJson(response);
    } catch (e) {
      debugPrint('Error fetching polaroid: $e');
      return null;
    }
  }

  Future<Polaroid?> createPolaroid(Polaroid polaroid) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final polaroidData = polaroid.toJson();
      polaroidData['created_by'] = user.id;
      polaroidData['id'] = _generateUuid();
      polaroidData['created_date'] = DateTime.now().toIso8601String();

      final response = await _supabase
          .from(tableName)
          .insert(polaroidData)
          .select()
          .single();

      return Polaroid.fromJson(response);
    } catch (e) {
      debugPrint('Error creating polaroid: $e');
      return null;
    }
  }

  Future<Polaroid?> updatePolaroid(String id, Polaroid polaroid) async {
    try {
      final polaroidData = polaroid.toJson();
      polaroidData['updated_date'] = DateTime.now().toIso8601String();

      final response = await _supabase
          .from(tableName)
          .update(polaroidData)
          .eq('id', id)
          .select()
          .single();

      return Polaroid.fromJson(response);
    } catch (e) {
      debugPrint('Error updating polaroid: $e');
      return null;
    }
  }

  Future<bool> deletePolaroid(String id) async {
    try {
      await _supabase.from(tableName).delete().eq('id', id);
      return true;
    } catch (e) {
      debugPrint('Error deleting polaroid: $e');
      return false;
    }
  }

  Future<List<Polaroid>> getPolaroidsByStatus(String status) async {
    try {
      final response = await _supabase
          .from(tableName)
          .select('*')
          .eq('status', status)
          .order('created_date', ascending: false);

      return (response as List)
          .map((polaroid) => Polaroid.fromJson(polaroid))
          .toList();
    } catch (e) {
      debugPrint('Error fetching polaroids by status: $e');
      return [];
    }
  }

  Future<List<Polaroid>> getPolaroidsByDateRange(
      DateTime startDate, DateTime endDate) async {
    try {
      final response = await _supabase
          .from(tableName)
          .select('*')
          .gte('date', startDate.toIso8601String().split('T')[0])
          .lte('date', endDate.toIso8601String().split('T')[0])
          .order('date', ascending: true);

      return (response as List)
          .map((polaroid) => Polaroid.fromJson(polaroid))
          .toList();
    } catch (e) {
      debugPrint('Error fetching polaroids by date range: $e');
      return [];
    }
  }

  String _generateUuid() {
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
