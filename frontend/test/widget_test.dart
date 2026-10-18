import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saranutri/appointments/appointment.dart';
import 'package:saranutri/appointments/appointment_repository.dart';
import 'package:saranutri/auth/app_session.dart';
import 'package:saranutri/auth/auth_repository.dart';
import 'package:saranutri/main.dart';
import 'package:saranutri/patients/patient.dart';
import 'package:saranutri/patients/patient_repository.dart';

void main() {
  testWidgets('shows the public site at the root route', (tester) async {
    await tester.pumpWidget(buildApp(initialRoute: '/'));
    await tester.pumpAndSettle();

    expect(find.text('Comer mejor puede sentirse simple.'), findsOneWidget);
    expect(find.byKey(const ValueKey('open-app-header')), findsOneWidget);
  });

  testWidgets('opens the login page before the private app', (tester) async {
    await tester.pumpWidget(buildApp(initialRoute: '/'));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('open-app-header')));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('email-field')), findsOneWidget);
    expect(find.byKey(const ValueKey('password-field')), findsOneWidget);
    expect(find.text('Te damos la bienvenida'), findsOneWidget);
  });

  testWidgets('professional signs in and can manage patients', (tester) async {
    final patientRepository = FakePatientRepository([
      const Patient(
        id: 'patient-1',
        givenName: 'Grace',
        familyName: 'Hopper',
      ),
    ]);
    await tester.pumpWidget(
      buildApp(
        initialLocale: const Locale('en'),
        initialRoute: '/app',
        patientRepository: patientRepository,
        authRepository: const FakeAuthRepository(professionalSession),
      ),
    );
    await tester.pumpAndSettle();

    await enterCredentialsAndSignIn(tester);

    expect(find.text('Hopper, Grace'), findsOneWidget);
    expect(find.byKey(const ValueKey('add-patient')), findsOneWidget);
    expect(find.text('Appointments'), findsOneWidget);
  });

  testWidgets('professional persists an added patient', (tester) async {
    final patientRepository = FakePatientRepository();
    await tester.pumpWidget(
      buildApp(
        initialLocale: const Locale('en'),
        initialRoute: '/app',
        initialSession: professionalSession,
        patientRepository: patientRepository,
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('add-patient')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('given-name-field')),
      'Ada',
    );
    await tester.enterText(
      find.byKey(const ValueKey('family-name-field')),
      'Lovelace',
    );
    await tester.tap(find.byKey(const ValueKey('save-patient')));
    await tester.pumpAndSettle();

    expect(patientRepository.added.single.displayName, 'Lovelace, Ada');
    expect(find.text('Lovelace, Ada'), findsOneWidget);
  });

  testWidgets('professional sees appointment assignment controls', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildApp(
        initialLocale: const Locale('en'),
        initialRoute: '/app',
        initialSession: professionalSession,
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Appointments'));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('assign-appointment')), findsOneWidget);
    expect(find.text('No appointments yet'), findsOneWidget);
  });

  testWidgets('professional assigns an appointment to a patient', (
    tester,
  ) async {
    const patient = Patient(
      id: 'patient-1',
      givenName: 'Ada',
      familyName: 'Lovelace',
    );
    final appointmentRepository = FakeAppointmentRepository(
      patients: const [patient],
    );
    await tester.pumpWidget(
      buildApp(
        initialLocale: const Locale('en'),
        initialRoute: '/app',
        initialSession: professionalSession,
        patientRepository: FakePatientRepository(const [patient]),
        appointmentRepository: appointmentRepository,
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Appointments'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('assign-appointment')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('appointment-patient')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Lovelace, Ada').last);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('appointment-date')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('appointment-time')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('save-appointment')));
    await tester.pumpAndSettle();

    expect(appointmentRepository.added, hasLength(1));
    expect(find.text('Lovelace, Ada'), findsOneWidget);
  });

  testWidgets('patient sees only their appointments', (tester) async {
    final appointmentRepository = FakeAppointmentRepository(
      appointments: [
        Appointment(
          id: 'appointment-1',
          patient: const Patient(
            id: 'patient-1',
            givenName: 'Ada',
            familyName: 'Lovelace',
          ),
          scheduledAt: DateTime(2026, 11, 2, 10, 30),
          status: 'scheduled',
        ),
      ],
    );
    await tester.pumpWidget(
      buildApp(
        initialLocale: const Locale('en'),
        initialRoute: '/app',
        initialSession: patientSession,
        appointmentRepository: appointmentRepository,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Lovelace, Ada'), findsOneWidget);
    expect(find.byKey(const ValueKey('add-patient')), findsNothing);
    expect(find.byKey(const ValueKey('assign-appointment')), findsNothing);
    expect(find.text('Patients'), findsNothing);
  });

  testWidgets('invalid credentials remain on the localized login page', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildApp(
        initialLocale: const Locale('pt'),
        initialRoute: '/app',
        authRepository: const FailingAuthRepository(),
      ),
    );
    await tester.pumpAndSettle();

    await enterCredentialsAndSignIn(tester);

    expect(find.text('O e-mail ou a senha estão incorretos.'), findsOneWidget);
    expect(find.byKey(const ValueKey('email-field')), findsOneWidget);
  });

  testWidgets('sign out returns to login', (tester) async {
    await tester.pumpWidget(
      buildApp(
        initialLocale: const Locale('en'),
        initialRoute: '/app',
        initialSession: professionalSession,
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('sign-out')));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('sign-in')), findsOneWidget);
  });
}

Future<void> enterCredentialsAndSignIn(WidgetTester tester) async {
  await tester.enterText(
    find.byKey(const ValueKey('email-field')),
    'user@example.com',
  );
  await tester.enterText(
    find.byKey(const ValueKey('password-field')),
    'secret',
  );
  await tester.tap(find.byKey(const ValueKey('sign-in')));
  await tester.pumpAndSettle();
}

SaraNutriApp buildApp({
  Locale initialLocale = const Locale('es'),
  String initialRoute = '/',
  AppSession? initialSession,
  AuthRepository? authRepository,
  PatientRepository? patientRepository,
  AppointmentRepository? appointmentRepository,
}) {
  return SaraNutriApp(
    authRepository:
        authRepository ?? const FakeAuthRepository(professionalSession),
    patientRepository: patientRepository ?? FakePatientRepository(),
    appointmentRepository: appointmentRepository ?? FakeAppointmentRepository(),
    initialLocale: initialLocale,
    initialRoute: initialRoute,
    initialSession: initialSession,
  );
}

const professionalSession = AppSession(
  accessToken: 'professional-token',
  user: AppUser(
    email: 'professional@example.com',
    displayName: 'Sara',
    role: UserRole.professional,
  ),
);

const patientSession = AppSession(
  accessToken: 'patient-token',
  user: AppUser(
    email: 'patient@example.com',
    displayName: 'Ada Lovelace',
    role: UserRole.patient,
  ),
);

class FakeAuthRepository implements AuthRepository {
  const FakeAuthRepository(this.session);

  final AppSession session;

  @override
  Future<AppSession> signIn({
    required String email,
    required String password,
  }) async =>
      session;
}

class FailingAuthRepository implements AuthRepository {
  const FailingAuthRepository();

  @override
  Future<AppSession> signIn({
    required String email,
    required String password,
  }) async {
    throw const InvalidCredentialsException();
  }
}

class FakePatientRepository implements PatientRepository {
  FakePatientRepository([List<Patient>? patients])
      : _patients = List<Patient>.of(patients ?? const []);

  final List<Patient> _patients;
  final List<Patient> added = [];

  @override
  Future<Patient> add(String accessToken, Patient patient) async {
    final persisted = Patient(
      id: 'patient-${_patients.length + 1}',
      givenName: patient.givenName,
      familyName: patient.familyName,
      birthDate: patient.birthDate,
    );
    added.add(persisted);
    _patients.add(persisted);
    return persisted;
  }

  @override
  Future<List<Patient>> fetchAll(String accessToken) async =>
      List.unmodifiable(_patients);
}

class FakeAppointmentRepository implements AppointmentRepository {
  FakeAppointmentRepository({
    List<Appointment> appointments = const [],
    List<Patient> patients = const [],
  })  : _appointments = List<Appointment>.of(appointments),
        _patients = List<Patient>.of(patients);

  final List<Appointment> _appointments;
  final List<Patient> _patients;
  final List<Appointment> added = [];

  @override
  Future<Appointment> add({
    required String accessToken,
    required String patientId,
    required DateTime scheduledAt,
  }) async {
    final patient = _patients.singleWhere(
      (candidate) => candidate.id == patientId,
    );
    final appointment = Appointment(
      id: 'appointment-${_appointments.length + 1}',
      patient: patient,
      scheduledAt: scheduledAt,
      status: 'scheduled',
    );
    _appointments.add(appointment);
    added.add(appointment);
    return appointment;
  }

  @override
  Future<List<Appointment>> fetchAll(String accessToken) async =>
      List.unmodifiable(_appointments);
}
