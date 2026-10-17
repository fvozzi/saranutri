// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'SaraNutri';

  @override
  String get localPrototype => 'Local prototype';

  @override
  String get addPatient => 'Add patient';

  @override
  String get givenName => 'Given name';

  @override
  String get familyName => 'Family name';

  @override
  String get chooseBirthDate => 'Choose birth date';

  @override
  String get cancel => 'Cancel';

  @override
  String get requiredField => 'Required';

  @override
  String get welcomeTitle => 'Nutrition care, made clear.';

  @override
  String get welcomeDescription =>
      'Start with a patient profile. Plans, check-ins, and the GemStone API can grow from this small foundation.';

  @override
  String patientProfiles(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'patient profiles',
      one: 'patient profile',
      zero: 'patient profiles',
    );
    return '$_temp0';
  }

  @override
  String get patients => 'Patients';

  @override
  String get noPatients => 'No patients yet';

  @override
  String get noPatientsDescription =>
      'Create the first profile to preview the patient workflow.';

  @override
  String get addFirstPatient => 'Add first patient';

  @override
  String get birthDateNotProvided => 'Birth date not provided';

  @override
  String bornOn(String date) {
    return 'Born $date';
  }

  @override
  String get changeLanguage => 'Change language';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageSpanish => 'Spanish';

  @override
  String get languagePortuguese => 'Portuguese';

  @override
  String get loadingPatients => 'Loading patients…';

  @override
  String get unableToLoadPatients => 'Patients could not be loaded.';

  @override
  String get unableToAddPatient => 'The patient could not be added.';

  @override
  String get retry => 'Try again';

  @override
  String get publicBrand => 'SV Nutrition';

  @override
  String get openApp => 'Open app';

  @override
  String get publicSite => 'Public site';

  @override
  String get publicNavApproach => 'Approach';

  @override
  String get publicNavContent => 'Content';

  @override
  String get publicEyebrow => 'Nutrition for real life';

  @override
  String get publicHeroTitle => 'Eating well can feel simple.';

  @override
  String get publicHeroDescription =>
      'A close, practical approach to building possible habits, enjoying food, and moving forward with clarity—without chasing perfection.';

  @override
  String get discoverApproach => 'Discover the approach';

  @override
  String get visitInstagram => 'Visit Instagram';

  @override
  String get approachEyebrow => 'The approach';

  @override
  String get approachTitle => 'A kinder way to care for how you eat.';

  @override
  String get approachDescription =>
      'Your food choices happen in real life. The process starts with your context and turns nutrition into clear, useful tools for everyday decisions.';

  @override
  String get principleBalanceTitle => 'Without extremes';

  @override
  String get principleBalanceDescription =>
      'Balance grows from consistency, flexibility, and choices you can sustain.';

  @override
  String get principlePersonalTitle => 'Personal context';

  @override
  String get principlePersonalDescription =>
      'Your routines, preferences, and goals shape the path forward.';

  @override
  String get principleEverydayTitle => 'Everyday tools';

  @override
  String get principleEverydayDescription =>
      'Simple ideas help bring what you learn into shopping, cooking, and sharing meals.';

  @override
  String get processEyebrow => 'The process';

  @override
  String get processTitle => 'Clarity, one step at a time.';

  @override
  String get processDescription =>
      'A simple structure helps transform information into actions that fit your week.';

  @override
  String get processListenTitle => 'We listen';

  @override
  String get processListenDescription =>
      'We begin with your context, questions, routines, and what matters to you.';

  @override
  String get processPlanTitle => 'We create a path';

  @override
  String get processPlanDescription =>
      'We organize practical next steps with clear priorities and room for real life.';

  @override
  String get processAdjustTitle => 'We adjust';

  @override
  String get processAdjustDescription =>
      'Progress becomes useful information for refining the process over time.';

  @override
  String get contentEyebrow => 'Ideas and inspiration';

  @override
  String get contentTitle => 'Nutrition content for everyday life.';

  @override
  String get contentDescription =>
      'Follow @sv.nutricionista for practical ideas, food inspiration, and a closer look at the approach.';

  @override
  String get followOnInstagram => 'Follow on Instagram';

  @override
  String get publicCtaTitle => 'Ready to organize your next step?';

  @override
  String get publicCtaDescription =>
      'Enter the private app to manage patient profiles and continue the digital care experience.';

  @override
  String get publicDisclaimer =>
      'General information. It does not replace individual medical care.';
}
