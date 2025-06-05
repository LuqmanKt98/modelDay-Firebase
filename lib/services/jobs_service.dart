import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/job.dart';

class JobsService {
  static final _supabase = Supabase.instance.client;

  static Future<List<Job>> list() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        debugPrint('No authenticated user found');
        return [];
      }

      final response = await _supabase
          .from('Job')
          .select()
          .eq('created_by', user.id)
          .order('date', ascending: false);

      return response.map<Job>((json) => Job.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error fetching jobs: $e');
      return [];
    }
  }

  static Future<Job?> get(String id) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        debugPrint('No authenticated user found');
        return null;
      }

      final response = await _supabase
          .from('Job')
          .select()
          .eq('id', id)
          .eq('created_by', user.id)
          .single();

      return Job.fromJson(response);
    } catch (e) {
      debugPrint('Error fetching job: $e');
      return null;
    }
  }

  static Future<Job?> create(Map<String, dynamic> data) async {
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
          await _supabase.from('Job').insert(enrichedData).select().single();

      return Job.fromJson(response);
    } catch (e) {
      debugPrint('Error creating job: $e');
      return null;
    }
  }

  static Future<Job?> update(String id, Map<String, dynamic> data) async {
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
          .from('Job')
          .update(enrichedData)
          .eq('id', id)
          .eq('created_by', user.id)
          .select()
          .single();

      return Job.fromJson(response);
    } catch (e) {
      debugPrint('Error updating job: $e');
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
          .from('Job')
          .delete()
          .eq('id', id)
          .eq('created_by', user.id);

      return true;
    } catch (e) {
      debugPrint('Error deleting job: $e');
      return false;
    }
  }

  // Add alias methods for compatibility
  Future<List<Job>> getJobs() async {
    return await list();
  }

  Future<bool> deleteJob(String id) async {
    return await delete(id);
  }
}
