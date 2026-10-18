enum UserRole {
  professional,
  patient;

  factory UserRole.fromJson(String value) {
    return switch (value) {
      'professional' => UserRole.professional,
      'patient' => UserRole.patient,
      _ => throw const FormatException('Unsupported user role'),
    };
  }
}

class AppUser {
  const AppUser({
    required this.email,
    required this.displayName,
    required this.role,
  });

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      email: json['email'] as String,
      displayName: json['displayName'] as String,
      role: UserRole.fromJson(json['role'] as String),
    );
  }

  final String email;
  final String displayName;
  final UserRole role;
}

class AppSession {
  const AppSession({required this.accessToken, required this.user});

  factory AppSession.fromJson(Map<String, dynamic> json) {
    return AppSession(
      accessToken: json['accessToken'] as String,
      user: AppUser.fromJson(json['user'] as Map<String, dynamic>),
    );
  }

  final String accessToken;
  final AppUser user;
}
