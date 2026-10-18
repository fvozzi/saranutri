// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appTitle => 'SaraNutri';

  @override
  String get localPrototype => 'Protótipo local';

  @override
  String get addPatient => 'Adicionar paciente';

  @override
  String get givenName => 'Nome';

  @override
  String get familyName => 'Sobrenome';

  @override
  String get chooseBirthDate => 'Escolher data de nascimento';

  @override
  String get cancel => 'Cancelar';

  @override
  String get requiredField => 'Campo obrigatório';

  @override
  String get welcomeTitle => 'Cuidado nutricional, com clareza.';

  @override
  String get welcomeDescription =>
      'Comece com o perfil de um paciente. Planos, acompanhamentos e a API do GemStone podem evoluir a partir desta base simples.';

  @override
  String patientProfiles(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'perfis de pacientes',
      one: 'perfil de paciente',
      zero: 'perfis de pacientes',
    );
    return '$_temp0';
  }

  @override
  String get patients => 'Pacientes';

  @override
  String get noPatients => 'Ainda não há pacientes';

  @override
  String get noPatientsDescription =>
      'Crie o primeiro perfil para visualizar o fluxo de pacientes.';

  @override
  String get addFirstPatient => 'Adicionar primeiro paciente';

  @override
  String get birthDateNotProvided => 'Data de nascimento não informada';

  @override
  String bornOn(String date) {
    return 'Nascimento: $date';
  }

  @override
  String get changeLanguage => 'Alterar idioma';

  @override
  String get languageEnglish => 'Inglês';

  @override
  String get languageSpanish => 'Espanhol';

  @override
  String get languagePortuguese => 'Português';

  @override
  String get loadingPatients => 'Carregando pacientes…';

  @override
  String get unableToLoadPatients => 'Não foi possível carregar os pacientes.';

  @override
  String get unableToAddPatient => 'Não foi possível adicionar o paciente.';

  @override
  String get retry => 'Tentar novamente';

  @override
  String get publicBrand => 'SV Nutrição';

  @override
  String get openApp => 'Entrar no app';

  @override
  String get publicSite => 'Site público';

  @override
  String get publicNavApproach => 'Abordagem';

  @override
  String get publicNavContent => 'Conteúdo';

  @override
  String get publicEyebrow => 'Nutrição para a vida real';

  @override
  String get publicHeroTitle => 'Comer melhor pode ser simples.';

  @override
  String get publicHeroDescription =>
      'Um acompanhamento próximo e prático para construir hábitos possíveis, aproveitar a comida e avançar com clareza, sem buscar a perfeição.';

  @override
  String get discoverApproach => 'Conheça a abordagem';

  @override
  String get visitInstagram => 'Ver Instagram';

  @override
  String get approachEyebrow => 'A abordagem';

  @override
  String get approachTitle => 'Uma forma mais gentil de cuidar da alimentação.';

  @override
  String get approachDescription =>
      'Suas escolhas alimentares acontecem na vida real. O processo parte do seu contexto e transforma a nutrição em ferramentas claras e úteis para o dia a dia.';

  @override
  String get principleBalanceTitle => 'Sem extremos';

  @override
  String get principleBalanceDescription =>
      'O equilíbrio nasce da constância, da flexibilidade e de escolhas que você consegue manter.';

  @override
  String get principlePersonalTitle => 'Contexto pessoal';

  @override
  String get principlePersonalDescription =>
      'Suas rotinas, preferências e objetivos orientam o caminho.';

  @override
  String get principleEverydayTitle => 'Ferramentas cotidianas';

  @override
  String get principleEverydayDescription =>
      'Ideias simples ajudam a levar o aprendizado para as compras, a cozinha e as refeições compartilhadas.';

  @override
  String get processEyebrow => 'O processo';

  @override
  String get processTitle => 'Clareza, passo a passo.';

  @override
  String get processDescription =>
      'Uma estrutura simples ajuda a transformar informação em ações que cabem na sua semana.';

  @override
  String get processListenTitle => 'Conversamos';

  @override
  String get processListenDescription =>
      'Começamos pelo seu contexto, suas perguntas, suas rotinas e o que importa para você.';

  @override
  String get processPlanTitle => 'Criamos um caminho';

  @override
  String get processPlanDescription =>
      'Organizamos próximos passos possíveis, com prioridades claras e espaço para a vida real.';

  @override
  String get processAdjustTitle => 'Ajustamos';

  @override
  String get processAdjustDescription =>
      'Cada avanço traz informações para aprimorar o processo ao longo do tempo.';

  @override
  String get contentEyebrow => 'Ideias e inspiração';

  @override
  String get contentTitle => 'Conteúdo de nutrição para todos os dias.';

  @override
  String get contentDescription =>
      'Siga @sv.nutricionista para encontrar ideias práticas, inspiração com alimentos e conhecer melhor a abordagem.';

  @override
  String get followOnInstagram => 'Seguir no Instagram';

  @override
  String get publicCtaTitle => 'Quer organizar o próximo passo?';

  @override
  String get publicCtaDescription =>
      'Entre no aplicativo privado para gerenciar perfis de pacientes e continuar a experiência de cuidado digital.';

  @override
  String get publicDisclaimer =>
      'Informação geral. Não substitui atendimento médico individual.';

  @override
  String get signInTitle => 'Boas-vindas';

  @override
  String get signInDescription => 'Entre para acessar seu espaço SaraNutri.';

  @override
  String get email => 'E-mail';

  @override
  String get password => 'Senha';

  @override
  String get showPassword => 'Mostrar senha';

  @override
  String get hidePassword => 'Ocultar senha';

  @override
  String get signIn => 'Entrar';

  @override
  String get invalidCredentials => 'O e-mail ou a senha estão incorretos.';

  @override
  String get unableToSignIn =>
      'Não foi possível entrar agora. Tente novamente.';

  @override
  String get signOut => 'Sair';

  @override
  String get appointments => 'Consultas';

  @override
  String get assignAppointment => 'Agendar consulta';

  @override
  String get loadingAppointments => 'Carregando consultas…';

  @override
  String get unableToLoadAppointments =>
      'Não foi possível carregar as consultas.';

  @override
  String get noAppointments => 'Ainda não há consultas';

  @override
  String get noProfessionalAppointmentsDescription =>
      'Agende a primeira consulta para um paciente.';

  @override
  String get noPatientAppointmentsDescription =>
      'Suas próximas consultas aparecerão aqui.';

  @override
  String get addPatientFirst =>
      'Adicione um paciente antes de agendar uma consulta.';

  @override
  String get unableToAssignAppointment =>
      'Não foi possível agendar a consulta.';

  @override
  String get patient => 'Paciente';

  @override
  String get chooseDate => 'Escolher data';

  @override
  String get chooseTime => 'Escolher horário';

  @override
  String get scheduled => 'Agendada';

  @override
  String appointmentDateTime(String date, String time) {
    return '$date às $time';
  }

  @override
  String get tryAgainDescription => 'Verifique sua conexão e tente novamente.';
}
