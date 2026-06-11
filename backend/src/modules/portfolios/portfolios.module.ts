import { Module } from '@nestjs/common';
import { PrismaService } from '../../prisma.service';
import { PortfoliosService } from './portfolios.service';
import { PortfoliosController } from './portfolios.controller';
import { PrismaPortfolioRepository } from './data/prisma-portfolio.repository';
import { PORTFOLIO_REPOSITORY } from './domain/portfolio.repository.interface';

@Module({
  controllers: [PortfoliosController],
  providers: [
    PrismaService,
    PortfoliosService,
    {
      provide: PORTFOLIO_REPOSITORY,
      useClass: PrismaPortfolioRepository,
    },
  ],
  exports: [PortfoliosService, PORTFOLIO_REPOSITORY],
})
export class PortfoliosModule {}
