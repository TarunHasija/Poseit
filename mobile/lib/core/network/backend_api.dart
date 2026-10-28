import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

/// HTTP client for the FastAPI service. Configure with --dart-define=API_BASE_URL.
final class BackendApi {
  BackendApi({http.Client? client, String? baseUrl})
    : _client = client ?? http.Client(),
      baseUrl =
          (baseUrl ??
                  const String.fromEnvironment(
                    'API_BASE_URL',
                    defaultValue: 'http://10.0.2.2:8000',
                  ))
              .replaceAll(RegExp(r'/+$'), '');

  final http.Client _client;
  final String baseUrl;

  Uri _uri(String path) => Uri.parse('$baseUrl$path');

  Map<String, String> _headers({bool authenticated = false}) {
    final headers = <String, String>{'Accept': 'application/json'};
    if (authenticated) {
      final token = Supabase.instance.client.auth.currentSession?.accessToken;
      if (token == null) throw StateError('Sign in to use the pose library.');
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  dynamic _decode(http.Response response) {
    final body = response.body.isEmpty ? null : jsonDecode(response.body);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      final detail = body is Map ? body['detail'] : null;
      throw BackendApiException(
        detail?.toString() ?? 'Request failed (${response.statusCode})',
      );
    }
    return body;
  }

  Future<Map<String, dynamic>> signup(String email, String password) async {
    final response = await _client.post(
      _uri('/auth/signup'),
      headers: {'Content-Type': 'application/json', ..._headers()},
      body: jsonEncode({'email': email, 'password': password}),
    );
    return Map<String, dynamic>.from(_decode(response) as Map);
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await _client.post(
      _uri('/auth/login'),
      headers: {'Content-Type': 'application/json', ..._headers()},
      body: jsonEncode({'email': email, 'password': password}),
    );
    return Map<String, dynamic>.from(_decode(response) as Map);
  }

  Future<List<Map<String, dynamic>>> listPoses() async {
    final response = await _client.get(
      _uri('/poses'),
      headers: _headers(authenticated: true),
    );
    return (_decode(response) as List).cast<Map<String, dynamic>>();
  }

  Future<Map<String, dynamic>> uploadPose(File file) async {
    final request = http.MultipartRequest('POST', _uri('/poses'))
      ..headers.addAll(_headers(authenticated: true))
      ..files.add(await http.MultipartFile.fromPath('file', file.path));
    final streamed = await _client.send(request);
    return Map<String, dynamic>.from(
      _decode(await http.Response.fromStream(streamed)) as Map,
    );
  }

  /// Fetches one stored image from GET /poses/{id}.
  Future<Uint8List> getPoseImage(String id) async {
    final response = await _client.get(
      _uri('/poses/$id'),
      headers: _headers(authenticated: true),
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      _decode(response);
    }
    return response.bodyBytes;
  }
}

final class BackendApiException implements Exception {
  const BackendApiException(this.message);
  final String message;
  @override
  String toString() => message;
}

final backendApi = BackendApi();
