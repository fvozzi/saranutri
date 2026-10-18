import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:http/http.dart' as http;
import 'package:saranutri/app/app_home.dart';
import 'package:saranutri/appointments/appointment_repository.dart';
import 'package:saranutri/auth/app_session.dart';
import 'package:saranutri/auth/auth_repository.dart';
import 'package:saranutri/auth/login_page.dart';
import 'package:saranutri/l10n/app_localizations.dart';
import 'package:saranutri/patients/patient_repository.dart';
import 'package:saranutri/public_site/public_site.dart';

const _apiUrl = String.fromEnvironment(
  'SARANUTRI_API_URL',
  defaultValue: 'http://gemstone.mshome.net:8888',
);

void main() {
  usePathUrlStrategy();
  final client = http.Client();
  final baseUri = Uri.parse(_apiUrl);
  runApp(
    SaraNutriApp(
      authRepository: HttpAuthRepository(baseUri: baseUri, client: client),
      patientRepository:
          HttpPatientRepository(baseUri: baseUri, client: client),
      appointmentRepository:
          HttpAppointmentRepository(baseUri: baseUri, client: client),
    ),
  );
}

class SaraNutriApp extends StatefulWidget {
  const SaraNutriApp({
    required this.authRepository,
    required this.patientRepository,
    required this.appointmentRepository,
    super.key,
    this.initialLocale,
    this.initialRoute,
    this.initialSession,
  });

  final AuthRepository authRepository;
  final PatientRepository patientRepository;
  final AppointmentRepository appointmentRepository;
  final Locale? initialLocale;
  final String? initialRoute;
  final AppSession? initialSession;

  @override
  State<SaraNutriApp> createState() => _SaraNutriAppState();
}

class _SaraNutriAppState extends State<SaraNutriApp> {
  Locale? _locale;
  AppSession? _session;

  @override
  void initState() {
    super.initState();
    _locale = widget.initialLocale;
    _session = widget.initialSession;
  }

  @override
  Widget build(BuildContext context) {
    const seedColor = Color(0xFF2F7D68);
    return MaterialApp(
      onGenerateTitle: (context) => AppLocalizations.of(context).publicBrand,
      debugShowCheckedModeBanner: false,
      locale: _locale,
      initialRoute: widget.initialRoute,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: seedColor),
        scaffoldBackgroundColor: const Color(0xFFF6F7F2),
        useMaterial3: true,
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
        ),
      ),
      routes: {
        '/': (context) => PublicSite(
              onLocaleChanged: _changeLocale,
              onOpenApp: () => Navigator.of(context).pushNamed('/app'),
            ),
        '/app': (context) => _buildPrivateApp(context),
      },
      onUnknownRoute: (settings) => MaterialPageRoute<void>(
        settings: settings,
        builder: (context) => PublicSite(
          onLocaleChanged: _changeLocale,
          onOpenApp: () => Navigator.of(context).pushNamed('/app'),
        ),
      ),
    );
  }

  Widget _buildPrivateApp(BuildContext context) {
    final session = _session;
    if (session == null) {
      return LoginPage(
        repository: widget.authRepository,
        onSignedIn: (session) => setState(() => _session = session),
        onLocaleChanged: _changeLocale,
        onOpenPublicSite: () => Navigator.of(context)
            .pushNamedAndRemoveUntil('/', (route) => false),
      );
    }
    return AppHome(
      session: session,
      patientRepository: widget.patientRepository,
      appointmentRepository: widget.appointmentRepository,
      onLocaleChanged: _changeLocale,
      onSignOut: () => setState(() => _session = null),
    );
  }

  void _changeLocale(Locale locale) => setState(() => _locale = locale);
}
