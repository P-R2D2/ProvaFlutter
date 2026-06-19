import { Injectable, Logger } from '@nestjs/common';
import { PrismaClient } from '@prisma/client';

export interface PortfolioSummary {
  userId: string;
  totalValue: number;
  allocationByCategory: Record<string, number>;
  diversificationScore: number;
  largestPositions: Array<{ name: string; percentage: number }>;
  generatedAt: Date;
}

@Injectable()
export class PortfolioSummaryService {
  private readonly logger = new Logger(PortfolioSummaryService.name);
  private prisma = new PrismaClient();
  
  private cache: Map<string, PortfolioSummary> = new Map();

  async generateSummary(userId: string): Promise<PortfolioSummary | null> {
    if (this.cache.has(userId)) {
      return this.cache.get(userId)!;
    }

    const userPortfolios = await this.prisma.portfolio.findMany({
      where: { userId },
      include: { investments: true }
    });

    if (!userPortfolios || userPortfolios.length === 0) {
      return null;
    }

    let totalValue = 0;
    const categoryTotals: Record<string, number> = {};
    const allInvestments: Array<{name: string, value: number, type: string}> = [];

    for (const portfolio of userPortfolios) {
      for (const inv of portfolio.investments) {
        const value = inv.quantity * inv.purchasePrice;
        totalValue += value;
        
        categoryTotals[inv.assetType] = (categoryTotals[inv.assetType] || 0) + value;
        allInvestments.push({ name: inv.name, value, type: inv.assetType });
      }
    }

    if (totalValue === 0) return null;

    const allocationByCategory: Record<string, number> = {};
    for (const [cat, val] of Object.entries(categoryTotals)) {
      allocationByCategory[cat] = Number(((val / totalValue) * 100).toFixed(2));
    }

    allInvestments.sort((a, b) => b.value - a.value);
    const largestPositions = allInvestments.slice(0, 3).map(inv => ({
      name: inv.name,
      percentage: Number(((inv.value / totalValue) * 100).toFixed(2))
    }));

    const numCategories = Object.keys(categoryTotals).length;
    let diversificationScore = Math.min(100, numCategories * 25);
    
    if (largestPositions.length > 0 && largestPositions[0].percentage > 40) {
      diversificationScore -= 20;
    }

    const summary: PortfolioSummary = {
      userId,
      totalValue,
      allocationByCategory,
      diversificationScore: Math.max(0, diversificationScore),
      largestPositions,
      generatedAt: new Date()
    };

    this.cache.set(userId, summary);
    return summary;
  }

  invalidateCache(userId: string) {
    this.cache.delete(userId);
    this.logger.log(`Invalidated portfolio summary cache for user ${userId}`);
  }
}
