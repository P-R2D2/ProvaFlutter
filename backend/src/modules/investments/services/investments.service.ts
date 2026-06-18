import { Injectable, Inject, NotFoundException, ForbiddenException } from '@nestjs/common';
import { PrismaService } from '../../../prisma.service';
import { CreateInvestmentDto } from '../dtos/create-investment.dto';
import { UpdateInvestmentDto } from '../dtos/update-investment.dto';
import { AssetsService } from '../../assets/assets.service';

@Injectable()
export class InvestmentsService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly assetsService: AssetsService,
  ) {}

  private roundToTwo(value: number): number {
    return Number(value.toFixed(2));
  }

  async findById(id: string) {
    const investment = await this.prisma.investment.findUnique({ where: { id } });
    if (!investment) {
      throw new NotFoundException(`Investment with ID '${id}' not found`);
    }
    return investment;
  }

  async findByPortfolio(portfolioId: string) {
    return this.prisma.investment.findMany({ where: { portfolioId } });
  }

  async create(portfolioId: string, dto: CreateInvestmentDto) {
    // Basic verification just to ensure it doesn't crash if assetsService is called.
    try {
      if (dto.assetType === 'STOCK') {
        await this.assetsService.getDetails(dto.name);
      }
    } catch (error) {
      // Ignore
    }

    return this.prisma.investment.create({
      data: {
        name: dto.name,
        assetType: dto.assetType,
        quantity: dto.quantity,
        purchasePrice: dto.purchasePrice,
        purchaseDate: new Date(dto.purchaseDate),
        portfolioId: portfolioId,
      },
    });
  }

  async update(id: string, dto: UpdateInvestmentDto) {
    await this.findById(id);
    return this.prisma.investment.update({
      where: { id },
      data: {
        name: dto.name,
        assetType: dto.assetType,
        quantity: dto.quantity,
        purchasePrice: dto.purchasePrice,
        purchaseDate: dto.purchaseDate ? new Date(dto.purchaseDate) : undefined,
      },
    });
  }

  async delete(id: string): Promise<void> {
    await this.findById(id);
    await this.prisma.investment.delete({ where: { id } });
  }

  async getPortfolioValuation(userId: string) {
    const portfolios = await this.prisma.portfolio.findMany({
      where: { userId },
      include: { investments: true }
    });

    const investments = portfolios.flatMap(p => p.investments);

    const positions = await Promise.all(
      investments.map(async (investment) => {
        let currentPrice = investment.purchasePrice;
        let isDelayed = false;

        if (investment.assetType === 'STOCK') {
          try {
            const details = await this.assetsService.getDetails(investment.name);
            currentPrice = details.currentPrice;
          } catch (error) {
            isDelayed = true;
          }
        }

        const investedAmount = investment.quantity * investment.purchasePrice;
        const currentPositionValue = investment.quantity * currentPrice;
        const profitLoss = currentPositionValue - investedAmount;
        const profitLossPercentage = investedAmount > 0 
          ? (profitLoss / investedAmount) * 100 
          : 0;

        return {
          id: investment.id,
          name: investment.name,
          assetType: investment.assetType,
          quantity: investment.quantity,
          purchasePrice: investment.purchasePrice,
          purchaseDate: investment.purchaseDate,
          currentMarketPrice: currentPrice,
          investedAmount: this.roundToTwo(investedAmount),
          currentPositionValue: this.roundToTwo(currentPositionValue),
          profitLoss: this.roundToTwo(profitLoss),
          profitLossPercentage: this.roundToTwo(profitLossPercentage),
          isDelayed,
        };
      })
    );

    const totalInvested = positions.reduce((sum, p) => sum + p.investedAmount, 0);
    const totalCurrentValue = positions.reduce((sum, p) => sum + p.currentPositionValue, 0);
    const totalProfitLoss = totalCurrentValue - totalInvested;
    const totalReturnPercentage = totalInvested > 0 
      ? (totalProfitLoss / totalInvested) * 100 
      : 0;
    const anyDelayed = positions.some((p) => p.isDelayed);

    return {
      summary: {
        totalInvested: this.roundToTwo(totalInvested),
        totalCurrentValue: this.roundToTwo(totalCurrentValue),
        totalProfitLoss: this.roundToTwo(totalProfitLoss),
        totalReturnPercentage: this.roundToTwo(totalReturnPercentage),
        isDelayed: anyDelayed,
      },
      positions,
    };
  }
}
