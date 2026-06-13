class AuthResult {
  final String accessToken;
  final String refreshToken;
  final bool entrevistaConcluida;
  final String? perfilInvestidor;
  final int? pontuacaoPerfil;

  const AuthResult({
    required this.accessToken,
    required this.refreshToken,
    required this.entrevistaConcluida,
    this.perfilInvestidor,
    this.pontuacaoPerfil,
  });

  factory AuthResult.fromJson(Map<String, dynamic> json) {
    return AuthResult(
      accessToken: json['accessToken'] as String,
      refreshToken: json['refreshToken'] as String,
      entrevistaConcluida: json['entrevistaConcluida'] as bool? ?? false,
      perfilInvestidor: json['perfilInvestidor'] as String?,
      pontuacaoPerfil: json['pontuacaoPerfil'] as int?,
    );
  }
}
