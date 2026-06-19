import { Injectable } from '@nestjs/common';
import { PrismaService } from '../../../prisma.service';
import { User } from '../domain/user.entity';
import { UserRepository } from './user.repository.interface';

@Injectable()
export class PrismaUserRepository implements UserRepository {
  constructor(private readonly prisma: PrismaService) {}

  async save(user: User): Promise<User> {
    const created = await this.prisma.user.create({
      data: {
        id: user.id,
        email: user.email,
        passwordHash: user.passwordHash,
        refreshTokenHash: user.refreshTokenHash,
        entrevistaConcluida: user.entrevistaConcluida,
        perfilInvestidor: user.perfilInvestidor,
        pontuacaoPerfil: user.pontuacaoPerfil,
      },
    });
    return this.mapToEntity(created);
  }

  async findByEmail(email: string): Promise<User | null> {
    const user = await this.prisma.user.findUnique({
      where: { email },
    });
    return user ? this.mapToEntity(user) : null;
  }

  async findById(id: string): Promise<User | null> {
    const user = await this.prisma.user.findUnique({
      where: { id },
    });
    return user ? this.mapToEntity(user) : null;
  }

  async update(user: User): Promise<User> {
    const updated = await this.prisma.user.update({
      where: { id: user.id },
      data: {
        email: user.email,
        passwordHash: user.passwordHash,
        refreshTokenHash: user.refreshTokenHash,
        entrevistaConcluida: user.entrevistaConcluida,
        perfilInvestidor: user.perfilInvestidor,
        pontuacaoPerfil: user.pontuacaoPerfil,
      },
    });
    return this.mapToEntity(updated);
  }

  private mapToEntity(prismaUser: any): User {
    const user = new User();
    user.id = prismaUser.id;
    user.email = prismaUser.email;
    user.passwordHash = prismaUser.passwordHash;
    user.refreshTokenHash = prismaUser.refreshTokenHash;
    user.entrevistaConcluida = prismaUser.entrevistaConcluida;
    user.perfilInvestidor = prismaUser.perfilInvestidor;
    user.pontuacaoPerfil = prismaUser.pontuacaoPerfil;
    return user;
  }
}
