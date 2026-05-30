class AuthResult {
  final String accessToken;
  final String refreshToken;
  final bool entrevistaConcluida;

  const AuthResult({
    required this.accessToken,
    required this.refreshToken,
    required this.entrevistaConcluida,
  });

  factory AuthResult.fromJson(Map<String, dynamic> json) {
    return AuthResult(
      accessToken: json['accessToken'] as String,
      refreshToken: json['refreshToken'] as String,
      entrevistaConcluida: json['entrevistaConcluida'] as bool? ?? false,
    );
  }
}
