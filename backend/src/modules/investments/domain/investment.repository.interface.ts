import { Investment } from './investment.entity';

export interface InvestmentRepository {
  findById(id: string): Promise<Investment | null>;
  findByPortfolio(portfolioId: string): Promise<Investment[]>;
  findByUser(userId: string): Promise<Investment[]>;
  create(data: Omit<Investment, 'id' | 'createdAt' | 'updatedAt'>): Promise<Investment>;
  update(id: string, data: Partial<Omit<Investment, 'id' | 'createdAt' | 'updatedAt' | 'portfolioId'>>): Promise<Investment>;
  delete(id: string): Promise<void>;
  findByPortfolioAndName(portfolioId: string, name: string): Promise<Investment | null>;
}

export const INVESTMENT_REPOSITORY = 'INVESTMENT_REPOSITORY';
