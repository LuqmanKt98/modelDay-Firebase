import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/event.dart';

class EventsService {
  final SupabaseClient _supabase = Supabase.instance.client;
  static const String tableName = 'Event';

  Future<List<Event>> getEvents() async {
    try {
      final response = await _supabase
          .from(tableName)
          .select('*')
          .order('date', ascending: false);

      return (response as List).map((event) => Event.fromJson(event)).toList();
    } catch (e) {
      debugPrint('Error fetching events: $e');
      return [];
    }
  }

  Future<List<Event>> getEventsByType(EventType type) async {
    try {
      final response = await _supabase
          .from(tableName)
          .select('*')
          .eq('type', type.toString().split('.').last)
          .order('date', ascending: false);

      return (response as List).map((event) => Event.fromJson(event)).toList();
    } catch (e) {
      debugPrint('Error fetching events by type: $e');
      return [];
    }
  }

  Future<List<Event>> getEventsByDateRange(DateTime start, DateTime end) async {
    try {
      final response = await _supabase
          .from(tableName)
          .select('*')
          .gte('date', start.toIso8601String().split('T')[0])
          .lte('date', end.toIso8601String().split('T')[0])
          .order('date', ascending: true);

      return (response as List).map((event) => Event.fromJson(event)).toList();
    } catch (e) {
      debugPrint('Error fetching events by date range: $e');
      return [];
    }
  }

  Future<Event?> getEventById(String id) async {
    try {
      final response =
          await _supabase.from(tableName).select('*').eq('id', id).single();

      return Event.fromJson(response);
    } catch (e) {
      debugPrint('Error fetching event: $e');
      return null;
    }
  }

  Future<Event?> createEvent(Event event) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final eventData = event.toJson();
      eventData['created_by'] = user.id;
      eventData['id'] = _generateUuid();
      eventData['created_date'] = DateTime.now().toIso8601String();

      final response =
          await _supabase.from(tableName).insert(eventData).select().single();

      return Event.fromJson(response);
    } catch (e) {
      debugPrint('Error creating event: $e');
      return null;
    }
  }

  Future<Event?> updateEvent(String id, Event event) async {
    try {
      final eventData = event.toJson();
      eventData['updated_date'] = DateTime.now().toIso8601String();

      final response = await _supabase
          .from(tableName)
          .update(eventData)
          .eq('id', id)
          .select()
          .single();

      return Event.fromJson(response);
    } catch (e) {
      debugPrint('Error updating event: $e');
      return null;
    }
  }

  Future<bool> deleteEvent(String id) async {
    try {
      await _supabase.from(tableName).delete().eq('id', id);
      return true;
    } catch (e) {
      debugPrint('Error deleting event: $e');
      return false;
    }
  }

  Future<List<Event>> searchEvents(String query) async {
    try {
      final response = await _supabase
          .from(tableName)
          .select('*')
          .or('client_name.ilike.%$query%,location.ilike.%$query%,notes.ilike.%$query%')
          .order('date', ascending: false);

      return (response as List).map((event) => Event.fromJson(event)).toList();
    } catch (e) {
      debugPrint('Error searching events: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>> getEventStats() async {
    try {
      final events = await getEvents();
      
      final stats = <String, dynamic>{
        'total': events.length,
        'byType': <String, int>{},
        'byStatus': <String, int>{},
        'totalRevenue': 0.0,
      };

      double totalRevenue = 0.0;

      for (final event in events) {
        // Count by type
        final typeKey = event.type.toString().split('.').last;
        stats['byType'][typeKey] = (stats['byType'][typeKey] ?? 0) + 1;

        // Count by status
        if (event.status != null) {
          final statusKey = event.status.toString().split('.').last;
          stats['byStatus'][statusKey] = (stats['byStatus'][statusKey] ?? 0) + 1;
        }

        // Calculate revenue
        if (event.dayRate != null) {
          totalRevenue += event.dayRate!;
        }
        if (event.usageRate != null) {
          totalRevenue += event.usageRate!;
        }
      }

      stats['totalRevenue'] = totalRevenue;
      return stats;
    } catch (e) {
      debugPrint('Error getting event stats: $e');
      return {};
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
