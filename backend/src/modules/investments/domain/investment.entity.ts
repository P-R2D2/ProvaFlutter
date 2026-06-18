export interface Investment {
  id: string;
  name: string;
  assetType: string;
  quantity: number;
  purchasePrice: number;
  purchaseDate: Date;
  portfolioId: string;
  createdAt: Date;
  updatedAt: Date;
}
