import { Injectable, Inject, Logger, NotFoundException } from '@nestjs/common';
import { HttpService } from '@nestjs/axios';
import { CACHE_MANAGER } from '@nestjs/cache-manager';
import type { Cache } from 'cache-manager';
import { firstValueFrom } from 'rxjs';
import { MarketAssetDto } from './dto/market-asset.dto';
import { AssetDetailsDto } from './dto/asset-details.dto';

@Injectable()
export class AssetsService {
  private readonly logger = new Logger(AssetsService.name);

  private readonly mockAssets = [
    { symbol: 'PETR4', name: 'Petroleo Brasileiro S.A. - Petrobras' },
    { symbol: 'VALE3', name: 'VALE S.A.' },
    { symbol: 'ITUB4', name: 'Itau Unibanco Holding S.A.' },
    { symbol: 'BBDC4', name: 'Banco Bradesco S.A.' },
    { symbol: 'BBAS3', name: 'Banco do Brasil S.A.' },
    { symbol: 'MGLU3', name: 'Magazine Luiza S.A.' },
  ];

  constructor(
    private readonly httpService: HttpService,
    @Inject(CACHE_MANAGER) private readonly cacheManager: Cache,
  ) {}

  private isMockMode(): boolean {
    const token = process.env.BRAPI_API_TOKEN;
    return !token || token === 'mock_brapi_api_token_value_for_local_development';
  }

  async search(query: string): Promise<MarketAssetDto[]> {
    const cacheKey = `assets:search:${query.toLowerCase()}`;
    const cached = await this.cacheManager.get<MarketAssetDto[]>(cacheKey);
    if (cached) {
      this.logger.log(`Cache hit for search query: ${query}`);
      return cached;
    }

    let results: MarketAssetDto[] = [];

    if (this.isMockMode()) {
      this.logger.log(`Mock mode active. Generating mock search results for query: ${query}`);
      results = this.mockAssets.filter(
        (asset) =>
          asset.symbol.toLowerCase().includes(query.toLowerCase()) ||
          asset.name.toLowerCase().includes(query.toLowerCase()),
      );
    } else {
      try {
        const token = process.env.BRAPI_API_TOKEN;
        const url = `https://brapi.dev/api/quote/list?search=${encodeURIComponent(query)}&token=${token}`;

        const response = await firstValueFrom(this.httpService.get<any>(url));
        const stocks = response.data?.stocks || [];

        results = stocks.map((item: any) => ({
          symbol: item.stock || item.symbol || '',
          name: item.name || item.name || '',
        }));
      } catch (error) {
        this.logger.error(`Error fetching search results from Brapi: ${error.message}. Falling back to mock data.`);
        results = this.mockAssets.filter(
          (asset) =>
            asset.symbol.toLowerCase().includes(query.toLowerCase()) ||
            asset.name.toLowerCase().includes(query.toLowerCase()),
        );
      }
    }

    await this.cacheManager.set(cacheKey, results, 300);
    return results;
  }

  async getDetails(ticker: string): Promise<AssetDetailsDto> {
    const uppercaseTicker = ticker.toUpperCase();
    const cacheKey = `assets:details:${uppercaseTicker}`;
    const cached = await this.cacheManager.get<AssetDetailsDto>(cacheKey);
    if (cached) {
      this.logger.log(`Cache hit for asset details: ${uppercaseTicker}`);
      return cached;
    }

    let details: AssetDetailsDto;

    if (this.isMockMode()) {
      this.logger.log(`Mock mode active. Generating mock details for ticker: ${uppercaseTicker}`);
      const matchedMock = this.mockAssets.find(
        (asset) => asset.symbol.toUpperCase() === uppercaseTicker,
      );

      const basePrice = uppercaseTicker === 'PETR4' ? 38.50
                      : uppercaseTicker === 'VALE3' ? 62.40
                      : uppercaseTicker === 'ITUB4' ? 33.20
                      : 45.00;

      details = {
        symbol: uppercaseTicker,
        name: matchedMock?.name || `${uppercaseTicker} S.A.`,
        currentPrice: basePrice,
        dayHigh: basePrice + 1.25,
        dayLow: basePrice - 0.75,
        changePercent: 1.45,
        currency: 'BRL',
        updatedAt: new Date().toISOString(),
      };
    } else {
      try {
        const token = process.env.BRAPI_API_TOKEN;
        const url = `https://brapi.dev/api/quote/${uppercaseTicker}?token=${token}`;

        const response = await firstValueFrom(this.httpService.get<any>(url));
        const result = response.data?.results?.[0];

        if (!result) {
          throw new NotFoundException(`Asset with ticker '${uppercaseTicker}' not found`);
        }

        details = {
          symbol: result.symbol || uppercaseTicker,
          name: result.longName || result.shortName || result.symbol || '',
          currentPrice: Number(result.regularMarketPrice) || 0,
          dayHigh: Number(result.regularMarketDayHigh) || 0,
          dayLow: Number(result.regularMarketDayLow) || 0,
          changePercent: Number(result.regularMarketChangePercent) || 0,
          currency: result.currency || 'BRL',
          updatedAt: result.regularMarketTime || new Date().toISOString(),
        };
      } catch (error) {
        if (error instanceof NotFoundException) {
          throw error;
        }

        this.logger.error(`Error fetching detailed quote for ${uppercaseTicker}: ${error.message}. Falling back to mock details.`);
        const matchedMock = this.mockAssets.find(
          (asset) => asset.symbol.toUpperCase() === uppercaseTicker,
        );

        const basePrice = 42.80;
        details = {
          symbol: uppercaseTicker,
          name: matchedMock?.name || `${uppercaseTicker} S.A.`,
          currentPrice: basePrice,
          dayHigh: basePrice + 0.95,
          dayLow: basePrice - 1.15,
          changePercent: -0.45,
          currency: 'BRL',
          updatedAt: new Date().toISOString(),
        };
      }
    }

    await this.cacheManager.set(cacheKey, details, 60);
    return details;
  }
}
