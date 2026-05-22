import { Module } from '@nestjs/common';
import { UsersService } from './services/users.service';
import { InMemoryUserRepository, USER_REPOSITORY } from './data/in-memory-user.repository';

@Module({
  imports: [],
  controllers: [],
  providers: [
    UsersService,
    {
      provide: USER_REPOSITORY,
      useClass: InMemoryUserRepository,
    },
  ],
  exports: [UsersService],
})
export class UsersModule {}
