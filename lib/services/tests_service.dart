import 'package:flutter/foundation.dart';
import '../models/test.dart';
import 'firebase_service_template.dart';

class TestsService {
  static const String _collectionName = 'tests';

  static Future<List<Test>> list() async {
    try {
      final documents = await FirebaseServiceTemplate.getUserDocuments(_collectionName);
      return documents.map<Test>((doc) => Test.fromJson(doc)).toList();
    } catch (e) {
      debugPrint('Error fetching tests: $e');
      return [];
    }
  }

  static Future<Test?> create(Map<String, dynamic> testData) async {
    try {
      final docId = await FirebaseServiceTemplate.createDocument(_collectionName, testData);
      if (docId != null) {
        final doc = await FirebaseServiceTemplate.getDocument(_collectionName, docId);
        if (doc != null) {
          return Test.fromJson(doc);
        }
      }
      return null;
    } catch (e) {
      debugPrint('Error creating test: $e');
      return null;
    }
  }

  static Future<Test?> update(String id, Map<String, dynamic> testData) async {
    try {
      final success = await FirebaseServiceTemplate.updateDocument(_collectionName, id, testData);
      if (success) {
        final doc = await FirebaseServiceTemplate.getDocument(_collectionName, id);
        if (doc != null) {
          return Test.fromJson(doc);
        }
      }
      return null;
    } catch (e) {
      debugPrint('Error updating test: $e');
      return null;
    }
  }

  static Future<bool> delete(String id) async {
    try {
      return await FirebaseServiceTemplate.deleteDocument(_collectionName, id);
    } catch (e) {
      debugPrint('Error deleting test: $e');
      return false;
    }
  }

  // Compatibility method
  static Future<Test?> get(String id) async {
    try {
      final doc = await FirebaseServiceTemplate.getDocument(_collectionName, id);
      if (doc != null) {
        return Test.fromJson(doc);
      }
      return null;
    } catch (e) {
      debugPrint('Error fetching test: $e');
      return null;
    }
  }
}
