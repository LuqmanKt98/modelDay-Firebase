import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/casting.dart';

class CastingsService {
  static final _supabase = Supabase.instance.client;

  static Future<List<Casting>> list() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        debugPrint('No authenticated user found');
        return [];
      }

      final response = await _supabase
          .from('Casting')
          .select()
          .eq('created_by', user.id)
          .order('date', ascending: false);

      return response.map<Casting>((json) => Casting.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error fetching castings: $e');
      return [];
    }
  }

  static Future<Casting?> get(String id) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        debugPrint('No authenticated user found');
        return null;
      }

      final response = await _supabase
          .from('Casting')
          .select()
          .eq('id', id)
          .eq('created_by', user.id)
          .single();

      return Casting.fromJson(response);
    } catch (e) {
      debugPrint('Error fetching casting: $e');
      return null;
    }
  }

  static Future<Casting?> create(Map<String, dynamic> data) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        debugPrint('No authenticated user found');
        return null;
      }

      // Add user ID and timestamps
      final enrichedData = {
        ...data,
        'created_by': user.id,
        'created_date': DateTime.now().toIso8601String(),
        'updated_date': DateTime.now().toIso8601String(),
      };

      final response = await _supabase
          .from('Casting')
          .insert(enrichedData)
          .select()
          .single();

      return Casting.fromJson(response);
    } catch (e) {
      debugPrint('Error creating casting: $e');
      return null;
    }
  }

  static Future<Casting?> update(String id, Map<String, dynamic> data) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        debugPrint('No authenticated user found');
        return null;
      }

      // Add updated timestamp
      final enrichedData = {
        ...data,
        'updated_date': DateTime.now().toIso8601String(),
      };

      final response = await _supabase
          .from('Casting')
          .update(enrichedData)
          .eq('id', id)
          .eq('created_by', user.id)
          .select()
          .single();

      return Casting.fromJson(response);
    } catch (e) {
      debugPrint('Error updating casting: $e');
      return null;
    }
  }

  static Future<bool> delete(String id) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        debugPrint('No authenticated user found');
        return false;
      }

      await _supabase
          .from('Casting')
          .delete()
          .eq('id', id)
          .eq('created_by', user.id);

      return true;
    } catch (e) {
      debugPrint('Error deleting casting: $e');
      return false;
    }
  }
}
