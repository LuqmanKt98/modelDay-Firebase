import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/direct_booking.dart';

class DirectBookingsService {
  static const String tableName = 'DirectBooking';

  static Future<List<DirectBooking>> list() async {
    try {
      final supabase = Supabase.instance.client;
      final response = await supabase
          .from(tableName)
          .select('*')
          .order('created_date', ascending: false);

      return (response as List)
          .map((booking) => DirectBooking.fromJson(booking))
          .toList();
    } catch (e) {
      debugPrint('Error fetching direct bookings: $e');
      return [];
    }
  }

  static Future<DirectBooking?> getById(String id) async {
    try {
      final supabase = Supabase.instance.client;
      final response =
          await supabase.from(tableName).select('*').eq('id', id).single();

      return DirectBooking.fromJson(response);
    } catch (e) {
      debugPrint('Error fetching direct booking: $e');
      return null;
    }
  }

  static Future<DirectBooking?> create(Map<String, dynamic> bookingData) async {
    try {
      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final data = {
        ...bookingData,
        'id': _generateUuid(),
        'created_date': DateTime.now().toIso8601String(),
        'created_by': user.id,
      };

      final response =
          await supabase.from(tableName).insert(data).select().single();

      return DirectBooking.fromJson(response);
    } catch (e) {
      debugPrint('Error creating direct booking: $e');
      return null;
    }
  }

  static Future<DirectBooking?> update(
      String id, Map<String, dynamic> bookingData) async {
    try {
      final supabase = Supabase.instance.client;
      final data = {
        ...bookingData,
        'updated_date': DateTime.now().toIso8601String(),
      };

      final response = await supabase
          .from(tableName)
          .update(data)
          .eq('id', id)
          .select()
          .single();

      return DirectBooking.fromJson(response);
    } catch (e) {
      debugPrint('Error updating direct booking: $e');
      return null;
    }
  }

  static Future<bool> delete(String id) async {
    try {
      final supabase = Supabase.instance.client;
      await supabase.from(tableName).delete().eq('id', id);
      return true;
    } catch (e) {
      debugPrint('Error deleting direct booking: $e');
      return false;
    }
  }

  static Future<List<DirectBooking>> getByDateRange(
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
          .map((booking) => DirectBooking.fromJson(booking))
          .toList();
    } catch (e) {
      debugPrint('Error fetching direct bookings by date range: $e');
      return [];
    }
  }

  static Future<List<DirectBooking>> search(String query) async {
    try {
      final supabase = Supabase.instance.client;
      final response = await supabase
          .from(tableName)
          .select('*')
          .or('client_name.ilike.%$query%,booking_type.ilike.%$query%,location.ilike.%$query%')
          .order('date', ascending: false);

      return (response as List)
          .map((booking) => DirectBooking.fromJson(booking))
          .toList();
    } catch (e) {
      debugPrint('Error searching direct bookings: $e');
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
