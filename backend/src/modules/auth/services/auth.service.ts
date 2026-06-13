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

  async login(loginDto: LoginDto): Promise<AuthToken> {
    const user = await this.usersService.findByEmail(loginDto.email);
    if (!user) {
      throw new UnauthorizedException('E-mail ou senha incorretos');
    }

    const isPasswordValid = await bcrypt.compare(loginDto.password, user.passwordHash);
    if (!isPasswordValid) {
      throw new UnauthorizedException('E-mail ou senha incorretos');
    }

    const payload = { sub: user.id, email: user.email };
    const accessToken = this.jwtService.sign(payload);
    const refreshToken = randomUUID();

    user.refreshToken = refreshToken;
    await this.usersService.update(user);

    return {
      accessToken,
      refreshToken,
      entrevistaConcluida: user.entrevistaConcluida,
      perfilInvestidor: user.perfilInvestidor,
      pontuacaoPerfil: user.pontuacaoPerfil,
    };
  }

  async logout(userId: string): Promise<void> {
    const user = await this.usersService.findById(userId);
    if (user) {
      user.refreshToken = null;
      await this.usersService.update(user);
    }
  }
}
