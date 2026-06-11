import { Module } from '@nestjs/common';
import { APP_GUARD } from '@nestjs/core';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { AuthModule } from './modules/auth/auth.module';
import { UsersModule } from './modules/users/users.module';
import { AssetsModule } from './modules/assets/assets.module';
import { InvestmentsModule } from './modules/investments/investments.module';
import { PortfoliosModule } from './modules/portfolios/portfolios.module';
import { JwtAuthGuard } from './modules/auth/guards/jwt-auth.guard';
import { PrismaService } from './prisma.service';

@Module({
  imports: [
    AuthModule,
    UsersModule,
    AssetsModule,
    InvestmentsModule,
    PortfoliosModule,
  ],
  controllers: [AppController],
  providers: [
    AppService,
    PrismaService,
    {
      provide: APP_GUARD,
      useClass: JwtAuthGuard,
    },
  ],
})
export class AppModule {}
