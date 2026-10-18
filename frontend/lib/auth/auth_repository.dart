import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:saranutri/auth/app_session.dart';

abstract interface class AuthRepository {
  Future<AppSession> signIn({required String email, required String password});
}

class HttpAuthRepository implements AuthRepository {
  HttpAuthRepository({required Uri baseUri, required http.Client client})
      : _sessionsUri = _buildSessionsUri(baseUri),
        _client = client;

  final Uri _sessionsUri;
  final http.Client _client;

  @override
  Future<AppSession> signIn({
    required String email,
    required String password,
  }) async {
    final response = await _client.post(
      _sessionsUri,
      headers: const {
        'accept': 'application/json',
        'content-type': 'text/plain; charset=UTF-8',
      },
      body: jsonEncode({'email': email.trim(), 'password': password}),
      encoding: utf8,
    );
    if (response.statusCode == 401) {
      throw const InvalidCredentialsException();
    }
    if (response.statusCode != 201) {
      throw const AuthenticationException();
    }
    try {
      final payload = jsonDecode(utf8.decode(response.bodyBytes));
      return AppSession.fromJson(payload as Map<String, dynamic>);
    } on Object {
      throw const AuthenticationException();
    }
  }

  static Uri _buildSessionsUri(Uri baseUri) {
    final base = baseUri.toString().replaceFirst(RegExp(r'/$'), '');
    return Uri.parse('$base/sessions');
  }
}

class AuthenticationException implements Exception {
  const AuthenticationException();
}

class InvalidCredentialsException extends AuthenticationException {
  const InvalidCredentialsException();
}
