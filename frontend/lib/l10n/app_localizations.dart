import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_pt.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
    Locale('pt')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'SaraNutri'**
  String get appTitle;

  /// No description provided for @localPrototype.
  ///
  /// In en, this message translates to:
  /// **'Local prototype'**
  String get localPrototype;

  /// No description provided for @addPatient.
  ///
  /// In en, this message translates to:
  /// **'Add patient'**
  String get addPatient;

  /// No description provided for @givenName.
  ///
  /// In en, this message translates to:
  /// **'Given name'**
  String get givenName;

  /// No description provided for @familyName.
  ///
  /// In en, this message translates to:
  /// **'Family name'**
  String get familyName;

  /// No description provided for @chooseBirthDate.
  ///
  /// In en, this message translates to:
  /// **'Choose birth date'**
  String get chooseBirthDate;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @requiredField.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get requiredField;

  /// No description provided for @welcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Nutrition care, made clear.'**
  String get welcomeTitle;

  /// No description provided for @welcomeDescription.
  ///
  /// In en, this message translates to:
  /// **'Start with a patient profile. Plans, check-ins, and the GemStone API can grow from this small foundation.'**
  String get welcomeDescription;

  /// No description provided for @patientProfiles.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{patient profiles} =1{patient profile} other{patient profiles}}'**
  String patientProfiles(int count);

  /// No description provided for @patients.
  ///
  /// In en, this message translates to:
  /// **'Patients'**
  String get patients;

  /// No description provided for @noPatients.
  ///
  /// In en, this message translates to:
  /// **'No patients yet'**
  String get noPatients;

  /// No description provided for @noPatientsDescription.
  ///
  /// In en, this message translates to:
  /// **'Create the first profile to preview the patient workflow.'**
  String get noPatientsDescription;

  /// No description provided for @addFirstPatient.
  ///
  /// In en, this message translates to:
  /// **'Add first patient'**
  String get addFirstPatient;

  /// No description provided for @birthDateNotProvided.
  ///
  /// In en, this message translates to:
  /// **'Birth date not provided'**
  String get birthDateNotProvided;

  /// No description provided for @bornOn.
  ///
  /// In en, this message translates to:
  /// **'Born {date}'**
  String bornOn(String date);

  /// No description provided for @changeLanguage.
  ///
  /// In en, this message translates to:
  /// **'Change language'**
  String get changeLanguage;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageSpanish.
  ///
  /// In en, this message translates to:
  /// **'Spanish'**
  String get languageSpanish;

  /// No description provided for @languagePortuguese.
  ///
  /// In en, this message translates to:
  /// **'Portuguese'**
  String get languagePortuguese;

  /// No description provided for @loadingPatients.
  ///
  /// In en, this message translates to:
  /// **'Loading patients…'**
  String get loadingPatients;

  /// No description provided for @unableToLoadPatients.
  ///
  /// In en, this message translates to:
  /// **'Patients could not be loaded.'**
  String get unableToLoadPatients;

  /// No description provided for @unableToAddPatient.
  ///
  /// In en, this message translates to:
  /// **'The patient could not be added.'**
  String get unableToAddPatient;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get retry;

  /// No description provided for @publicBrand.
  ///
  /// In en, this message translates to:
  /// **'SV Nutrition'**
  String get publicBrand;

  /// No description provided for @openApp.
  ///
  /// In en, this message translates to:
  /// **'Open app'**
  String get openApp;

  /// No description provided for @publicSite.
  ///
  /// In en, this message translates to:
  /// **'Public site'**
  String get publicSite;

  /// No description provided for @publicNavApproach.
  ///
  /// In en, this message translates to:
  /// **'Approach'**
  String get publicNavApproach;

  /// No description provided for @publicNavContent.
  ///
  /// In en, this message translates to:
  /// **'Content'**
  String get publicNavContent;

  /// No description provided for @publicEyebrow.
  ///
  /// In en, this message translates to:
  /// **'Nutrition for real life'**
  String get publicEyebrow;

  /// No description provided for @publicHeroTitle.
  ///
  /// In en, this message translates to:
  /// **'Eating well can feel simple.'**
  String get publicHeroTitle;

  /// No description provided for @publicHeroDescription.
  ///
  /// In en, this message translates to:
  /// **'A close, practical approach to building possible habits, enjoying food, and moving forward with clarity—without chasing perfection.'**
  String get publicHeroDescription;

  /// No description provided for @discoverApproach.
  ///
  /// In en, this message translates to:
  /// **'Discover the approach'**
  String get discoverApproach;

  /// No description provided for @visitInstagram.
  ///
  /// In en, this message translates to:
  /// **'Visit Instagram'**
  String get visitInstagram;

  /// No description provided for @approachEyebrow.
  ///
  /// In en, this message translates to:
  /// **'The approach'**
  String get approachEyebrow;

  /// No description provided for @approachTitle.
  ///
  /// In en, this message translates to:
  /// **'A kinder way to care for how you eat.'**
  String get approachTitle;

  /// No description provided for @approachDescription.
  ///
  /// In en, this message translates to:
  /// **'Your food choices happen in real life. The process starts with your context and turns nutrition into clear, useful tools for everyday decisions.'**
  String get approachDescription;

  /// No description provided for @principleBalanceTitle.
  ///
  /// In en, this message translates to:
  /// **'Without extremes'**
  String get principleBalanceTitle;

  /// No description provided for @principleBalanceDescription.
  ///
  /// In en, this message translates to:
  /// **'Balance grows from consistency, flexibility, and choices you can sustain.'**
  String get principleBalanceDescription;

  /// No description provided for @principlePersonalTitle.
  ///
  /// In en, this message translates to:
  /// **'Personal context'**
  String get principlePersonalTitle;

  /// No description provided for @principlePersonalDescription.
  ///
  /// In en, this message translates to:
  /// **'Your routines, preferences, and goals shape the path forward.'**
  String get principlePersonalDescription;

  /// No description provided for @principleEverydayTitle.
  ///
  /// In en, this message translates to:
  /// **'Everyday tools'**
  String get principleEverydayTitle;

  /// No description provided for @principleEverydayDescription.
  ///
  /// In en, this message translates to:
  /// **'Simple ideas help bring what you learn into shopping, cooking, and sharing meals.'**
  String get principleEverydayDescription;

  /// No description provided for @processEyebrow.
  ///
  /// In en, this message translates to:
  /// **'The process'**
  String get processEyebrow;

  /// No description provided for @processTitle.
  ///
  /// In en, this message translates to:
  /// **'Clarity, one step at a time.'**
  String get processTitle;

  /// No description provided for @processDescription.
  ///
  /// In en, this message translates to:
  /// **'A simple structure helps transform information into actions that fit your week.'**
  String get processDescription;

  /// No description provided for @processListenTitle.
  ///
  /// In en, this message translates to:
  /// **'We listen'**
  String get processListenTitle;

  /// No description provided for @processListenDescription.
  ///
  /// In en, this message translates to:
  /// **'We begin with your context, questions, routines, and what matters to you.'**
  String get processListenDescription;

  /// No description provided for @processPlanTitle.
  ///
  /// In en, this message translates to:
  /// **'We create a path'**
  String get processPlanTitle;

  /// No description provided for @processPlanDescription.
  ///
  /// In en, this message translates to:
  /// **'We organize practical next steps with clear priorities and room for real life.'**
  String get processPlanDescription;

  /// No description provided for @processAdjustTitle.
  ///
  /// In en, this message translates to:
  /// **'We adjust'**
  String get processAdjustTitle;

  /// No description provided for @processAdjustDescription.
  ///
  /// In en, this message translates to:
  /// **'Progress becomes useful information for refining the process over time.'**
  String get processAdjustDescription;

  /// No description provided for @contentEyebrow.
  ///
  /// In en, this message translates to:
  /// **'Ideas and inspiration'**
  String get contentEyebrow;

  /// No description provided for @contentTitle.
  ///
  /// In en, this message translates to:
  /// **'Nutrition content for everyday life.'**
  String get contentTitle;

  /// No description provided for @contentDescription.
  ///
  /// In en, this message translates to:
  /// **'Follow @sv.nutricionista for practical ideas, food inspiration, and a closer look at the approach.'**
  String get contentDescription;

  /// No description provided for @followOnInstagram.
  ///
  /// In en, this message translates to:
  /// **'Follow on Instagram'**
  String get followOnInstagram;

  /// No description provided for @publicCtaTitle.
  ///
  /// In en, this message translates to:
  /// **'Ready to organize your next step?'**
  String get publicCtaTitle;

  /// No description provided for @publicCtaDescription.
  ///
  /// In en, this message translates to:
  /// **'Enter the private app to manage patient profiles and continue the digital care experience.'**
  String get publicCtaDescription;

  /// No description provided for @publicDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'General information. It does not replace individual medical care.'**
  String get publicDisclaimer;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es', 'pt'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'pt':
      return AppLocalizationsPt();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
