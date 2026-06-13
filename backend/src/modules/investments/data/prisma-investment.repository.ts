import { Injectable } from '@nestjs/common';
import { PrismaService } from '../../../prisma.service';
import { Investment } from '../domain/investment.entity';
import { InvestmentRepository } from '../domain/investment.repository.interface';

@Injectable()
export class PrismaInvestmentRepository implements InvestmentRepository {
  constructor(private readonly prisma: PrismaService) {}

  async findById(id: string): Promise<Investment | null> {
    return this.prisma.investment.findUnique({
      where: { id },
    });
  }

  async findByPortfolio(portfolioId: string): Promise<Investment[]> {
    return this.prisma.investment.findMany({
      where: { portfolioId },
      orderBy: { assetSymbol: 'asc' },
    });
  }

  async findByUser(userId: string): Promise<Investment[]> {
    return this.prisma.investment.findMany({
      where: {
        portfolio: {
          userId,
        },
      },
      orderBy: { assetSymbol: 'asc' },
    });
  }

  async create(data: {
    assetSymbol: string;
    assetName: string;
    quantity: number;
    averagePurchasePrice: number;
    portfolioId: string;
  }): Promise<Investment> {
    return this.prisma.investment.create({
      data,
    });
  }

  async update(
    id: string,
    data: {
      quantity?: number;
      averagePurchasePrice?: number;
    },
  ): Promise<Investment> {
    return this.prisma.investment.update({
      where: { id },
      data,
    });
  }

  async delete(id: string): Promise<void> {
    await this.prisma.investment.delete({
      where: { id },
    });
  }

  async findByPortfolioAndSymbol(portfolioId: string, assetSymbol: string): Promise<Investment | null> {
    return this.prisma.investment.findFirst({
      where: {
        portfolioId,
        assetSymbol: {
          equals: assetSymbol,
        },
      },
    });
  }
}
