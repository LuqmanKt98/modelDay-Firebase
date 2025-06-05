import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/agent.dart';

class AgentsService {
  final SupabaseClient _supabase = Supabase.instance.client;
  static const String tableName = 'Agent';

  Future<List<Agent>> getAgents() async {
    try {
      final response = await _supabase
          .from(tableName)
          .select('*')
          .order('created_date', ascending: false);

      return (response as List).map((agent) => Agent.fromJson(agent)).toList();
    } catch (e) {
      debugPrint('Error fetching agents: $e');
      return [];
    }
  }

  Future<Agent?> getAgentById(String id) async {
    try {
      final response =
          await _supabase.from(tableName).select('*').eq('id', id).single();

      return Agent.fromJson(response);
    } catch (e) {
      debugPrint('Error fetching agent: $e');
      return null;
    }
  }

  Future<Agent?> createAgent(Agent agent) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final agentData = agent.toJson();
      agentData['created_by'] = user.id;
      agentData['id'] = _generateUuid();
      agentData['created_date'] = DateTime.now().toIso8601String();

      final response =
          await _supabase.from(tableName).insert(agentData).select().single();

      return Agent.fromJson(response);
    } catch (e) {
      debugPrint('Error creating agent: $e');
      return null;
    }
  }

  Future<Agent?> updateAgent(String id, Agent agent) async {
    try {
      final agentData = agent.toJson();
      agentData['updated_date'] = DateTime.now().toIso8601String();

      final response = await _supabase
          .from(tableName)
          .update(agentData)
          .eq('id', id)
          .select()
          .single();

      return Agent.fromJson(response);
    } catch (e) {
      debugPrint('Error updating agent: $e');
      return null;
    }
  }

  Future<bool> deleteAgent(String id) async {
    try {
      await _supabase.from(tableName).delete().eq('id', id);
      return true;
    } catch (e) {
      debugPrint('Error deleting agent: $e');
      return false;
    }
  }

  Future<List<Agent>> getAgentsByCity(String city) async {
    try {
      final response = await _supabase
          .from(tableName)
          .select('*')
          .eq('city', city)
          .order('name', ascending: true);

      return (response as List).map((agent) => Agent.fromJson(agent)).toList();
    } catch (e) {
      debugPrint('Error fetching agents by city: $e');
      return [];
    }
  }

  Future<List<Agent>> searchAgents(String query) async {
    try {
      final response = await _supabase
          .from(tableName)
          .select('*')
          .or('name.ilike.%$query%,email.ilike.%$query%,agency.ilike.%$query%')
          .order('name', ascending: true);

      return (response as List).map((agent) => Agent.fromJson(agent)).toList();
    } catch (e) {
      debugPrint('Error searching agents: $e');
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
