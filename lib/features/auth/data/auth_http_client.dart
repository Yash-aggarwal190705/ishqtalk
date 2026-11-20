import 'dart:convert';
import 'package:http/http.dart' as http;

/// HTTP client wrapper that automatically adds authentication headers
/// and handles token refresh
class AuthHttpClient extends http.BaseClient {
  AuthHttpClient({
    required this.baseClient,
    required this.getAccessToken,
    required this.onTokenExpired,
  });

  final http.Client baseClient;
  final Future<String?> Function() getAccessToken;
  final Future<void> Function() onTokenExpired;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    // Add authentication header if available
    final token = await getAccessToken();
    if (token != null && token.isNotEmpty) {
      request.headers['Authorization'] = 'Bearer $token';
    }

    // Add common headers
    request.headers['Accept'] = 'application/json';
    request.headers['X-Platform'] = _getPlatform();
    
    // Send the request
    final response = await baseClient.send(request);

    // Handle token expiration
    if (response.statusCode == 401) {
      await onTokenExpired();
    }

    return response;
  }

  String _getPlatform() {
    // Simple platform detection
    try {
      if (identical(0, 0.0)) {
        return 'web';
      }
    } catch (_) {}
    
    // This will be set properly by the platform
    return 'mobile';
  }

  @override
  void close() {
    baseClient.close();
    super.close();
  }
}

/// Helper for making authenticated API requests
class AuthApiClient {
  AuthApiClient({
    required this.baseUrl,
    required this.getAccessToken,
    required this.onTokenExpired,
    http.Client? httpClient,
  }) : _client = AuthHttpClient(
          baseClient: httpClient ?? http.Client(),
          getAccessToken: getAccessToken,
          onTokenExpired: onTokenExpired,
        );

  final String baseUrl;
  final Future<String?> Function() getAccessToken;
  final Future<void> Function() onTokenExpired;
  final AuthHttpClient _client;

  /// GET request
  Future<http.Response> get(
    String path, {
    Map<String, String>? headers,
    Map<String, dynamic>? queryParameters,
  }) async {
    final uri = _buildUri(path, queryParameters);
    return await _client.get(uri, headers: headers);
  }

  /// POST request
  Future<http.Response> post(
    String path, {
    Map<String, String>? headers,
    Map<String, dynamic>? body,
    Map<String, dynamic>? queryParameters,
  }) async {
    final uri = _buildUri(path, queryParameters);
    return await _client.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        ...?headers,
      },
      body: body != null ? jsonEncode(body) : null,
    );
  }

  /// PUT request
  Future<http.Response> put(
    String path, {
    Map<String, String>? headers,
    Map<String, dynamic>? body,
    Map<String, dynamic>? queryParameters,
  }) async {
    final uri = _buildUri(path, queryParameters);
    return await _client.put(
      uri,
      headers: {
        'Content-Type': 'application/json',
        ...?headers,
      },
      body: body != null ? jsonEncode(body) : null,
    );
  }

  /// PATCH request
  Future<http.Response> patch(
    String path, {
    Map<String, String>? headers,
    Map<String, dynamic>? body,
    Map<String, dynamic>? queryParameters,
  }) async {
    final uri = _buildUri(path, queryParameters);
    return await _client.patch(
      uri,
      headers: {
        'Content-Type': 'application/json',
        ...?headers,
      },
      body: body != null ? jsonEncode(body) : null,
    );
  }

  /// DELETE request
  Future<http.Response> delete(
    String path, {
    Map<String, String>? headers,
    Map<String, dynamic>? queryParameters,
  }) async {
    final uri = _buildUri(path, queryParameters);
    return await _client.delete(uri, headers: headers);
  }

  Uri _buildUri(String path, Map<String, dynamic>? queryParameters) {
    final url = '$baseUrl$path';
    final uri = Uri.parse(url);

    if (queryParameters != null && queryParameters.isNotEmpty) {
      return uri.replace(queryParameters: {
        ...uri.queryParameters,
        ...queryParameters.map((key, value) => MapEntry(key, value.toString())),
      });
    }

    return uri;
  }

  void dispose() {
    _client.close();
  }
}
