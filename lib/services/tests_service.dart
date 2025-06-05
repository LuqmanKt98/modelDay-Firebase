import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/test.dart';

class TestsService {
  static final _supabase = Supabase.instance.client;

  static Future<List<Test>> list() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        debugPrint('No authenticated user found');
        return [];
      }

      final response = await _supabase
          .from('Test')
          .select()
          .eq('created_by', user.id)
          .order('date', ascending: false);

      return response.map<Test>((json) => Test.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error fetching tests: $e');
      return [];
    }
  }

  static Future<Test?> get(String id) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        debugPrint('No authenticated user found');
        return null;
      }

      final response = await _supabase
          .from('Test')
          .select()
          .eq('id', id)
          .eq('created_by', user.id)
          .single();

      return Test.fromJson(response);
    } catch (e) {
      debugPrint('Error fetching test: $e');
      return null;
    }
  }

  static Future<Test?> create(Map<String, dynamic> data) async {
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

      final response =
          await _supabase.from('Test').insert(enrichedData).select().single();

      return Test.fromJson(response);
    } catch (e) {
      debugPrint('Error creating test: $e');
      return null;
    }
  }

  static Future<Test?> update(String id, Map<String, dynamic> data) async {
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
          .from('Test')
          .update(enrichedData)
          .eq('id', id)
          .eq('created_by', user.id)
          .select()
          .single();

      return Test.fromJson(response);
    } catch (e) {
      debugPrint('Error updating test: $e');
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
          .from('Test')
          .delete()
          .eq('id', id)
          .eq('created_by', user.id);

      return true;
    } catch (e) {
      debugPrint('Error deleting test: $e');
      return false;
    }
  }
}
