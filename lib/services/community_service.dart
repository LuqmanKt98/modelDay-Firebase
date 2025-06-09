import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:new_flutter/models/community_post.dart';

class CommunityService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static const String _collection = 'community_posts';

  /// Get all community posts ordered by timestamp (newest first)
  static Future<List<CommunityPost>> getPosts() async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .orderBy('timestamp', descending: true)
          .limit(50) // Limit to 50 most recent posts
          .get();

      return querySnapshot.docs
          .map((doc) => CommunityPost.fromJson({
                'id': doc.id,
                ...doc.data(),
              }))
          .toList();
    } catch (e) {
      debugPrint('Error getting posts: $e');
      // Return empty list instead of mock data
      return [];
    }
  }

  /// Create a new community post
  static Future<void> createPost(String content, {
    String? category,
    String? location,
    String? date,
    String? time,
    String? contactMethod,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      // Generate tags based on category and content
      List<String> tags = [];
      if (category != null && category != 'All Categories') {
        tags.add(category.toLowerCase().replaceAll(' ', '_'));
      }

      // Add tags based on content keywords
      final contentLower = content.toLowerCase();
      if (contentLower.contains('roommate')) tags.add('roommate');
      if (contentLower.contains('housing')) tags.add('housing');
      if (contentLower.contains('job')) tags.add('jobs');
      if (contentLower.contains('event')) tags.add('events');

      final post = {
        'authorId': user.uid,
        'authorName': user.displayName ?? user.email?.split('@').first ?? 'Anonymous',
        'content': content,
        'timestamp': FieldValue.serverTimestamp(),
        'likes': 0,
        'comments': 0,
        'tags': tags,
        'category': category ?? 'General',
        'location': location,
        'date': date,
        'time': time,
        'contactMethod': contactMethod ?? 'Comments',
      };

      await _firestore.collection(_collection).add(post);
    } catch (e) {
      debugPrint('Error creating post: $e');
      throw Exception('Failed to create post: $e');
    }
  }

  /// Like a post
  static Future<void> likePost(String postId) async {
    try {
      await _firestore.collection(_collection).doc(postId).update({
        'likes': FieldValue.increment(1),
      });
    } catch (e) {
      debugPrint('Error liking post: $e');
      throw Exception('Failed to like post: $e');
    }
  }

  /// Unlike a post
  static Future<void> unlikePost(String postId) async {
    try {
      await _firestore.collection(_collection).doc(postId).update({
        'likes': FieldValue.increment(-1),
      });
    } catch (e) {
      debugPrint('Error unliking post: $e');
      throw Exception('Failed to unlike post: $e');
    }
  }

  /// Get posts by a specific user
  static Future<List<CommunityPost>> getPostsByUser(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('authorId', isEqualTo: userId)
          .orderBy('timestamp', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => CommunityPost.fromJson({
                'id': doc.id,
                ...doc.data(),
              }))
          .toList();
    } catch (e) {
      debugPrint('Error getting user posts: $e');
      return [];
    }
  }

  /// Delete a post (only by the author)
  static Future<void> deletePost(String postId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      // Check if user is the author
      final doc = await _firestore.collection(_collection).doc(postId).get();
      if (!doc.exists) {
        throw Exception('Post not found');
      }

      final postData = doc.data()!;
      if (postData['authorId'] != user.uid) {
        throw Exception('Not authorized to delete this post');
      }

      await _firestore.collection(_collection).doc(postId).delete();
    } catch (e) {
      debugPrint('Error deleting post: $e');
      throw Exception('Failed to delete post: $e');
    }
  }


}
