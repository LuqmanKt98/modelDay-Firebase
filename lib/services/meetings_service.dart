import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/meeting.dart';

class MeetingsService {
  final SupabaseClient _supabase = Supabase.instance.client;
  static const String tableName = 'Meeting';

  static Future<List<Meeting>> list() async {
    try {
      final supabase = Supabase.instance.client;
      final response = await supabase
          .from(tableName)
          .select('*')
          .order('created_date', ascending: false);

      return (response as List)
          .map((meeting) => Meeting.fromJson(meeting))
          .toList();
    } catch (e) {
      debugPrint('Error fetching meetings: $e');
      return [];
    }
  }

  Future<List<Meeting>> getMeetings() async {
    try {
      final response = await _supabase
          .from(tableName)
          .select('*')
          .order('created_date', ascending: false);

      return (response as List)
          .map((meeting) => Meeting.fromJson(meeting))
          .toList();
    } catch (e) {
      debugPrint('Error fetching meetings: $e');
      return [];
    }
  }

  Future<Meeting?> getMeetingById(String id) async {
    try {
      final response =
          await _supabase.from(tableName).select('*').eq('id', id).single();

      return Meeting.fromJson(response);
    } catch (e) {
      debugPrint('Error fetching meeting: $e');
      return null;
    }
  }

  Future<Meeting?> createMeeting(Meeting meeting) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final meetingData = meeting.toJson();
      meetingData['created_by'] = user.id;
      meetingData['id'] = _generateUuid();
      meetingData['created_date'] = DateTime.now().toIso8601String();

      final response =
          await _supabase.from(tableName).insert(meetingData).select().single();

      return Meeting.fromJson(response);
    } catch (e) {
      debugPrint('Error creating meeting: $e');
      return null;
    }
  }

  Future<Meeting?> updateMeeting(String id, Meeting meeting) async {
    try {
      final meetingData = meeting.toJson();
      meetingData['updated_date'] = DateTime.now().toIso8601String();

      final response = await _supabase
          .from(tableName)
          .update(meetingData)
          .eq('id', id)
          .select()
          .single();

      return Meeting.fromJson(response);
    } catch (e) {
      debugPrint('Error updating meeting: $e');
      return null;
    }
  }

  Future<bool> deleteMeeting(String id) async {
    try {
      await _supabase.from(tableName).delete().eq('id', id);
      return true;
    } catch (e) {
      debugPrint('Error deleting meeting: $e');
      return false;
    }
  }

  Future<List<Meeting>> getMeetingsByStatus(String status) async {
    try {
      final response = await _supabase
          .from(tableName)
          .select('*')
          .eq('status', status)
          .order('created_date', ascending: false);

      return (response as List)
          .map((meeting) => Meeting.fromJson(meeting))
          .toList();
    } catch (e) {
      debugPrint('Error fetching meetings by status: $e');
      return [];
    }
  }

  Future<List<Meeting>> getUpcomingMeetings() async {
    try {
      final today = DateTime.now().toIso8601String().split('T')[0];
      final response = await _supabase
          .from(tableName)
          .select('*')
          .gte('date', today)
          .order('date', ascending: true);

      return (response as List)
          .map((meeting) => Meeting.fromJson(meeting))
          .toList();
    } catch (e) {
      debugPrint('Error fetching upcoming meetings: $e');
      return [];
    }
  }

  Future<List<Meeting>> getMeetingsByDateRange(
      DateTime startDate, DateTime endDate) async {
    try {
      final response = await _supabase
          .from(tableName)
          .select('*')
          .gte('date', startDate.toIso8601String().split('T')[0])
          .lte('date', endDate.toIso8601String().split('T')[0])
          .order('date', ascending: true);

      return (response as List)
          .map((meeting) => Meeting.fromJson(meeting))
          .toList();
    } catch (e) {
      debugPrint('Error fetching meetings by date range: $e');
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
