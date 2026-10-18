import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:saranutri/auth/app_session.dart';
import 'package:saranutri/auth/auth_repository.dart';

void main() {
  const apiUrl = 'http://gemstone.example:8888';

  test('signIn maps the authenticated session', () async {
    final client = MockClient((request) async {
      expect(request.method, 'POST');
      expect(request.url, Uri.parse('$apiUrl/sessions'));
      expect(jsonDecode(request.body), {
        'email': 'professional@example.com',
        'password': 'secret',
      });
      return http.Response(
        jsonEncode({
          'accessToken': 'token-123',
          'user': {
            'email': 'professional@example.com',
            'displayName': 'Sara',
            'role': 'professional',
          },
        }),
        201,
      );
    });
    final repository = HttpAuthRepository(
      baseUri: Uri.parse(apiUrl),
      client: client,
    );

    final session = await repository.signIn(
      email: ' professional@example.com ',
      password: 'secret',
    );

    expect(session.accessToken, 'token-123');
    expect(session.user.role, UserRole.professional);
  });

  test('signIn reports invalid credentials', () async {
    final repository = HttpAuthRepository(
      baseUri: Uri.parse(apiUrl),
      client: MockClient((_) async => http.Response('{}', 401)),
    );

    expect(
      repository.signIn(email: 'unknown@example.com', password: 'wrong'),
      throwsA(isA<InvalidCredentialsException>()),
    );
  });
}
