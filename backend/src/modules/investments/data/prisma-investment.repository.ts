import { Injectable } from '@nestjs/common';
import { PrismaService } from '../../../prisma.service';
import { Investment } from '../domain/investment.entity';
import { InvestmentRepository } from '../domain/investment.repository.interface';

@Injectable()
export class PrismaInvestmentRepository implements InvestmentRepository {
  constructor(private readonly prisma: PrismaService) {}

  async findById(id: string): Promise<Investment | null> {
    return this.prisma.investment.findUnique({ where: { id } });
  }

  async findByPortfolio(portfolioId: string): Promise<Investment[]> {
    return this.prisma.investment.findMany({ where: { portfolioId } });
  }

  async findByUser(userId: string): Promise<Investment[]> {
    return this.prisma.investment.findMany({
      where: {
        portfolio: { userId },
      },
    });
  }

  async create(data: Omit<Investment, 'id' | 'createdAt' | 'updatedAt'>): Promise<Investment> {
    return this.prisma.investment.create({ data });
  }

  async update(id: string, data: Partial<Omit<Investment, 'id' | 'createdAt' | 'updatedAt' | 'portfolioId'>>): Promise<Investment> {
    return this.prisma.investment.update({
      where: { id },
      data,
    });
  }

  async delete(id: string): Promise<void> {
    await this.prisma.investment.delete({ where: { id } });
  }

  async findByPortfolioAndName(portfolioId: string, name: string): Promise<Investment | null> {
    return this.prisma.investment.findFirst({
      where: { portfolioId, name },
    });
  }
}
