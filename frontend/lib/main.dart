import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:http/http.dart' as http;
import 'package:saranutri/l10n/app_localizations.dart';
import 'package:saranutri/patients/patient.dart';
import 'package:saranutri/patients/patient_repository.dart';
import 'package:saranutri/public_site/public_site.dart';
import 'package:saranutri/shared/brand_mark.dart';
import 'package:saranutri/shared/language_menu.dart';

const _apiUrl = String.fromEnvironment(
  'SARANUTRI_API_URL',
  defaultValue: 'http://gemstone.mshome.net:8888',
);

void main() {
  usePathUrlStrategy();
  runApp(
    SaraNutriApp(
      repository: HttpPatientRepository(
        baseUri: Uri.parse(_apiUrl),
        client: http.Client(),
      ),
    ),
  );
}

class SaraNutriApp extends StatefulWidget {
  const SaraNutriApp({
    required this.repository,
    super.key,
    this.initialLocale,
    this.initialRoute,
  });

  final PatientRepository repository;
  final Locale? initialLocale;
  final String? initialRoute;

  @override
  State<SaraNutriApp> createState() => _SaraNutriAppState();
}

class _SaraNutriAppState extends State<SaraNutriApp> {
  Locale? _locale;

  @override
  void initState() {
    super.initState();
    _locale = widget.initialLocale;
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
        '/app': (context) => PatientsPage(
              repository: widget.repository,
              onLocaleChanged: _changeLocale,
              onOpenPublicSite: () => Navigator.of(context)
                  .pushNamedAndRemoveUntil('/', (route) => false),
            ),
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

  void _changeLocale(Locale locale) => setState(() => _locale = locale);
}

class PatientsPage extends StatefulWidget {
  const PatientsPage({
    required this.repository,
    required this.onLocaleChanged,
    required this.onOpenPublicSite,
    super.key,
  });

  final PatientRepository repository;
  final ValueChanged<Locale> onLocaleChanged;
  final VoidCallback onOpenPublicSite;

  @override
  State<PatientsPage> createState() => _PatientsPageState();
}

class _PatientsPageState extends State<PatientsPage> {
  List<Patient> _patients = const [];
  bool _isLoading = true;
  bool _loadFailed = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadPatients();
  }

  Future<void> _loadPatients() async {
    setState(() {
      _isLoading = true;
      _loadFailed = false;
    });
    try {
      final patients = await widget.repository.fetchAll();
      if (!mounted) return;
      setState(() => _patients = patients);
    } on Object {
      if (!mounted) return;
      setState(() => _loadFailed = true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _showAddPatientDialog() async {
    final patient = await showDialog<Patient>(
      context: context,
      builder: (context) => const _AddPatientDialog(),
    );
    if (patient != null && mounted) {
      await _savePatient(patient);
    }
  }

  Future<void> _savePatient(Patient patient) async {
    setState(() => _isSaving = true);
    try {
      final persistedPatient = await widget.repository.add(patient);
      if (!mounted) return;
      setState(() => _patients = [..._patients, persistedPatient]);
    } on Object {
      if (!mounted) return;
      final message = AppLocalizations.of(context).unableToAddPatient;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final addPatient = _isSaving ? null : _showAddPatientDialog;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const BrandMark(size: 34),
            const SizedBox(width: 10),
            Text(localizations.appTitle),
          ],
        ),
        actions: [
          IconButton(
            tooltip: localizations.publicSite,
            onPressed: widget.onOpenPublicSite,
            icon: const Icon(Icons.home_outlined),
          ),
          LanguageMenu(onLocaleChanged: widget.onLocaleChanged),
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: Chip(
              avatar: const Icon(
                Icons.circle,
                size: 10,
                color: Color(0xFF2F7D68),
              ),
              label: Text(localizations.localPrototype),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1080),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 48),
              children: [
                _WelcomePanel(
                  patientCount: _patients.length,
                  onAddPatient: addPatient,
                ),
                const SizedBox(height: 32),
                Row(
                  children: [
                    Text(
                      localizations.patients,
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                    ),
                    const Spacer(),
                    if (_patients.isNotEmpty)
                      FilledButton.icon(
                        key: const ValueKey('add-patient-secondary'),
                        onPressed: addPatient,
                        icon: const Icon(Icons.add),
                        label: Text(localizations.addPatient),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                if (_isLoading)
                  _LoadingPatients(label: localizations.loadingPatients)
                else if (_loadFailed)
                  _LoadFailure(onRetry: _loadPatients)
                else if (_patients.isEmpty)
                  _EmptyPatients(onAddPatient: addPatient)
                else
                  ..._patients.map(
                    (patient) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _PatientCard(patient: patient),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AddPatientDialog extends StatefulWidget {
  const _AddPatientDialog();

  @override
  State<_AddPatientDialog> createState() => _AddPatientDialogState();
}

class _AddPatientDialogState extends State<_AddPatientDialog> {
  final _givenNameController = TextEditingController();
  final _familyNameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  DateTime? _birthDate;

  @override
  void dispose() {
    _givenNameController.dispose();
    _familyNameController.dispose();
    super.dispose();
  }

  String? _requiredField(String? value) {
    return value == null || value.trim().isEmpty
        ? AppLocalizations.of(context).requiredField
        : null;
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return AlertDialog(
      title: Text(localizations.addPatient),
      content: SizedBox(
        width: 420,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                key: const ValueKey('given-name-field'),
                controller: _givenNameController,
                autofocus: true,
                decoration: InputDecoration(labelText: localizations.givenName),
                textInputAction: TextInputAction.next,
                validator: _requiredField,
              ),
              const SizedBox(height: 16),
              TextFormField(
                key: const ValueKey('family-name-field'),
                controller: _familyNameController,
                decoration:
                    InputDecoration(labelText: localizations.familyName),
                textInputAction: TextInputAction.done,
                validator: _requiredField,
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: () async {
                  final selected = await showDatePicker(
                    context: context,
                    firstDate: DateTime(1800),
                    lastDate: DateTime(2200),
                    initialDate: _birthDate ?? DateTime.now(),
                  );
                  if (selected != null) setState(() => _birthDate = selected);
                },
                icon: const Icon(Icons.calendar_month_outlined),
                label: Text(
                  _birthDate == null
                      ? localizations.chooseBirthDate
                      : MaterialLocalizations.of(context)
                          .formatMediumDate(_birthDate!),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(localizations.cancel),
        ),
        FilledButton(
          key: const ValueKey('save-patient'),
          onPressed: () {
            if (!(_formKey.currentState?.validate() ?? false)) return;
            Navigator.pop(
              context,
              Patient(
                givenName: _givenNameController.text,
                familyName: _familyNameController.text,
                birthDate: _birthDate,
              ),
            );
          },
          child: Text(localizations.addPatient),
        ),
      ],
    );
  }
}

class _WelcomePanel extends StatelessWidget {
  const _WelcomePanel({required this.patientCount, required this.onAddPatient});

  final int patientCount;
  final VoidCallback? onAddPatient;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final localizations = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [colorScheme.primary, const Color(0xFF255F5A)],
        ),
        borderRadius: BorderRadius.circular(28),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 620;
          final copy = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                localizations.welcomeTitle,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: 10),
              Text(
                localizations.welcomeDescription,
                style: const TextStyle(color: Color(0xD9FFFFFF), height: 1.45),
              ),
              const SizedBox(height: 22),
              FilledButton.icon(
                key: const ValueKey('add-patient-primary'),
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: colorScheme.primary,
                ),
                onPressed: onAddPatient,
                icon: const Icon(Icons.person_add_alt_1),
                label: Text(localizations.addPatient),
              ),
            ],
          );
          final count = Container(
            constraints: const BoxConstraints(minWidth: 180),
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: const Color(0x1FFFFFFF),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: const Color(0x33FFFFFF)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$patientCount',
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                ),
                Text(
                  localizations.patientProfiles(patientCount),
                  style: const TextStyle(color: Color(0xCCFFFFFF)),
                ),
              ],
            ),
          );
          if (compact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [copy, const SizedBox(height: 24), count],
            );
          }
          return Row(
            children: [
              Expanded(child: copy),
              const SizedBox(width: 36),
              count,
            ],
          );
        },
      ),
    );
  }
}

class _LoadingPatients extends StatelessWidget {
  const _LoadingPatients({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(label),
        ],
      ),
    );
  }
}

class _LoadFailure extends StatelessWidget {
  const _LoadFailure({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    return Card(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          children: [
            const Icon(Icons.cloud_off_outlined, size: 42),
            const SizedBox(height: 12),
            Text(localizations.unableToLoadPatients),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: onRetry,
              child: Text(localizations.retry),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyPatients extends StatelessWidget {
  const _EmptyPatients({required this.onAddPatient});

  final VoidCallback? onAddPatient;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    return Card(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 42),
        child: Column(
          children: [
            Icon(
              Icons.people_outline,
              size: 46,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 14),
            Text(
              localizations.noPatients,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 6),
            Text(localizations.noPatientsDescription,
                textAlign: TextAlign.center),
            const SizedBox(height: 20),
            OutlinedButton.icon(
              onPressed: onAddPatient,
              icon: const Icon(Icons.add),
              label: Text(localizations.addFirstPatient),
            ),
          ],
        ),
      ),
    );
  }
}

class _PatientCard extends StatelessWidget {
  const _PatientCard({required this.patient});

  final Patient patient;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final birthDate = patient.birthDate;
    return Card(
      color: Colors.white,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          child: Text(patient.initials),
        ),
        title: Text(
          patient.displayName,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        subtitle: Text(
          birthDate == null
              ? localizations.birthDateNotProvided
              : localizations.bornOn(
                  MaterialLocalizations.of(context).formatMediumDate(birthDate),
                ),
        ),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}
