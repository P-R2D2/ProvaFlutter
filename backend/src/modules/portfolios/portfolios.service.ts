import { Injectable, Inject, ConflictException, NotFoundException } from '@nestjs/common';
import { PORTFOLIO_REPOSITORY } from './domain/portfolio.repository.interface';
import type { PortfolioRepository } from './domain/portfolio.repository.interface';
import { Portfolio } from './domain/portfolio.entity';

@Injectable()
export class PortfoliosService {
  constructor(
    @Inject(PORTFOLIO_REPOSITORY)
    private readonly portfolioRepository: PortfolioRepository,
  ) {}

  async findById(id: string): Promise<Portfolio> {
    const portfolio = await this.portfolioRepository.findById(id);
    if (!portfolio) {
      throw new NotFoundException('Portfolio not found');
    }
    return portfolio;
  }

  async findByUser(userId: string): Promise<Portfolio[]> {
    return this.portfolioRepository.findByUser(userId);
  }

  async create(userId: string, data: { name: string; description?: string }): Promise<Portfolio> {
    const existing = await this.portfolioRepository.findByNameAndUser(data.name, userId);
    if (existing) {
      throw new ConflictException('Portfolio with this name already exists');
    }
    return this.portfolioRepository.create({ ...data, userId });
  }

  async update(id: string, userId: string, data: { name?: string; description?: string }): Promise<Portfolio> {
    const portfolio = await this.findById(id);

    if (data.name && data.name !== portfolio.name) {
      const existing = await this.portfolioRepository.findByNameAndUser(data.name, userId);
      if (existing) {
        throw new ConflictException('Portfolio with this name already exists');
      }
    }

    return this.portfolioRepository.update(id, data);
  }

  async delete(id: string): Promise<void> {
    await this.findById(id);
    await this.portfolioRepository.delete(id);
  }
}
