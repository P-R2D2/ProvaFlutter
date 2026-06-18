import { Injectable } from '@nestjs/common';
import { PrismaService } from '../../../prisma.service';
import { Portfolio } from '../domain/portfolio.entity';
import { PortfolioRepository } from '../domain/portfolio.repository.interface';

@Injectable()
export class PrismaPortfolioRepository implements PortfolioRepository {
  constructor(private readonly prisma: PrismaService) {}

  async findById(id: string): Promise<Portfolio | null> {
    return this.prisma.portfolio.findUnique({
      where: { id },
      include: { investments: true },
    });
  }

  async findByNameAndUser(name: string, userId: string): Promise<Portfolio | null> {
    return this.prisma.portfolio.findUnique({
      where: {
        userId_name: {
          userId,
          name,
        },
      },
    });
  }

  async findByUser(userId: string): Promise<Portfolio[]> {
    return this.prisma.portfolio.findMany({
      where: { userId },
      orderBy: { createdAt: 'desc' },
      include: { investments: true },
    });
  }

  async create(data: { name: string; description?: string; userId: string }): Promise<Portfolio> {
    return this.prisma.portfolio.create({
      data,
    });
  }

  async update(id: string, data: { name?: string; description?: string }): Promise<Portfolio> {
    return this.prisma.portfolio.update({
      where: { id },
      data,
    });
  }

  async delete(id: string): Promise<void> {
    await this.prisma.portfolio.delete({
      where: { id },
    });
  }
}
