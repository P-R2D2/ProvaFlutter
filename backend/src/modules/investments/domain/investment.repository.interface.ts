import { Investment } from './investment.entity';

export const INVESTMENT_REPOSITORY = 'INVESTMENT_REPOSITORY';

export interface InvestmentRepository {
  findById(id: string): Promise<Investment | null>;
  findByPortfolio(portfolioId: string): Promise<Investment[]>;
  findByUser(userId: string): Promise<Investment[]>;
  create(data: {
    assetSymbol: string;
    assetName: string;
    quantity: number;
    averagePurchasePrice: number;
    portfolioId: string;
  }): Promise<Investment>;
  update(
    id: string,
    data: {
      quantity?: number;
      averagePurchasePrice?: number;
    },
  ): Promise<Investment>;
  delete(id: string): Promise<void>;
  findByPortfolioAndSymbol(portfolioId: string, assetSymbol: string): Promise<Investment | null>;
}
