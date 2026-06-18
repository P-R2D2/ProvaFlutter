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

  @Post('investments')
  async createDefaultRoot(@Request() req: any, @Body() dto: CreateInvestmentDto) {
    // Just delegating the root /investments to the service method directly 
    // since the portfolioId is inside the DTO now.
    const userId = req.user.id;
    const portfolio = await this.prisma.portfolio.findUnique({ where: { id: dto.portfolioId } });
    if (!portfolio || portfolio.userId !== userId) {
      throw new Error('Portfolio access denied or not found');
    }
    return this.investmentsService.create(dto.portfolioId, dto);
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
