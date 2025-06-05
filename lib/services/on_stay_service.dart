import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/on_stay.dart';

class OnStayService {
  static final _supabase = Supabase.instance.client;

  /// Get all OnStay records for the current user
  static Future<List<OnStay>> list() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        debugPrint('No authenticated user found');
        return [];
      }

      final response = await _supabase
          .from('OnStay')
          .select()
          .eq('created_by', user.id)
          .order('created_date', ascending: false);

      return response.map<OnStay>((json) => OnStay.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error fetching OnStay records: $e');
      return [];
    }
  }

  /// Get a specific OnStay record by ID
  static Future<OnStay?> get(String id) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        debugPrint('No authenticated user found');
        return null;
      }

      final response = await _supabase
          .from('OnStay')
          .select()
          .eq('id', id)
          .eq('created_by', user.id)
          .single();

      return OnStay.fromJson(response);
    } catch (e) {
      debugPrint('Error fetching OnStay record: $e');
      return null;
    }
  }

  /// Create a new OnStay record
  static Future<OnStay?> create(Map<String, dynamic> data) async {
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
          .from('OnStay')
          .insert(enrichedData)
          .select()
          .single();

      return OnStay.fromJson(response);
    } catch (e) {
      debugPrint('Error creating OnStay record: $e');
      return null;
    }
  }

  /// Update an existing OnStay record
  static Future<OnStay?> update(String id, Map<String, dynamic> data) async {
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
          .from('OnStay')
          .update(enrichedData)
          .eq('id', id)
          .eq('created_by', user.id)
          .select()
          .single();

      return OnStay.fromJson(response);
    } catch (e) {
      debugPrint('Error updating OnStay record: $e');
      return null;
    }
  }

  /// Delete an OnStay record
  static Future<bool> delete(String id) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        debugPrint('No authenticated user found');
        return false;
      }

      await _supabase
          .from('OnStay')
          .delete()
          .eq('id', id)
          .eq('created_by', user.id);

      return true;
    } catch (e) {
      debugPrint('Error deleting OnStay record: $e');
      return false;
    }
  }

  /// Get OnStay records filtered by status
  static Future<List<OnStay>> getByStatus(String status) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        debugPrint('No authenticated user found');
        return [];
      }

      final response = await _supabase
          .from('OnStay')
          .select()
          .eq('created_by', user.id)
          .eq('status', status)
          .order('created_date', ascending: false);

      return response.map<OnStay>((json) => OnStay.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error fetching OnStay records by status: $e');
      return [];
    }
  }

  /// Get OnStay records filtered by payment status
  static Future<List<OnStay>> getByPaymentStatus(String paymentStatus) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        debugPrint('No authenticated user found');
        return [];
      }

      final response = await _supabase
          .from('OnStay')
          .select()
          .eq('created_by', user.id)
          .eq('payment_status', paymentStatus)
          .order('created_date', ascending: false);

      return response.map<OnStay>((json) => OnStay.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error fetching OnStay records by payment status: $e');
      return [];
    }
  }

  /// Get upcoming OnStay records (check-in date in the future)
  static Future<List<OnStay>> getUpcoming() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        debugPrint('No authenticated user found');
        return [];
      }

      final today = DateTime.now().toIso8601String().split('T')[0];

      final response = await _supabase
          .from('OnStay')
          .select()
          .eq('created_by', user.id)
          .gte('check_in_date', today)
          .order('check_in_date', ascending: true);

      return response.map<OnStay>((json) => OnStay.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error fetching upcoming OnStay records: $e');
      return [];
    }
  }

  /// Get current OnStay records (currently staying)
  static Future<List<OnStay>> getCurrent() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        debugPrint('No authenticated user found');
        return [];
      }

      final today = DateTime.now().toIso8601String().split('T')[0];

      final response = await _supabase
          .from('OnStay')
          .select()
          .eq('created_by', user.id)
          .lte('check_in_date', today)
          .gte('check_out_date', today)
          .order('check_in_date', ascending: false);

      return response.map<OnStay>((json) => OnStay.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error fetching current OnStay records: $e');
      return [];
    }
  }

  /// Get past OnStay records (check-out date in the past)
  static Future<List<OnStay>> getPast() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        debugPrint('No authenticated user found');
        return [];
      }

      final today = DateTime.now().toIso8601String().split('T')[0];

      final response = await _supabase
          .from('OnStay')
          .select()
          .eq('created_by', user.id)
          .lt('check_out_date', today)
          .order('check_out_date', ascending: false);

      return response.map<OnStay>((json) => OnStay.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error fetching past OnStay records: $e');
      return [];
    }
  }

  /// Search OnStay records by location name
  static Future<List<OnStay>> searchByLocation(String query) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        debugPrint('No authenticated user found');
        return [];
      }

      final response = await _supabase
          .from('OnStay')
          .select()
          .eq('created_by', user.id)
          .ilike('location_name', '%$query%')
          .order('created_date', ascending: false);

      return response.map<OnStay>((json) => OnStay.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error searching OnStay records: $e');
      return [];
    }
  }
}
