export interface AuthToken {
  accessToken: string;
  refreshToken: string;
  entrevistaConcluida: boolean;
  perfilInvestidor: string | null;
  pontuacaoPerfil: number | null;
}
