import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'auth_service.dart';
import 'token_storage_service.dart';

class ApiClient {
  static final _supabase = Supabase.instance.client;
  static AuthService? _authService;

  /// Initialize with auth service reference
  static void initialize(AuthService authService) {
    _authService = authService;
  }

  /// Make authenticated HTTP request with automatic token management
  static Future<Map<String, dynamic>?> request({
    required String method,
    required String endpoint,
    Map<String, dynamic>? data,
    Map<String, String>? headers,
    bool requireAuth = true,
  }) async {
    try {
      // Prepare headers
      final requestHeaders = <String, String>{
        'Content-Type': 'application/json',
        ...?headers,
      };

      // Add authentication if required
      if (requireAuth) {
        final token = await _getValidToken();
        if (token != null) {
          requestHeaders['Authorization'] = 'Bearer $token';
        } else if (requireAuth) {
          throw Exception(
              'Authentication required but no valid token available');
        }
      }

      // Make the request based on method
      dynamic response;

      switch (method.toUpperCase()) {
        case 'GET':
          response = await _supabase
              .from(endpoint)
              .select()
              .withConverter((data) => data);
          break;

        case 'POST':
          if (data != null) {
            response =
                await _supabase.from(endpoint).insert(data).select().single();
          }
          break;

        case 'PUT':
        case 'PATCH':
          if (data != null && data.containsKey('id')) {
            response = await _supabase
                .from(endpoint)
                .update(data)
                .eq('id', data['id'])
                .select()
                .single();
          }
          break;

        case 'DELETE':
          if (data != null && data.containsKey('id')) {
            await _supabase.from(endpoint).delete().eq('id', data['id']);
            response = {'success': true};
          }
          break;

        default:
          throw Exception('Unsupported HTTP method: $method');
      }

      return response is Map<String, dynamic> ? response : {'data': response};
    } catch (e) {
      debugPrint('API request error: $e');

      // Handle authentication errors
      if (e.toString().contains('401') ||
          e.toString().contains('unauthorized')) {
        await _handleAuthError();
      }

      rethrow;
    }
  }

  /// Get a valid access token, refreshing if necessary
  static Future<String?> _getValidToken() async {
    try {
      // Check if current session is valid
      if (_authService != null) {
        final isValid = await _authService!.isSessionValid();
        if (isValid) {
          return await _authService!.getAccessToken();
        }
      }

      // Try to refresh token
      final refreshToken = await TokenStorageService.getRefreshToken();
      if (refreshToken != null && _authService != null) {
        final refreshed = await _authService!.refreshToken();
        if (refreshed) {
          return await _authService!.getAccessToken();
        }
      }

      return null;
    } catch (e) {
      debugPrint('Error getting valid token: $e');
      return null;
    }
  }

  /// Handle authentication errors
  static Future<void> _handleAuthError() async {
    try {
      debugPrint('Handling authentication error - clearing tokens');

      // Clear stored tokens
      await TokenStorageService.clearAll();

      // Force logout through auth service
      if (_authService != null) {
        await _authService!.forceLogout();
      }
    } catch (e) {
      debugPrint('Error handling auth error: $e');
    }
  }

  /// Convenience methods for common HTTP operations

  static Future<Map<String, dynamic>?> get(
    String endpoint, {
    Map<String, String>? headers,
    bool requireAuth = true,
  }) async {
    return request(
      method: 'GET',
      endpoint: endpoint,
      headers: headers,
      requireAuth: requireAuth,
    );
  }

  static Future<Map<String, dynamic>?> post(
    String endpoint,
    Map<String, dynamic> data, {
    Map<String, String>? headers,
    bool requireAuth = true,
  }) async {
    return request(
      method: 'POST',
      endpoint: endpoint,
      data: data,
      headers: headers,
      requireAuth: requireAuth,
    );
  }

  static Future<Map<String, dynamic>?> put(
    String endpoint,
    Map<String, dynamic> data, {
    Map<String, String>? headers,
    bool requireAuth = true,
  }) async {
    return request(
      method: 'PUT',
      endpoint: endpoint,
      data: data,
      headers: headers,
      requireAuth: requireAuth,
    );
  }

  static Future<Map<String, dynamic>?> patch(
    String endpoint,
    Map<String, dynamic> data, {
    Map<String, String>? headers,
    bool requireAuth = true,
  }) async {
    return request(
      method: 'PATCH',
      endpoint: endpoint,
      data: data,
      headers: headers,
      requireAuth: requireAuth,
    );
  }

  static Future<Map<String, dynamic>?> delete(
    String endpoint,
    String id, {
    Map<String, String>? headers,
    bool requireAuth = true,
  }) async {
    return request(
      method: 'DELETE',
      endpoint: endpoint,
      data: {'id': id},
      headers: headers,
      requireAuth: requireAuth,
    );
  }

  /// Upload file with authentication
  static Future<String?> uploadFile({
    required String bucket,
    required String path,
    required Uint8List fileBytes,
    String? contentType,
  }) async {
    try {
      final token = await _getValidToken();
      if (token == null) {
        throw Exception('Authentication required for file upload');
      }

      final response =
          await _supabase.storage.from(bucket).uploadBinary(path, fileBytes);

      if (response.isNotEmpty) {
        return _supabase.storage.from(bucket).getPublicUrl(path);
      }

      return null;
    } catch (e) {
      debugPrint('File upload error: $e');

      if (e.toString().contains('401') ||
          e.toString().contains('unauthorized')) {
        await _handleAuthError();
      }

      rethrow;
    }
  }

  /// Download file with authentication
  static Future<Uint8List?> downloadFile({
    required String bucket,
    required String path,
  }) async {
    try {
      final token = await _getValidToken();
      if (token == null) {
        throw Exception('Authentication required for file download');
      }

      final response = await _supabase.storage.from(bucket).download(path);

      return response;
    } catch (e) {
      debugPrint('File download error: $e');

      if (e.toString().contains('401') ||
          e.toString().contains('unauthorized')) {
        await _handleAuthError();
      }

      rethrow;
    }
  }

  /// Get public URL for file
  static String getPublicUrl({
    required String bucket,
    required String path,
  }) {
    return _supabase.storage.from(bucket).getPublicUrl(path);
  }

  /// Check if user is authenticated
  static Future<bool> isAuthenticated() async {
    final token = await _getValidToken();
    return token != null;
  }

  /// Get current user data
  static Future<Map<String, dynamic>?> getCurrentUser() async {
    try {
      final isAuth = await isAuthenticated();
      if (!isAuth) return null;

      return await TokenStorageService.getUserData();
    } catch (e) {
      debugPrint('Error getting current user: $e');
      return null;
    }
  }
}
