export class PositionValuationDto {
  id: string;
  name: string;
  assetType: string;
  quantity: number;
  purchasePrice: number;
  currentMarketPrice: number;
  investedAmount: number;
  currentPositionValue: number;
  profitLoss: number;
  profitLossPercentage: number;
  isDelayed: boolean;
}

export class PortfolioValuationDto {
  summary: {
    totalInvested: number;
    totalCurrentValue: number;
    totalProfitLoss: number;
    totalReturnPercentage: number;
    isDelayed: boolean;
  };
  positions: PositionValuationDto[];
}
