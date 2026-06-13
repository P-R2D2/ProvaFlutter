import { Module } from '@nestjs/common';
import { PrismaService } from '../../prisma.service';
import { InvestmentsService } from './services/investments.service';
import { InvestmentsController } from './controllers/investments.controller';
import { AssetsModule } from '../assets/assets.module';
import { PrismaInvestmentRepository } from './data/prisma-investment.repository';
import { INVESTMENT_REPOSITORY } from './domain/investment.repository.interface';

@Module({
  imports: [AssetsModule],
  providers: [
    PrismaService,
    InvestmentsService,
    {
      provide: INVESTMENT_REPOSITORY,
      useClass: PrismaInvestmentRepository,
    },
  ],
  controllers: [InvestmentsController],
  exports: [InvestmentsService, INVESTMENT_REPOSITORY],
})
export class InvestmentsModule {}
