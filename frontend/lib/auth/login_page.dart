import 'package:flutter/material.dart';
import 'package:saranutri/auth/app_session.dart';
import 'package:saranutri/auth/auth_repository.dart';
import 'package:saranutri/l10n/app_localizations.dart';
import 'package:saranutri/shared/brand_mark.dart';
import 'package:saranutri/shared/language_menu.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({
    required this.repository,
    required this.onSignedIn,
    required this.onLocaleChanged,
    required this.onOpenPublicSite,
    super.key,
  });

  final AuthRepository repository;
  final ValueChanged<AppSession> onSignedIn;
  final ValueChanged<Locale> onLocaleChanged;
  final VoidCallback onOpenPublicSite;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;
  bool _hidePassword = true;
  _LoginFailure _failure = _LoginFailure.none;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() {
      _isSubmitting = true;
      _failure = _LoginFailure.none;
    });
    try {
      final session = await widget.repository.signIn(
        email: _emailController.text,
        password: _passwordController.text,
      );
      if (mounted) widget.onSignedIn(session);
    } on InvalidCredentialsException {
      if (mounted) setState(() => _failure = _LoginFailure.credentials);
    } on Object {
      if (mounted) setState(() => _failure = _LoginFailure.service);
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          tooltip: localizations.publicSite,
          onPressed: widget.onOpenPublicSite,
          icon: const Icon(Icons.arrow_back),
        ),
        actions: [
          LanguageMenu(onLocaleChanged: widget.onLocaleChanged),
          const SizedBox(width: 12),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Card(
                color: Colors.white,
                elevation: 0,
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Align(child: BrandMark(size: 64)),
                        const SizedBox(height: 22),
                        Text(
                          localizations.signInTitle,
                          textAlign: TextAlign.center,
                          style: Theme.of(context)
                              .textTheme
                              .headlineMedium
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          localizations.signInDescription,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 28),
                        TextFormField(
                          key: const ValueKey('email-field'),
                          controller: _emailController,
                          enabled: !_isSubmitting,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          autofillHints: const [AutofillHints.username],
                          decoration: InputDecoration(
                            labelText: localizations.email,
                            prefixIcon: const Icon(Icons.mail_outline),
                          ),
                          validator: (value) =>
                              value == null || value.trim().isEmpty
                                  ? localizations.requiredField
                                  : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          key: const ValueKey('password-field'),
                          controller: _passwordController,
                          enabled: !_isSubmitting,
                          obscureText: _hidePassword,
                          textInputAction: TextInputAction.done,
                          autofillHints: const [AutofillHints.password],
                          onFieldSubmitted: (_) => _signIn(),
                          decoration: InputDecoration(
                            labelText: localizations.password,
                            prefixIcon: const Icon(Icons.lock_outline),
                            suffixIcon: IconButton(
                              tooltip: _hidePassword
                                  ? localizations.showPassword
                                  : localizations.hidePassword,
                              onPressed: () => setState(
                                () => _hidePassword = !_hidePassword,
                              ),
                              icon: Icon(
                                _hidePassword
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                              ),
                            ),
                          ),
                          validator: (value) => value == null || value.isEmpty
                              ? localizations.requiredField
                              : null,
                        ),
                        if (_failure != _LoginFailure.none) ...[
                          const SizedBox(height: 16),
                          Semantics(
                            liveRegion: true,
                            child: Text(
                              _failure.message(localizations),
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.error,
                              ),
                            ),
                          ),
                        ],
                        const SizedBox(height: 24),
                        FilledButton(
                          key: const ValueKey('sign-in'),
                          onPressed: _isSubmitting ? null : _signIn,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: _isSubmitting
                                ? const SizedBox.square(
                                    dimension: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Text(localizations.signIn),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

enum _LoginFailure {
  none,
  credentials,
  service;

  String message(AppLocalizations localizations) {
    return switch (this) {
      _LoginFailure.none => '',
      _LoginFailure.credentials => localizations.invalidCredentials,
      _LoginFailure.service => localizations.unableToSignIn,
    };
  }
}
