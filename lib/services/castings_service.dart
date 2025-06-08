import 'package:flutter/foundation.dart';
import '../models/casting.dart';
import 'firebase_service_template.dart';

class CastingsService {
  static const String _collectionName = 'castings';

  static Future<List<Casting>> list() async {
    try {
      final documents = await FirebaseServiceTemplate.getUserDocuments(_collectionName);
      return documents.map<Casting>((doc) => Casting.fromJson(doc)).toList();
    } catch (e) {
      debugPrint('Error fetching castings: $e');
      return [];
    }
  }

  static Future<Casting?> getById(String id) async {
    try {
      final doc = await FirebaseServiceTemplate.getDocument(_collectionName, id);
      if (doc != null) {
        return Casting.fromJson(doc);
      }
      return null;
    } catch (e) {
      debugPrint('Error fetching casting: $e');
      return null;
    }
  }

  static Future<Casting?> create(Map<String, dynamic> castingData) async {
    try {
      final docId = await FirebaseServiceTemplate.createDocument(_collectionName, castingData);
      if (docId != null) {
        return await getById(docId);
      }
      return null;
    } catch (e) {
      debugPrint('Error creating casting: $e');
      return null;
    }
  }

  static Future<Casting?> update(String id, Map<String, dynamic> castingData) async {
    try {
      final success = await FirebaseServiceTemplate.updateDocument(_collectionName, id, castingData);
      if (success) {
        return await getById(id);
      }
      return null;
    } catch (e) {
      debugPrint('Error updating casting: $e');
      return null;
    }
  }

  static Future<bool> delete(String id) async {
    try {
      return await FirebaseServiceTemplate.deleteDocument(_collectionName, id);
    } catch (e) {
      debugPrint('Error deleting casting: $e');
      return false;
    }
  }

  // Compatibility method
  static Future<Casting?> get(String id) async {
    return await getById(id);
  }
}
