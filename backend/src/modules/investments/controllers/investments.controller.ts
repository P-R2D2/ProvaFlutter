import { Controller, Get, Post, Put, Delete, Body, Param, Request, UseGuards } from '@nestjs/common';
import { InvestmentsService } from '../services/investments.service';
import { CreateInvestmentDto } from '../dtos/create-investment.dto';
import { UpdateInvestmentDto } from '../dtos/update-investment.dto';
import { OwnershipGuard } from '../../../common/guards/ownership.guard';
import { PrismaService } from '../../../prisma.service';

@Controller()
export class InvestmentsController {
  constructor(
    private readonly investmentsService: InvestmentsService,
    private readonly prisma: PrismaService,
  ) {}

  @Get('api/investments')
  async getValuationApi(@Request() req: any) {
    return this.getValuation(req);
  }

  @Get('investments')
  async getValuation(@Request() req: any) {
    const userId = req.user.id;
    return this.investmentsService.getPortfolioValuation(userId);
  }

  @Post('api/investments')
  async createDefault(@Request() req: any, @Body() body: any) {
    const userId = req.user.id;

    let portfolio = await this.prisma.portfolio.findFirst({
      where: { userId },
    });

    if (!portfolio) {
      portfolio = await this.prisma.portfolio.create({
        data: {
          name: 'Default Portfolio',
          userId,
        },
      });
    }

    const assetSymbol = (body.symbol || body.assetSymbol || '').toUpperCase();
    const assetName = body.assetName || body.name || assetSymbol;
    const quantity = Number(body.quantity);
    const averagePurchasePrice = Number(body.averagePurchasePrice);

    return this.investmentsService.create(portfolio.id, {
      assetSymbol,
      assetName,
      quantity,
      averagePurchasePrice,
    });
  }

  @UseGuards(OwnershipGuard)
  @Post('portfolios/:portfolioId/investments')
  async create(
    @Param('portfolioId') portfolioId: string,
    @Body() dto: CreateInvestmentDto,
  ) {
    return this.investmentsService.create(portfolioId, dto);
  }

  @UseGuards(OwnershipGuard)
  @Get('portfolios/:portfolioId/investments')
  async findByPortfolio(@Param('portfolioId') portfolioId: string) {
    return this.investmentsService.findByPortfolio(portfolioId);
  }

  @UseGuards(OwnershipGuard)
  @Put('investments/:id')
  async update(
    @Param('id') id: string,
    @Body() dto: UpdateInvestmentDto,
  ) {
    return this.investmentsService.update(id, dto);
  }

  @UseGuards(OwnershipGuard)
  @Delete('api/investments/:id')
  async deleteApi(@Param('id') id: string) {
    return this.delete(id);
  }

  @UseGuards(OwnershipGuard)
  @Delete('investments/:id')
  async delete(@Param('id') id: string) {
    await this.investmentsService.delete(id);
    return { success: true, message: 'Investment successfully deleted' };
  }
}
