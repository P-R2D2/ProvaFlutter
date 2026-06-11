import { Injectable, Inject, NotFoundException } from '@nestjs/common';
import { INVESTMENT_REPOSITORY } from '../domain/investment.repository.interface';
import type { InvestmentRepository } from '../domain/investment.repository.interface';
import { Investment } from '../domain/investment.entity';
import { CreateInvestmentDto } from '../dtos/create-investment.dto';
import { UpdateInvestmentDto } from '../dtos/update-investment.dto';
import { AssetsService } from '../../assets/assets.service';

@Injectable()
export class InvestmentsService {
  constructor(
    @Inject(INVESTMENT_REPOSITORY)
    private readonly investmentRepository: InvestmentRepository,
    private readonly assetsService: AssetsService,
  ) {}

  private roundToTwo(value: number): number {
    return Number(value.toFixed(2));
  }

  async findById(id: string): Promise<Investment> {
    const investment = await this.investmentRepository.findById(id);
    if (!investment) {
      throw new NotFoundException(`Investment with ID '${id}' not found`);
    }
    return investment;
  }

  async findByPortfolio(portfolioId: string): Promise<Investment[]> {
    return this.investmentRepository.findByPortfolio(portfolioId);
  }

  async create(portfolioId: string, dto: CreateInvestmentDto): Promise<Investment> {
    const uppercaseSymbol = dto.assetSymbol.toUpperCase();

    try {
      await this.assetsService.getDetails(uppercaseSymbol);
    } catch (error) {
      // If verification fails but we still want to save, proceed
    }

    const existing = await this.investmentRepository.findByPortfolioAndSymbol(portfolioId, uppercaseSymbol);
    if (existing) {
      const newQuantity = existing.quantity + dto.quantity;
      const newAveragePrice =
        (existing.quantity * existing.averagePurchasePrice + dto.quantity * dto.averagePurchasePrice) / newQuantity;

      return this.investmentRepository.update(existing.id, {
        quantity: newQuantity,
        averagePurchasePrice: this.roundToTwo(newAveragePrice),
      });
    }

    return this.investmentRepository.create({
      assetSymbol: uppercaseSymbol,
      assetName: dto.assetName,
      quantity: dto.quantity,
      averagePurchasePrice: dto.averagePurchasePrice,
      portfolioId,
    });
  }

  async update(id: string, dto: UpdateInvestmentDto): Promise<Investment> {
    await this.findById(id);
    return this.investmentRepository.update(id, dto);
  }

  async delete(id: string): Promise<void> {
    await this.findById(id);
    await this.investmentRepository.delete(id);
  }

  async getPortfolioValuation(userId: string): Promise<any> {
    const investments = await this.investmentRepository.findByUser(userId);

    const positions = await Promise.all(
      investments.map(async (investment) => {
        let currentPrice = investment.averagePurchasePrice;
        let isDelayed = false;
        let assetName = investment.assetName;

        try {
          const details = await this.assetsService.getDetails(investment.assetSymbol);
          currentPrice = details.currentPrice;
          assetName = details.name;
        } catch (error) {
          isDelayed = true;
        }

        const investedAmount = investment.quantity * investment.averagePurchasePrice;
        const currentPositionValue = investment.quantity * currentPrice;
        const profitLoss = currentPositionValue - investedAmount;
        const profitLossPercentage = investedAmount > 0 
          ? (profitLoss / investedAmount) * 100 
          : 0;

        return {
          id: investment.id,
          symbol: investment.assetSymbol,
          name: assetName,
          quantity: investment.quantity,
          averagePurchasePrice: investment.averagePurchasePrice,
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
