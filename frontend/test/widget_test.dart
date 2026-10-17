import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saranutri/main.dart';
import 'package:saranutri/patients/patient.dart';
import 'package:saranutri/patients/patient_repository.dart';

void main() {
  testWidgets('shows the public site at the root route', (tester) async {
    await tester.pumpWidget(
      SaraNutriApp(
        repository: FakePatientRepository(),
        initialLocale: const Locale('es'),
        initialRoute: '/',
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Comer mejor puede sentirse simple.'), findsOneWidget);
    expect(find.text('SV Nutrición'), findsWidgets);
    expect(find.byKey(const ValueKey('open-app-header')), findsOneWidget);
  });

  testWidgets('opens the patient app at /app', (tester) async {
    await tester.pumpWidget(
      SaraNutriApp(
        repository: FakePatientRepository(),
        initialLocale: const Locale('en'),
        initialRoute: '/',
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('open-app-header')));
    await tester.pumpAndSettle();

    expect(find.text('No patients yet'), findsOneWidget);
  });

  testWidgets('public site supports mobile and desktop widths', (tester) async {
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    tester.view.devicePixelRatio = 1;

    for (final size in [const Size(390, 844), const Size(1440, 900)]) {
      tester.view.physicalSize = size;
      await tester.pumpWidget(
        SaraNutriApp(
          repository: FakePatientRepository(),
          initialLocale: const Locale('es'),
          initialRoute: '/',
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.byKey(const ValueKey('open-app-header')), findsOneWidget);
    }
  });

  testWidgets('loads patients from the repository', (tester) async {
    final repository = FakePatientRepository([
      const Patient(givenName: 'Grace', familyName: 'Hopper'),
    ]);

    await tester.pumpWidget(
      SaraNutriApp(
        repository: repository,
        initialLocale: const Locale('en'),
        initialRoute: '/app',
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Hopper, Grace'), findsOneWidget);
    expect(find.text('1'), findsOneWidget);
  });

  testWidgets('persists an added patient through the repository', (
    tester,
  ) async {
    final repository = FakePatientRepository();
    await tester.pumpWidget(
      SaraNutriApp(
        repository: repository,
        initialLocale: const Locale('en'),
        initialRoute: '/app',
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('No patients yet'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('add-patient-primary')));
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

    expect(repository.added.single.displayName, 'Lovelace, Ada');
    expect(find.text('Lovelace, Ada'), findsOneWidget);
    expect(find.text('1'), findsOneWidget);
  });

  testWidgets('renders Spanish translations', (tester) async {
    await tester.pumpWidget(
      SaraNutriApp(
        repository: FakePatientRepository(),
        initialLocale: const Locale('es'),
        initialRoute: '/app',
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Atención nutricional, con claridad.'), findsOneWidget);
    expect(find.text('Todavía no hay pacientes'), findsOneWidget);
    expect(find.text('Agregar paciente'), findsOneWidget);
  });

  testWidgets('renders Portuguese translations', (tester) async {
    await tester.pumpWidget(
      SaraNutriApp(
        repository: FakePatientRepository(),
        initialLocale: const Locale('pt'),
        initialRoute: '/app',
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Cuidado nutricional, com clareza.'), findsOneWidget);
    expect(find.text('Ainda não há pacientes'), findsOneWidget);
    expect(find.text('Adicionar paciente'), findsOneWidget);
  });

  testWidgets('changes language from the app bar', (tester) async {
    await tester.pumpWidget(
      SaraNutriApp(
        repository: FakePatientRepository(),
        initialLocale: const Locale('en'),
        initialRoute: '/app',
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.language));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Spanish'));
    await tester.pumpAndSettle();

    expect(find.text('Pacientes'), findsOneWidget);
    expect(find.text('Todavía no hay pacientes'), findsOneWidget);
  });
}

class FakePatientRepository implements PatientRepository {
  FakePatientRepository([List<Patient>? patients])
      : _patients = List<Patient>.of(patients ?? const []);

  final List<Patient> _patients;
  final List<Patient> added = [];

  @override
  Future<Patient> add(Patient patient) async {
    added.add(patient);
    _patients.add(patient);
    return patient;
  }

  @override
  Future<List<Patient>> fetchAll() async => List.unmodifiable(_patients);
}
