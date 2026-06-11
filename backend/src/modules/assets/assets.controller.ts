import { Controller, Get, Query, Param, UseFilters } from '@nestjs/common';
import { AssetsService } from './assets.service';
import { SearchQueryDto } from './dto/search-query.dto';
import { MarketAssetDto } from './dto/market-asset.dto';
import { AssetDetailsDto } from './dto/asset-details.dto';
import { HttpExceptionFilter } from './filters/http-exception.filter';

@Controller('api/assets')
@UseFilters(HttpExceptionFilter)
export class AssetsController {
  constructor(private readonly assetsService: AssetsService) {}

  @Get('search')
  async search(@Query() searchQuery: SearchQueryDto): Promise<MarketAssetDto[]> {
    return this.assetsService.search(searchQuery.query);
  }

  @Get('details/:ticker')
  async getDetails(@Param('ticker') ticker: string): Promise<AssetDetailsDto> {
    return this.assetsService.getDetails(ticker);
  }
}
