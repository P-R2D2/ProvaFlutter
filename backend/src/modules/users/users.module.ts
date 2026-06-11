import { Module } from '@nestjs/common';
import { PrismaService } from '../../prisma.service';
import { UsersService } from './services/users.service';
import { PrismaUserRepository } from './data/prisma-user.repository';
import { USER_REPOSITORY } from './data/user.repository.interface';

@Module({
  providers: [
    PrismaService,
    UsersService,
    {
      provide: USER_REPOSITORY,
      useClass: PrismaUserRepository,
    },
  ],
  exports: [UsersService],
})
export class UsersModule {}
