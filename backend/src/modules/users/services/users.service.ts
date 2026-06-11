import { Inject, Injectable, ConflictException } from '@nestjs/common';
import { User } from '../domain/user.entity';
import { USER_REPOSITORY, type UserRepository } from '../data/user.repository.interface';
import * as bcrypt from 'bcrypt';
import { randomUUID } from 'crypto';

@Injectable()
export class UsersService {
  constructor(
    @Inject(USER_REPOSITORY)
    private readonly userRepository: UserRepository,
  ) {}

  async create(email: string, passwordPlain: string): Promise<User> {
    const existingUser = await this.userRepository.findByEmail(email);
    if (existingUser) {
      throw new ConflictException('Email already exists');
    }

    const saltRounds = 10;
    const passwordHash = await bcrypt.hash(passwordPlain, saltRounds);

    const user = new User();
    user.id = randomUUID();
    user.email = email;
    user.passwordHash = passwordHash;
    user.refreshTokenHash = null;

    return this.userRepository.save(user);
  }

  async findByEmail(email: string): Promise<User | null> {
    return this.userRepository.findByEmail(email);
  }

  async findById(id: string): Promise<User | null> {
    return this.userRepository.findById(id);
  }

  async update(user: User): Promise<User> {
    return this.userRepository.update(user);
  }
}
