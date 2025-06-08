import 'package:flutter/foundation.dart';
import '../models/on_stay.dart';
import 'firebase_service_template.dart';

class OnStayService {
  static const String _collectionName = 'on_stay';

  static Future<List<OnStay>> list() async {
    try {
      final documents = await FirebaseServiceTemplate.getUserDocuments(_collectionName);
      return documents.map<OnStay>((doc) => OnStay.fromJson(doc)).toList();
    } catch (e) {
      debugPrint('Error fetching on stay records: $e');
      return [];
    }
  }

  static Future<OnStay?> create(Map<String, dynamic> onStayData) async {
    try {
      final docId = await FirebaseServiceTemplate.createDocument(_collectionName, onStayData);
      if (docId != null) {
        final doc = await FirebaseServiceTemplate.getDocument(_collectionName, docId);
        if (doc != null) {
          return OnStay.fromJson(doc);
        }
      }
      return null;
    } catch (e) {
      debugPrint('Error creating on stay record: $e');
      return null;
    }
  }

  static Future<OnStay?> update(String id, Map<String, dynamic> onStayData) async {
    try {
      final success = await FirebaseServiceTemplate.updateDocument(_collectionName, id, onStayData);
      if (success) {
        final doc = await FirebaseServiceTemplate.getDocument(_collectionName, id);
        if (doc != null) {
          return OnStay.fromJson(doc);
        }
      }
      return null;
    } catch (e) {
      debugPrint('Error updating on stay record: $e');
      return null;
    }
  }

  static Future<bool> delete(String id) async {
    try {
      return await FirebaseServiceTemplate.deleteDocument(_collectionName, id);
    } catch (e) {
      debugPrint('Error deleting on stay record: $e');
      return false;
    }
  }

  static Future<List<OnStay>> getUpcoming() async {
    try {
      final now = DateTime.now();
      final documents = await FirebaseServiceTemplate.getDocumentsByDateRange(
        _collectionName, now, now.add(const Duration(days: 365)), dateField: 'startDate'
      );
      return documents.map<OnStay>((doc) => OnStay.fromJson(doc)).toList();
    } catch (e) {
      debugPrint('Error fetching upcoming on stay records: $e');
      return [];
    }
  }

  static Future<List<OnStay>> getCurrent() async {
    try {
      final now = DateTime.now();
      final documents = await FirebaseServiceTemplate.getDocumentsByDateRange(
        _collectionName, now.subtract(const Duration(days: 30)), now, dateField: 'startDate'
      );
      return documents.map<OnStay>((doc) => OnStay.fromJson(doc)).toList();
    } catch (e) {
      debugPrint('Error fetching current on stay records: $e');
      return [];
    }
  }

  static Future<List<OnStay>> getPast() async {
    try {
      final now = DateTime.now();
      final documents = await FirebaseServiceTemplate.getDocumentsByDateRange(
        _collectionName, now.subtract(const Duration(days: 365)), now.subtract(const Duration(days: 1)), dateField: 'endDate'
      );
      return documents.map<OnStay>((doc) => OnStay.fromJson(doc)).toList();
    } catch (e) {
      debugPrint('Error fetching past on stay records: $e');
      return [];
    }
  }
}
