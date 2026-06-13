import { Injectable, UnauthorizedException } from '@nestjs/common';
import { UsersService } from '../../users/services/users.service';
import { JwtService } from '@nestjs/jwt';
import { LoginDto } from '../dtos/login.dto';
import { AuthToken } from '../domain/auth-token.type';
import * as bcrypt from 'bcrypt';
import { randomUUID } from 'crypto';

@Injectable()
export class AuthService {
  constructor(
    private readonly usersService: UsersService,
    private readonly jwtService: JwtService,
  ) {}

  private hashToken(token: string): string {
    return require('crypto').createHash('sha256').update(token).digest('hex');
  }

  private async generateTokenPair(user: { id: string; email: string }): Promise<{ accessToken: string; refreshToken: string }> {
    const payload = { sub: user.id, email: user.email };

    const accessToken = this.jwtService.sign(payload, {
      secret: process.env.JWT_SECRET || 'super-secret-developer-key-change-in-production',
      expiresIn: '15m',
    });

    const refreshToken = this.jwtService.sign(
      { ...payload, jti: randomUUID() },
      {
        secret: process.env.JWT_REFRESH_SECRET || 'super-secret-refresh-token-developer-key',
        expiresIn: '7d',
      },
    );

    return {
      accessToken,
      refreshToken,
    };
  }

  async login(loginDto: LoginDto): Promise<AuthToken> {
    const user = await this.usersService.findByEmail(loginDto.email);
    if (!user) {
      throw new UnauthorizedException('E-mail ou senha incorretos');
    }

    const isPasswordValid = await bcrypt.compare(loginDto.password, user.passwordHash);
    if (!isPasswordValid) {
      throw new UnauthorizedException('E-mail ou senha incorretos');
    }

    const tokenPair = await this.generateTokenPair(user);
    const saltRounds = 10;
    user.refreshTokenHash = await bcrypt.hash(this.hashToken(tokenPair.refreshToken), saltRounds);
    await this.usersService.update(user);

    return {
      accessToken: tokenPair.accessToken,
      refreshToken: tokenPair.refreshToken,
      entrevistaConcluida: user.entrevistaConcluida,
      perfilInvestidor: user.perfilInvestidor,
      pontuacaoPerfil: user.pontuacaoPerfil,
    };
  }

  async refresh(refreshToken: string): Promise<AuthToken> {
    let payload: any;
    try {
      payload = this.jwtService.verify(refreshToken, {
        secret: process.env.JWT_REFRESH_SECRET || 'super-secret-refresh-token-developer-key',
      });
    } catch (_) {
      throw new UnauthorizedException('Invalid or expired refresh token');
    }

    const userId = payload.sub;
    const user = await this.usersService.findById(userId);
    if (!user || !user.refreshTokenHash) {
      throw new UnauthorizedException('Invalid or expired refresh token');
    }

    const hashedToken = this.hashToken(refreshToken);
    const isTokenValid = await bcrypt.compare(hashedToken, user.refreshTokenHash);
    if (!isTokenValid) {
      // RTR Breach: Token reuse detected. Terminate all active sessions.
      user.refreshTokenHash = null;
      await this.usersService.update(user);
      throw new UnauthorizedException('Token reuse detected. Session terminated.');
    }

    const tokenPair = await this.generateTokenPair(user);
    const saltRounds = 10;
    user.refreshTokenHash = await bcrypt.hash(this.hashToken(tokenPair.refreshToken), saltRounds);
    await this.usersService.update(user);

    return {
      accessToken: tokenPair.accessToken,
      refreshToken: tokenPair.refreshToken,
      entrevistaConcluida: user.entrevistaConcluida,
      perfilInvestidor: user.perfilInvestidor,
      pontuacaoPerfil: user.pontuacaoPerfil,
    };
  }

  async logout(userId: string): Promise<void> {
    const user = await this.usersService.findById(userId);
    if (user) {
      user.refreshTokenHash = null;
      await this.usersService.update(user);
    }
  }
}
