import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/industry_contact.dart';

class IndustryContactsService {
  final SupabaseClient _supabase = Supabase.instance.client;
  static const String tableName = 'IndustryContact';

  Future<List<IndustryContact>> getIndustryContacts() async {
    try {
      final response = await _supabase
          .from(tableName)
          .select('*')
          .order('created_date', ascending: false);

      return (response as List)
          .map((contact) => IndustryContact.fromJson(contact))
          .toList();
    } catch (e) {
      debugPrint('Error fetching industry contacts: $e');
      return [];
    }
  }

  Future<IndustryContact?> getIndustryContactById(String id) async {
    try {
      final response =
          await _supabase.from(tableName).select('*').eq('id', id).single();

      return IndustryContact.fromJson(response);
    } catch (e) {
      debugPrint('Error fetching industry contact: $e');
      return null;
    }
  }

  Future<IndustryContact?> createIndustryContact(
      IndustryContact contact) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final contactData = contact.toJson();
      contactData['created_by'] = user.id;
      contactData['id'] = _generateUuid();
      contactData['created_date'] = DateTime.now().toIso8601String();

      final response =
          await _supabase.from(tableName).insert(contactData).select().single();

      return IndustryContact.fromJson(response);
    } catch (e) {
      debugPrint('Error creating industry contact: $e');
      return null;
    }
  }

  Future<IndustryContact?> updateIndustryContact(
      String id, IndustryContact contact) async {
    try {
      final contactData = contact.toJson();
      contactData['updated_date'] = DateTime.now().toIso8601String();

      final response = await _supabase
          .from(tableName)
          .update(contactData)
          .eq('id', id)
          .select()
          .single();

      return IndustryContact.fromJson(response);
    } catch (e) {
      debugPrint('Error updating industry contact: $e');
      return null;
    }
  }

  Future<bool> deleteIndustryContact(String id) async {
    try {
      await _supabase.from(tableName).delete().eq('id', id);
      return true;
    } catch (e) {
      debugPrint('Error deleting industry contact: $e');
      return false;
    }
  }

  Future<List<IndustryContact>> getIndustryContactsByCompany(
      String company) async {
    try {
      final response = await _supabase
          .from(tableName)
          .select('*')
          .eq('company', company)
          .order('name', ascending: true);

      return (response as List)
          .map((contact) => IndustryContact.fromJson(contact))
          .toList();
    } catch (e) {
      debugPrint('Error fetching industry contacts by company: $e');
      return [];
    }
  }

  Future<List<IndustryContact>> searchIndustryContacts(String query) async {
    try {
      final response = await _supabase
          .from(tableName)
          .select('*')
          .or('name.ilike.%$query%,email.ilike.%$query%,company.ilike.%$query%,job_title.ilike.%$query%')
          .order('name', ascending: true);

      return (response as List)
          .map((contact) => IndustryContact.fromJson(contact))
          .toList();
    } catch (e) {
      debugPrint('Error searching industry contacts: $e');
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
