import 'package:flutter/foundation.dart';
import '../models/direct_options.dart';
import 'firebase_service_template.dart';

class DirectOptionsService {
  static const String _collectionName = 'direct_options';

  static Future<List<DirectOptions>> list() async {
    try {
      final documents = await FirebaseServiceTemplate.getUserDocuments(_collectionName);
      return documents.map<DirectOptions>((doc) => DirectOptions.fromJson(doc)).toList();
    } catch (e) {
      debugPrint('Error fetching direct options: $e');
      return [];
    }
  }

  static Future<DirectOptions?> getById(String id) async {
    try {
      final doc = await FirebaseServiceTemplate.getDocument(_collectionName, id);
      if (doc != null) {
        return DirectOptions.fromJson(doc);
      }
      return null;
    } catch (e) {
      debugPrint('Error fetching direct option: $e');
      return null;
    }
  }

  static Future<DirectOptions?> create(Map<String, dynamic> optionData) async {
    try {
      final docId = await FirebaseServiceTemplate.createDocument(_collectionName, optionData);
      if (docId != null) {
        return await getById(docId);
      }
      return null;
    } catch (e) {
      debugPrint('Error creating direct option: $e');
      return null;
    }
  }

  static Future<DirectOptions?> update(String id, Map<String, dynamic> optionData) async {
    try {
      final success = await FirebaseServiceTemplate.updateDocument(_collectionName, id, optionData);
      if (success) {
        return await getById(id);
      }
      return null;
    } catch (e) {
      debugPrint('Error updating direct option: $e');
      return null;
    }
  }

  static Future<bool> delete(String id) async {
    try {
      return await FirebaseServiceTemplate.deleteDocument(_collectionName, id);
    } catch (e) {
      debugPrint('Error deleting direct option: $e');
      return false;
    }
  }

  static Future<List<DirectOptions>> getByDateRange(DateTime startDate, DateTime endDate) async {
    try {
      final documents = await FirebaseServiceTemplate.getDocumentsByDateRange(
        _collectionName, startDate, endDate, dateField: 'date'
      );
      return documents.map<DirectOptions>((doc) => DirectOptions.fromJson(doc)).toList();
    } catch (e) {
      debugPrint('Error fetching direct options by date range: $e');
      return [];
    }
  }

  static Future<List<DirectOptions>> search(String query) async {
    try {
      final documents = await FirebaseServiceTemplate.searchDocuments(_collectionName, 'title', query);
      return documents.map<DirectOptions>((doc) => DirectOptions.fromJson(doc)).toList();
    } catch (e) {
      debugPrint('Error searching direct options: $e');
      return [];
    }
  }
}
