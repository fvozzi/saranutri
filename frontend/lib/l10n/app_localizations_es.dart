// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'SaraNutri';

  @override
  String get localPrototype => 'Prototipo local';

  @override
  String get addPatient => 'Agregar paciente';

  @override
  String get givenName => 'Nombre';

  @override
  String get familyName => 'Apellido';

  @override
  String get chooseBirthDate => 'Elegir fecha de nacimiento';

  @override
  String get cancel => 'Cancelar';

  @override
  String get requiredField => 'Campo obligatorio';

  @override
  String get welcomeTitle => 'Atención nutricional, con claridad.';

  @override
  String get welcomeDescription =>
      'Comienza con el perfil de un paciente. Los planes, seguimientos y la API de GemStone pueden crecer a partir de esta base sencilla.';

  @override
  String patientProfiles(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'perfiles de pacientes',
      one: 'perfil de paciente',
      zero: 'perfiles de pacientes',
    );
    return '$_temp0';
  }

  @override
  String get patients => 'Pacientes';

  @override
  String get noPatients => 'Todavía no hay pacientes';

  @override
  String get noPatientsDescription =>
      'Crea el primer perfil para visualizar el flujo de pacientes.';

  @override
  String get addFirstPatient => 'Agregar primer paciente';

  @override
  String get birthDateNotProvided => 'Fecha de nacimiento no informada';

  @override
  String bornOn(String date) {
    return 'Nacimiento: $date';
  }

  @override
  String get changeLanguage => 'Cambiar idioma';

  @override
  String get languageEnglish => 'Inglés';

  @override
  String get languageSpanish => 'Español';

  @override
  String get languagePortuguese => 'Portugués';

  @override
  String get loadingPatients => 'Cargando pacientes…';

  @override
  String get unableToLoadPatients => 'No se pudieron cargar los pacientes.';

  @override
  String get unableToAddPatient => 'No se pudo agregar el paciente.';

  @override
  String get retry => 'Reintentar';

  @override
  String get publicBrand => 'SV Nutrición';

  @override
  String get openApp => 'Ingresar a la app';

  @override
  String get publicSite => 'Sitio público';

  @override
  String get publicNavApproach => 'Enfoque';

  @override
  String get publicNavContent => 'Contenido';

  @override
  String get publicEyebrow => 'Nutrición para la vida real';

  @override
  String get publicHeroTitle => 'Comer mejor puede sentirse simple.';

  @override
  String get publicHeroDescription =>
      'Un acompañamiento cercano y práctico para construir hábitos posibles, disfrutar la comida y avanzar con claridad, sin perseguir la perfección.';

  @override
  String get discoverApproach => 'Conocé el enfoque';

  @override
  String get visitInstagram => 'Ver Instagram';

  @override
  String get approachEyebrow => 'El enfoque';

  @override
  String get approachTitle => 'Una forma más amable de cuidar tu alimentación.';

  @override
  String get approachDescription =>
      'Tus decisiones alimentarias suceden en la vida real. El proceso parte de tu contexto y transforma la nutrición en herramientas claras y útiles para lo cotidiano.';

  @override
  String get principleBalanceTitle => 'Sin extremos';

  @override
  String get principleBalanceDescription =>
      'El equilibrio se construye con constancia, flexibilidad y decisiones que puedas sostener.';

  @override
  String get principlePersonalTitle => 'Contexto personal';

  @override
  String get principlePersonalDescription =>
      'Tus rutinas, preferencias y objetivos le dan forma al camino.';

  @override
  String get principleEverydayTitle => 'Herramientas cotidianas';

  @override
  String get principleEverydayDescription =>
      'Ideas simples para llevar lo aprendido a las compras, la cocina y la mesa compartida.';

  @override
  String get processEyebrow => 'El proceso';

  @override
  String get processTitle => 'Claridad, paso a paso.';

  @override
  String get processDescription =>
      'Una estructura simple ayuda a transformar información en acciones que entren en tu semana.';

  @override
  String get processListenTitle => 'Conversamos';

  @override
  String get processListenDescription =>
      'Empezamos por tu contexto, tus preguntas, tus rutinas y lo que es importante para vos.';

  @override
  String get processPlanTitle => 'Trazamos un camino';

  @override
  String get processPlanDescription =>
      'Ordenamos próximos pasos posibles, con prioridades claras y espacio para la vida real.';

  @override
  String get processAdjustTitle => 'Ajustamos';

  @override
  String get processAdjustDescription =>
      'Cada avance aporta información para afinar el proceso con el tiempo.';

  @override
  String get contentEyebrow => 'Ideas e inspiración';

  @override
  String get contentTitle => 'Contenido de nutrición para todos los días.';

  @override
  String get contentDescription =>
      'Seguí a @sv.nutricionista para encontrar ideas prácticas, inspiración con alimentos y conocer más de cerca el enfoque.';

  @override
  String get followOnInstagram => 'Seguir en Instagram';

  @override
  String get publicCtaTitle => '¿Querés ordenar tu próximo paso?';

  @override
  String get publicCtaDescription =>
      'Ingresá a la aplicación privada para gestionar perfiles de pacientes y continuar la experiencia de atención digital.';

  @override
  String get publicDisclaimer =>
      'Información general. No reemplaza la atención médica individual.';

  @override
  String get signInTitle => 'Te damos la bienvenida';

  @override
  String get signInDescription =>
      'Ingresá para acceder a tu espacio de SaraNutri.';

  @override
  String get email => 'Correo electrónico';

  @override
  String get password => 'Contraseña';

  @override
  String get showPassword => 'Mostrar contraseña';

  @override
  String get hidePassword => 'Ocultar contraseña';

  @override
  String get signIn => 'Ingresar';

  @override
  String get invalidCredentials => 'El correo o la contraseña son incorrectos.';

  @override
  String get unableToSignIn =>
      'No se puede iniciar sesión en este momento. Intentá nuevamente.';

  @override
  String get signOut => 'Cerrar sesión';

  @override
  String get appointments => 'Turnos';

  @override
  String get assignAppointment => 'Asignar turno';

  @override
  String get loadingAppointments => 'Cargando turnos…';

  @override
  String get unableToLoadAppointments => 'No se pudieron cargar los turnos.';

  @override
  String get noAppointments => 'Todavía no hay turnos';

  @override
  String get noProfessionalAppointmentsDescription =>
      'Asigná el primer turno a un paciente.';

  @override
  String get noPatientAppointmentsDescription =>
      'Tus próximos turnos aparecerán aquí.';

  @override
  String get addPatientFirst => 'Agregá un paciente antes de asignar un turno.';

  @override
  String get unableToAssignAppointment => 'No se pudo asignar el turno.';

  @override
  String get patient => 'Paciente';

  @override
  String get chooseDate => 'Elegir fecha';

  @override
  String get chooseTime => 'Elegir horario';

  @override
  String get scheduled => 'Programado';

  @override
  String appointmentDateTime(String date, String time) {
    return '$date a las $time';
  }

  @override
  String get tryAgainDescription => 'Revisá tu conexión e intentá nuevamente.';
}
