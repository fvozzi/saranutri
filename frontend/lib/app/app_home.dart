import 'package:flutter/material.dart';
import 'package:saranutri/appointments/appointment.dart';
import 'package:saranutri/appointments/appointment_repository.dart';
import 'package:saranutri/auth/app_session.dart';
import 'package:saranutri/l10n/app_localizations.dart';
import 'package:saranutri/patients/patient.dart';
import 'package:saranutri/patients/patient_repository.dart';
import 'package:saranutri/shared/brand_mark.dart';
import 'package:saranutri/shared/language_menu.dart';

class AppHome extends StatelessWidget {
  const AppHome({
    required this.session,
    required this.patientRepository,
    required this.appointmentRepository,
    required this.onLocaleChanged,
    required this.onSignOut,
    super.key,
  });

  final AppSession session;
  final PatientRepository patientRepository;
  final AppointmentRepository appointmentRepository;
  final ValueChanged<Locale> onLocaleChanged;
  final VoidCallback onSignOut;

  @override
  Widget build(BuildContext context) {
    return switch (session.user.role) {
      UserRole.professional => ProfessionalHome(
          session: session,
          patientRepository: patientRepository,
          appointmentRepository: appointmentRepository,
          onLocaleChanged: onLocaleChanged,
          onSignOut: onSignOut,
        ),
      UserRole.patient => PatientHome(
          session: session,
          appointmentRepository: appointmentRepository,
          onLocaleChanged: onLocaleChanged,
          onSignOut: onSignOut,
        ),
    };
  }
}

class ProfessionalHome extends StatefulWidget {
  const ProfessionalHome({
    required this.session,
    required this.patientRepository,
    required this.appointmentRepository,
    required this.onLocaleChanged,
    required this.onSignOut,
    super.key,
  });

  final AppSession session;
  final PatientRepository patientRepository;
  final AppointmentRepository appointmentRepository;
  final ValueChanged<Locale> onLocaleChanged;
  final VoidCallback onSignOut;

  @override
  State<ProfessionalHome> createState() => _ProfessionalHomeState();
}

class _ProfessionalHomeState extends State<ProfessionalHome> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final pages = [
      PatientsView(
        session: widget.session,
        repository: widget.patientRepository,
      ),
      AppointmentsView(
        session: widget.session,
        repository: widget.appointmentRepository,
        patientRepository: widget.patientRepository,
        canAssign: true,
      ),
    ];
    return _AuthenticatedScaffold(
      session: widget.session,
      onLocaleChanged: widget.onLocaleChanged,
      onSignOut: widget.onSignOut,
      body: IndexedStack(index: _selectedIndex, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (value) =>
            setState(() => _selectedIndex = value),
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.people_outline),
            selectedIcon: const Icon(Icons.people),
            label: localizations.patients,
          ),
          NavigationDestination(
            icon: const Icon(Icons.calendar_month_outlined),
            selectedIcon: const Icon(Icons.calendar_month),
            label: localizations.appointments,
          ),
        ],
      ),
    );
  }
}

class PatientHome extends StatelessWidget {
  const PatientHome({
    required this.session,
    required this.appointmentRepository,
    required this.onLocaleChanged,
    required this.onSignOut,
    super.key,
  });

  final AppSession session;
  final AppointmentRepository appointmentRepository;
  final ValueChanged<Locale> onLocaleChanged;
  final VoidCallback onSignOut;

  @override
  Widget build(BuildContext context) {
    return _AuthenticatedScaffold(
      session: session,
      onLocaleChanged: onLocaleChanged,
      onSignOut: onSignOut,
      body: AppointmentsView(
        session: session,
        repository: appointmentRepository,
        canAssign: false,
      ),
    );
  }
}

class _AuthenticatedScaffold extends StatelessWidget {
  const _AuthenticatedScaffold({
    required this.session,
    required this.onLocaleChanged,
    required this.onSignOut,
    required this.body,
    this.bottomNavigationBar,
  });

  final AppSession session;
  final ValueChanged<Locale> onLocaleChanged;
  final VoidCallback onSignOut;
  final Widget body;
  final Widget? bottomNavigationBar;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
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
          if (MediaQuery.sizeOf(context).width >= 620)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Center(child: Text(session.user.displayName)),
            ),
          LanguageMenu(onLocaleChanged: onLocaleChanged),
          IconButton(
            key: const ValueKey('sign-out'),
            tooltip: localizations.signOut,
            onPressed: onSignOut,
            icon: const Icon(Icons.logout),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(child: body),
      bottomNavigationBar: bottomNavigationBar,
    );
  }
}

class PatientsView extends StatefulWidget {
  const PatientsView({
    required this.session,
    required this.repository,
    super.key,
  });

  final AppSession session;
  final PatientRepository repository;

  @override
  State<PatientsView> createState() => _PatientsViewState();
}

class _PatientsViewState extends State<PatientsView> {
  List<Patient> _patients = const [];
  bool _isLoading = true;
  bool _loadFailed = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _loadFailed = false;
    });
    try {
      final patients =
          await widget.repository.fetchAll(widget.session.accessToken);
      if (mounted) setState(() => _patients = patients);
    } on Object {
      if (mounted) setState(() => _loadFailed = true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _showAddDialog() async {
    final patient = await showDialog<Patient>(
      context: context,
      builder: (context) => const _AddPatientDialog(),
    );
    if (patient == null || !mounted) return;
    setState(() => _isSaving = true);
    try {
      final persisted = await widget.repository.add(
        widget.session.accessToken,
        patient,
      );
      if (mounted) setState(() => _patients = [..._patients, persisted]);
    } on Object {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).unableToAddPatient),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    return _PageFrame(
      title: localizations.patients,
      action: FilledButton.icon(
        key: const ValueKey('add-patient'),
        onPressed: _isSaving ? null : _showAddDialog,
        icon: const Icon(Icons.person_add_alt_1),
        label: Text(localizations.addPatient),
      ),
      child: _isLoading
          ? _Loading(label: localizations.loadingPatients)
          : _loadFailed
              ? _Failure(
                  message: localizations.unableToLoadPatients,
                  onRetry: _load,
                )
              : _patients.isEmpty
                  ? _Empty(
                      icon: Icons.people_outline,
                      title: localizations.noPatients,
                      description: localizations.noPatientsDescription,
                    )
                  : Column(
                      children: _patients
                          .map(
                            (patient) => Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _PatientCard(patient: patient),
                            ),
                          )
                          .toList(growable: false),
                    ),
    );
  }
}

class AppointmentsView extends StatefulWidget {
  const AppointmentsView({
    required this.session,
    required this.repository,
    required this.canAssign,
    super.key,
    this.patientRepository,
  });

  final AppSession session;
  final AppointmentRepository repository;
  final PatientRepository? patientRepository;
  final bool canAssign;

  @override
  State<AppointmentsView> createState() => _AppointmentsViewState();
}

class _AppointmentsViewState extends State<AppointmentsView> {
  List<Appointment> _appointments = const [];
  bool _isLoading = true;
  bool _loadFailed = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _loadFailed = false;
    });
    try {
      final appointments =
          await widget.repository.fetchAll(widget.session.accessToken);
      if (mounted) setState(() => _appointments = appointments);
    } on Object {
      if (mounted) setState(() => _loadFailed = true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _showAssignDialog() async {
    final patientRepository = widget.patientRepository;
    if (patientRepository == null) return;
    List<Patient> patients;
    try {
      patients = await patientRepository.fetchAll(widget.session.accessToken);
    } on Object {
      if (mounted) _showAssignmentFailure();
      return;
    }
    if (!mounted) return;
    if (patients.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).addPatientFirst)),
      );
      return;
    }
    final request = await showDialog<_AppointmentRequest>(
      context: context,
      builder: (context) => _AssignAppointmentDialog(patients: patients),
    );
    if (request == null || !mounted) return;
    setState(() => _isSaving = true);
    try {
      final appointment = await widget.repository.add(
        accessToken: widget.session.accessToken,
        patientId: request.patient.id,
        scheduledAt: request.scheduledAt,
      );
      if (mounted) {
        setState(() => _appointments = [..._appointments, appointment]..sort(
            (first, second) =>
                first.scheduledAt.compareTo(second.scheduledAt)));
      }
    } on Object {
      if (mounted) _showAssignmentFailure();
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _showAssignmentFailure() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context).unableToAssignAppointment),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    return _PageFrame(
      title: localizations.appointments,
      action: widget.canAssign
          ? FilledButton.icon(
              key: const ValueKey('assign-appointment'),
              onPressed: _isSaving ? null : _showAssignDialog,
              icon: const Icon(Icons.add),
              label: Text(localizations.assignAppointment),
            )
          : null,
      child: _isLoading
          ? _Loading(label: localizations.loadingAppointments)
          : _loadFailed
              ? _Failure(
                  message: localizations.unableToLoadAppointments,
                  onRetry: _load,
                )
              : _appointments.isEmpty
                  ? _Empty(
                      icon: Icons.event_available_outlined,
                      title: localizations.noAppointments,
                      description: widget.canAssign
                          ? localizations.noProfessionalAppointmentsDescription
                          : localizations.noPatientAppointmentsDescription,
                    )
                  : Column(
                      children: _appointments
                          .map(
                            (appointment) => Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _AppointmentCard(appointment: appointment),
                            ),
                          )
                          .toList(growable: false),
                    ),
    );
  }
}

class _PageFrame extends StatelessWidget {
  const _PageFrame({required this.title, required this.child, this.action});

  final String title;
  final Widget child;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1080),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 48),
          children: [
            Wrap(
              spacing: 16,
              runSpacing: 12,
              crossAxisAlignment: WrapCrossAlignment.center,
              alignment: WrapAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
                if (action case final action?) action,
              ],
            ),
            const SizedBox(height: 24),
            child,
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
          patient.birthDate == null
              ? localizations.birthDateNotProvided
              : localizations.bornOn(
                  MaterialLocalizations.of(context)
                      .formatMediumDate(patient.birthDate!),
                ),
        ),
      ),
    );
  }
}

class _AppointmentCard extends StatelessWidget {
  const _AppointmentCard({required this.appointment});

  final Appointment appointment;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final material = MaterialLocalizations.of(context);
    final time = TimeOfDay.fromDateTime(appointment.scheduledAt);
    return Card(
      color: Colors.white,
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          child: const Icon(Icons.calendar_today_outlined),
        ),
        title: Text(
          appointment.patient.displayName,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        subtitle: Text(
          localizations.appointmentDateTime(
            material.formatMediumDate(appointment.scheduledAt),
            material.formatTimeOfDay(time),
          ),
        ),
        trailing: Chip(label: Text(localizations.scheduled)),
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

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    String? requiredField(String? value) =>
        value == null || value.trim().isEmpty
            ? localizations.requiredField
            : null;
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
                validator: requiredField,
              ),
              const SizedBox(height: 16),
              TextFormField(
                key: const ValueKey('family-name-field'),
                controller: _familyNameController,
                decoration:
                    InputDecoration(labelText: localizations.familyName),
                validator: requiredField,
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: () async {
                  final selected = await showDatePicker(
                    context: context,
                    firstDate: DateTime(1900),
                    lastDate: DateTime.now(),
                    initialDate: _birthDate ?? DateTime(1990),
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
                id: '',
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

class _AssignAppointmentDialog extends StatefulWidget {
  const _AssignAppointmentDialog({required this.patients});

  final List<Patient> patients;

  @override
  State<_AssignAppointmentDialog> createState() =>
      _AssignAppointmentDialogState();
}

class _AssignAppointmentDialogState extends State<_AssignAppointmentDialog> {
  Patient? _patient;
  DateTime? _date;
  TimeOfDay? _time;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final material = MaterialLocalizations.of(context);
    return AlertDialog(
      title: Text(localizations.assignAppointment),
      content: SizedBox(
        width: 440,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DropdownButtonFormField<Patient>(
              key: const ValueKey('appointment-patient'),
              initialValue: _patient,
              decoration: InputDecoration(labelText: localizations.patient),
              items: widget.patients
                  .map(
                    (patient) => DropdownMenuItem(
                      value: patient,
                      child: Text(patient.displayName),
                    ),
                  )
                  .toList(growable: false),
              onChanged: (value) => setState(() => _patient = value),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              key: const ValueKey('appointment-date'),
              onPressed: () async {
                final now = DateTime.now();
                final selected = await showDatePicker(
                  context: context,
                  firstDate: DateTime(now.year, now.month, now.day),
                  lastDate: DateTime(now.year + 2),
                  initialDate: _date ?? now,
                );
                if (selected != null) setState(() => _date = selected);
              },
              icon: const Icon(Icons.calendar_month_outlined),
              label: Text(
                _date == null
                    ? localizations.chooseDate
                    : material.formatMediumDate(_date!),
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              key: const ValueKey('appointment-time'),
              onPressed: () async {
                final selected = await showTimePicker(
                  context: context,
                  initialTime: _time ?? TimeOfDay.now(),
                );
                if (selected != null) setState(() => _time = selected);
              },
              icon: const Icon(Icons.schedule_outlined),
              label: Text(
                _time == null
                    ? localizations.chooseTime
                    : material.formatTimeOfDay(_time!),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(localizations.cancel),
        ),
        FilledButton(
          key: const ValueKey('save-appointment'),
          onPressed: _patient == null || _date == null || _time == null
              ? null
              : () => Navigator.pop(
                    context,
                    _AppointmentRequest(
                      patient: _patient!,
                      scheduledAt: DateTime(
                        _date!.year,
                        _date!.month,
                        _date!.day,
                        _time!.hour,
                        _time!.minute,
                      ),
                    ),
                  ),
          child: Text(localizations.assignAppointment),
        ),
      ],
    );
  }
}

class _AppointmentRequest {
  const _AppointmentRequest({required this.patient, required this.scheduledAt});

  final Patient patient;
  final DateTime scheduledAt;
}

class _Loading extends StatelessWidget {
  const _Loading({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 48),
        child: Column(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(label),
          ],
        ),
      );
}

class _Failure extends StatelessWidget {
  const _Failure({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => _Empty(
        icon: Icons.cloud_off_outlined,
        title: message,
        description: AppLocalizations.of(context).tryAgainDescription,
        action: OutlinedButton(
          onPressed: onRetry,
          child: Text(AppLocalizations.of(context).retry),
        ),
      );
}

class _Empty extends StatelessWidget {
  const _Empty({
    required this.icon,
    required this.title,
    required this.description,
    this.action,
  });

  final IconData icon;
  final String title;
  final String description;
  final Widget? action;

  @override
  Widget build(BuildContext context) => Card(
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 42),
          child: Column(
            children: [
              Icon(icon,
                  size: 46, color: Theme.of(context).colorScheme.primary),
              const SizedBox(height: 14),
              Text(
                title,
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 6),
              Text(description, textAlign: TextAlign.center),
              if (action case final action?) ...[
                const SizedBox(height: 20),
                action,
              ],
            ],
          ),
        ),
      );
}
