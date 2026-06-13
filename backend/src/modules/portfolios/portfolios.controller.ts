import { Controller, Get, Post, Put, Delete, Body, Param, Request, UseGuards } from '@nestjs/common';
import { PortfoliosService } from './portfolios.service';
import { CreatePortfolioDto } from './dtos/create-portfolio.dto';
import { UpdatePortfolioDto } from './dtos/update-portfolio.dto';
import { OwnershipGuard } from '../../common/guards/ownership.guard';

@Controller('portfolios')
export class PortfoliosController {
  constructor(private readonly portfoliosService: PortfoliosService) {}

  @Get()
  async findAll(@Request() req: any) {
    return this.portfoliosService.findByUser(req.user.id);
  }

  @UseGuards(OwnershipGuard)
  @Get(':id')
  async findOne(@Param('id') id: string) {
    return this.portfoliosService.findById(id);
  }

  @Post()
  async create(@Request() req: any, @Body() createPortfolioDto: CreatePortfolioDto) {
    return this.portfoliosService.create(req.user.id, createPortfolioDto);
  }

  @UseGuards(OwnershipGuard)
  @Put(':id')
  async update(
    @Param('id') id: string,
    @Request() req: any,
    @Body() updatePortfolioDto: UpdatePortfolioDto,
  ) {
    return this.portfoliosService.update(id, req.user.id, updatePortfolioDto);
  }

  @UseGuards(OwnershipGuard)
  @Delete(':id')
  async remove(@Param('id') id: string) {
    await this.portfoliosService.delete(id);
    return { message: 'Portfolio deleted successfully' };
  }
}
