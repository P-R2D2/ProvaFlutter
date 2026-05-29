import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { UsersService } from './services/users.service';
import { User } from './domain/user.entity';
import { TypeOrmUserRepository } from './data/typeorm-user.repository';
import { USER_REPOSITORY } from './data/user.repository.interface';

@Module({
  imports: [TypeOrmModule.forFeature([User])],
  controllers: [],
  providers: [
    UsersService,
    {
      provide: USER_REPOSITORY,
      useClass: TypeOrmUserRepository,
    },
  ],
  exports: [UsersService],
})
export class UsersModule {}
