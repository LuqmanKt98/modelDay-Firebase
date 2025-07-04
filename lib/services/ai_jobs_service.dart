import 'package:flutter/foundation.dart';
import '../models/ai_job.dart';
import 'firebase_service_template.dart';

class AiJobsService {
  static const String _collectionName = 'ai_jobs';

  static Future<List<AiJob>> list() async {
    try {
      final documents = await FirebaseServiceTemplate.getUserDocuments(_collectionName);
      return documents.map<AiJob>((doc) => AiJob.fromJson(doc)).toList();
    } catch (e) {
      debugPrint('Error fetching AI jobs: $e');
      return [];
    }
  }

  static Future<AiJob?> getById(String id) async {
    try {
      final doc = await FirebaseServiceTemplate.getDocument(_collectionName, id);
      if (doc != null) {
        return AiJob.fromJson(doc);
      }
      return null;
    } catch (e) {
      debugPrint('Error fetching AI job: $e');
      return null;
    }
  }

  static Future<AiJob?> create(Map<String, dynamic> aiJobData) async {
    try {
      final docId = await FirebaseServiceTemplate.createDocument(_collectionName, aiJobData);
      if (docId != null) {
        return await getById(docId);
      }
      return null;
    } catch (e) {
      debugPrint('Error creating AI job: $e');
      return null;
    }
  }

  static Future<AiJob?> update(String id, Map<String, dynamic> aiJobData) async {
    try {
      final success = await FirebaseServiceTemplate.updateDocument(_collectionName, id, aiJobData);
      if (success) {
        return await getById(id);
      }
      return null;
    } catch (e) {
      debugPrint('Error updating AI job: $e');
      return null;
    }
  }

  static Future<bool> delete(String id) async {
    try {
      return await FirebaseServiceTemplate.deleteDocument(_collectionName, id);
    } catch (e) {
      debugPrint('Error deleting AI job: $e');
      return false;
    }
  }

  static Future<List<AiJob>> getByDateRange(DateTime startDate, DateTime endDate) async {
    try {
      final documents = await FirebaseServiceTemplate.getDocumentsByDateRange(
        _collectionName, startDate, endDate, dateField: 'date'
      );
      return documents.map<AiJob>((doc) => AiJob.fromJson(doc)).toList();
    } catch (e) {
      debugPrint('Error fetching AI jobs by date range: $e');
      return [];
    }
  }

  static Future<List<AiJob>> search(String query) async {
    try {
      final documents = await FirebaseServiceTemplate.searchDocuments(_collectionName, 'title', query);
      return documents.map<AiJob>((doc) => AiJob.fromJson(doc)).toList();
    } catch (e) {
      debugPrint('Error searching AI jobs: $e');
      return [];
    }
  }
}
