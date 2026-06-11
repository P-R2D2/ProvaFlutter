export class PortfolioPositionDto {
  id: string;
  symbol: string;
  name: string;
  quantity: number;
  averagePurchasePrice: number;
  currentMarketPrice: number;
  investedAmount: number;
  currentPositionValue: number;
  profitLoss: number;
  profitLossPercentage: number;
  isDelayed: boolean;
}

export class PortfolioSummaryDto {
  totalInvested: number;
  totalCurrentValue: number;
  totalProfitLoss: number;
  totalReturnPercentage: number;
  isDelayed: boolean;
}

export class PortfolioValuationDto {
  summary: PortfolioSummaryDto;
  positions: PortfolioPositionDto[];
}
