import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_config.dart';
import 'auth_http_client.dart';

/// Example service showing how to use AuthApiClient for authenticated requests
/// 
/// This demonstrates the pattern that other features (profiles, messages, etc.)
/// should follow when making API calls.
class ProfileApiService {
  ProfileApiService({
    required this.getAccessToken,
    required this.onTokenExpired,
    http.Client? httpClient,
  }) : _client = AuthApiClient(
          baseUrl: AuthConfig.current.baseUrl,
          getAccessToken: getAccessToken,
          onTokenExpired: onTokenExpired,
          httpClient: httpClient,
        );

  final Future<String?> Function() getAccessToken;
  final Future<void> Function() onTokenExpired;
  final AuthApiClient _client;

  /// GET /v1/me - Get current user profile
  Future<Map<String, dynamic>?> getCurrentUser() async {
    try {
      final response = await _client.get('/v1/me');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return data['data'] as Map<String, dynamic>?;
      }
      return null;
    } catch (e) {
      print('Error fetching current user: $e');
      return null;
    }
  }

  /// GET /v1/profiles/:id - Get another user's profile
  Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    try {
      final response = await _client.get('/v1/profiles/$userId');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return data['data'] as Map<String, dynamic>?;
      }
      return null;
    } catch (e) {
      print('Error fetching user profile: $e');
      return null;
    }
  }

  /// PATCH /v1/me - Update current user profile
  Future<bool> updateProfile({
    String? displayName,
    String? bio,
  }) async {
    try {
      final response = await _client.patch(
        '/v1/me',
        body: {
          if (displayName != null) 'display_name': displayName,
          if (bio != null) 'bio': bio,
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error updating profile: $e');
      return false;
    }
  }

  /// POST /v1/media/upload - Upload profile photo
  /// This is a simplified example - real implementation would use multipart
  Future<String?> uploadProfilePhoto(String filePath) async {
    try {
      // In a real implementation, you'd use multipart/form-data
      // This is just showing the pattern
      final response = await _client.post(
        '/v1/media/upload',
        body: {
          'type': 'profile_photo',
          'path': filePath,
        },
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final mediaData = data['data'] as Map<String, dynamic>?;
        return mediaData?['url'] as String?;
      }
      return null;
    } catch (e) {
      print('Error uploading photo: $e');
      return null;
    }
  }

  void dispose() {
    _client.dispose();
  }
}

/// Example usage in a widget or state class:
/// 
/// ```dart
/// class ProfileState extends ChangeNotifier {
///   late final ProfileApiService _api;
///   
///   ProfileState({required AuthState authState}) {
///     _api = ProfileApiService(
///       getAccessToken: () async => authState.session?.accessToken,
///       onTokenExpired: () async {
///         await authState.refreshToken();
///       },
///     );
///   }
///   
///   Future<void> loadProfile() async {
///     final profile = await _api.getCurrentUser();
///     // Update state with profile data
///   }
///   
///   @override
///   void dispose() {
///     _api.dispose();
///     super.dispose();
///   }
/// }
/// ```
