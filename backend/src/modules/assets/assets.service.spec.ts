import { Test, TestingModule } from '@nestjs/testing';
import { HttpService } from '@nestjs/axios';
import { CACHE_MANAGER } from '@nestjs/cache-manager';
import { AssetsService } from './assets.service';

describe('AssetsService', () => {
  let service: AssetsService;
  let cacheManagerMock: any;

  beforeEach(async () => {
    cacheManagerMock = {
      get: jest.fn().mockResolvedValue(null),
      set: jest.fn().mockResolvedValue(null),
    };

    const module: TestingModule = await Test.createTestingModule({
      providers: [
        AssetsService,
        {
          provide: HttpService,
          useValue: {
            get: jest.fn(),
          },
        },
        {
          provide: CACHE_MANAGER,
          useValue: cacheManagerMock,
        },
      ],
    }).compile();

    service = module.get<AssetsService>(AssetsService);
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });

  describe('search', () => {
    it('should return filtered mock assets in mock mode', async () => {
      process.env.BRAPI_API_TOKEN = 'mock_brapi_api_token_value_for_local_development';
      const results = await service.search('PETR');
      expect(results.length).toBe(1);
      expect(results[0].symbol).toBe('PETR4');
    });

    it('should pull from cache if present', async () => {
      const mockCached = [{ symbol: 'XYZ3', name: 'XYZ Corp' }];
      cacheManagerMock.get.mockResolvedValue(mockCached);

      const results = await service.search('XYZ');
      expect(results).toEqual(mockCached);
      expect(cacheManagerMock.get).toHaveBeenCalledWith('assets:search:xyz');
    });
  });

  describe('getDetails', () => {
    it('should return mock details in mock mode', async () => {
      process.env.BRAPI_API_TOKEN = '';
      const results = await service.getDetails('VALE3');
      expect(results.symbol).toBe('VALE3');
      expect(results.currentPrice).toBe(62.40);
      expect(results.currency).toBe('BRL');
    });
  });
});
