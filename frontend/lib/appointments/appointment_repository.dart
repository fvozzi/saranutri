import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:saranutri/appointments/appointment.dart';

abstract interface class AppointmentRepository {
  Future<List<Appointment>> fetchAll(String accessToken);

  Future<Appointment> add({
    required String accessToken,
    required String patientId,
    required DateTime scheduledAt,
  });
}

class HttpAppointmentRepository implements AppointmentRepository {
  HttpAppointmentRepository({required Uri baseUri, required http.Client client})
      : _appointmentsUri = _buildAppointmentsUri(baseUri),
        _client = client;

  final Uri _appointmentsUri;
  final http.Client _client;

  @override
  Future<List<Appointment>> fetchAll(String accessToken) async {
    final response = await _client.get(
      _appointmentsUri,
      headers: _authorizedHeaders(accessToken),
    );
    _requireStatus(response, 200);
    final payload = _decodeJson(response);
    if (payload is! List<dynamic>) {
      throw const AppointmentRepositoryException();
    }
    try {
      return payload
          .map(
            (entry) => Appointment.fromJson(entry as Map<String, dynamic>),
          )
          .toList(growable: false);
    } on Object {
      throw const AppointmentRepositoryException();
    }
  }

  @override
  Future<Appointment> add({
    required String accessToken,
    required String patientId,
    required DateTime scheduledAt,
  }) async {
    final response = await _client.post(
      _appointmentsUri,
      headers: {
        ..._authorizedHeaders(accessToken),
        'content-type': 'text/plain; charset=UTF-8',
      },
      body: jsonEncode({
        'patientId': patientId,
        'scheduledAt': scheduledAt.toUtc().toIso8601String(),
      }),
      encoding: utf8,
    );
    _requireStatus(response, 201);
    try {
      return Appointment.fromJson(
        _decodeJson(response) as Map<String, dynamic>,
      );
    } on Object {
      throw const AppointmentRepositoryException();
    }
  }

  static Map<String, String> _authorizedHeaders(String accessToken) => {
        'accept': 'application/json',
        'authorization': 'Bearer $accessToken',
      };

  static Uri _buildAppointmentsUri(Uri baseUri) {
    final base = baseUri.toString().replaceFirst(RegExp(r'/$'), '');
    return Uri.parse('$base/appointments');
  }

  static Object? _decodeJson(http.Response response) {
    try {
      return jsonDecode(utf8.decode(response.bodyBytes));
    } on FormatException {
      throw const AppointmentRepositoryException();
    }
  }

  static void _requireStatus(http.Response response, int expectedStatus) {
    if (response.statusCode != expectedStatus) {
      throw const AppointmentRepositoryException();
    }
  }
}

class AppointmentRepositoryException implements Exception {
  const AppointmentRepositoryException();
}
