import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/shooting.dart';

class ShootingsService {
  final SupabaseClient _supabase = Supabase.instance.client;
  static const String tableName = 'Shooting';

  static Future<List<Shooting>> list() async {
    try {
      final supabase = Supabase.instance.client;
      final response = await supabase
          .from(tableName)
          .select('*')
          .order('created_date', ascending: false);

      return (response as List)
          .map((shooting) => Shooting.fromJson(shooting))
          .toList();
    } catch (e) {
      debugPrint('Error fetching shootings: $e');
      return [];
    }
  }

  Future<List<Shooting>> getShootings() async {
    try {
      final response = await _supabase
          .from(tableName)
          .select('*')
          .order('created_date', ascending: false);

      return (response as List)
          .map((shooting) => Shooting.fromJson(shooting))
          .toList();
    } catch (e) {
      debugPrint('Error fetching shootings: $e');
      return [];
    }
  }

  Future<Shooting?> getShootingById(String id) async {
    try {
      final response =
          await _supabase.from(tableName).select('*').eq('id', id).single();

      return Shooting.fromJson(response);
    } catch (e) {
      debugPrint('Error fetching shooting: $e');
      return null;
    }
  }

  Future<Shooting?> createShooting(Shooting shooting) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final shootingData = shooting.toJson();
      shootingData['created_by'] = user.id;
      shootingData['id'] = _generateUuid();
      shootingData['created_date'] = DateTime.now().toIso8601String();

      final response = await _supabase
          .from(tableName)
          .insert(shootingData)
          .select()
          .single();

      return Shooting.fromJson(response);
    } catch (e) {
      debugPrint('Error creating shooting: $e');
      return null;
    }
  }

  Future<Shooting?> updateShooting(String id, Shooting shooting) async {
    try {
      final shootingData = shooting.toJson();
      shootingData['updated_date'] = DateTime.now().toIso8601String();

      final response = await _supabase
          .from(tableName)
          .update(shootingData)
          .eq('id', id)
          .select()
          .single();

      return Shooting.fromJson(response);
    } catch (e) {
      debugPrint('Error updating shooting: $e');
      return null;
    }
  }

  Future<bool> deleteShooting(String id) async {
    try {
      await _supabase.from(tableName).delete().eq('id', id);
      return true;
    } catch (e) {
      debugPrint('Error deleting shooting: $e');
      return false;
    }
  }

  Future<List<Shooting>> getShootingsByStatus(String status) async {
    try {
      final response = await _supabase
          .from(tableName)
          .select('*')
          .eq('status', status)
          .order('created_date', ascending: false);

      return (response as List)
          .map((shooting) => Shooting.fromJson(shooting))
          .toList();
    } catch (e) {
      debugPrint('Error fetching shootings by status: $e');
      return [];
    }
  }

  Future<List<Shooting>> getShootingsByDateRange(
      DateTime startDate, DateTime endDate) async {
    try {
      final response = await _supabase
          .from(tableName)
          .select('*')
          .gte('date', startDate.toIso8601String().split('T')[0])
          .lte('date', endDate.toIso8601String().split('T')[0])
          .order('date', ascending: true);

      return (response as List)
          .map((shooting) => Shooting.fromJson(shooting))
          .toList();
    } catch (e) {
      debugPrint('Error fetching shootings by date range: $e');
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
