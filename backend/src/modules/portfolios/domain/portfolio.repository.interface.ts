import { Portfolio } from './portfolio.entity';

export const PORTFOLIO_REPOSITORY = 'PORTFOLIO_REPOSITORY';

export interface PortfolioRepository {
  findById(id: string): Promise<Portfolio | null>;
  findByNameAndUser(name: string, userId: string): Promise<Portfolio | null>;
  findByUser(userId: string): Promise<Portfolio[]>;
  create(data: { name: string; description?: string; userId: string }): Promise<Portfolio>;
  update(id: string, data: { name?: string; description?: string }): Promise<Portfolio>;
  delete(id: string): Promise<void>;
}
