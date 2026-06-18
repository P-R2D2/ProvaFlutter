import { Test, TestingModule } from '@nestjs/testing';
import { NotFoundException } from '@nestjs/common';
import { InvestmentsService } from './investments.service';
import { INVESTMENT_REPOSITORY } from '../domain/investment.repository.interface';
import { AssetsService } from '../../assets/assets.service';
import { PrismaService } from '../../../prisma.service';

describe('InvestmentsService', () => {
  let service: InvestmentsService;
  let repo: any;
  let assetsService: AssetsService;
  let prisma: any;

  const mockPrismaService = {
    investment: {
      findUnique: jest.fn(),
      findMany: jest.fn(),
      create: jest.fn(),
      update: jest.fn(),
      delete: jest.fn(),
      findFirst: jest.fn(),
    },
    portfolio: {
      findMany: jest.fn(),
    }
  };

  const mockAssetsService = {
    getDetails: jest.fn(),
  };

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        InvestmentsService,
        {
          provide: PrismaService,
          useValue: mockPrismaService,
        },
        {
          provide: AssetsService,
          useValue: mockAssetsService,
        },
        // Kept for backward compatibility if needed, though we use PrismaService directly now
        {
          provide: INVESTMENT_REPOSITORY,
          useValue: {},
        }
      ],
    }).compile();

    service = module.get<InvestmentsService>(InvestmentsService);
    prisma = module.get<PrismaService>(PrismaService);
    assetsService = module.get<AssetsService>(AssetsService);

    jest.clearAllMocks();
  });

  describe('create', () => {
    it('should create a new investment position', async () => {
      const dto = { name: 'PETR4', assetType: 'STOCK', quantity: 10, purchasePrice: 30, purchaseDate: '2023-01-01T00:00:00.000Z', portfolioId: 'portfolio1' };
      mockAssetsService.getDetails.mockResolvedValue({ currentPrice: 35, name: 'Petrobras' });
      mockPrismaService.investment.create.mockResolvedValue({ id: 'id1', ...dto, portfolioId: 'portfolio1' });

      const result = await service.create('portfolio1', dto);

      expect(assetsService.getDetails).toHaveBeenCalledWith('PETR4');
      expect(mockPrismaService.investment.create).toHaveBeenCalledWith({
        data: {
          name: 'PETR4',
          assetType: 'STOCK',
          quantity: 10,
          purchasePrice: 30,
          purchaseDate: new Date('2023-01-01T00:00:00.000Z'),
          portfolioId: 'portfolio1',
        }
      });
      expect(result.name).toBe('PETR4');
    });
  });

  describe('delete', () => {
    it('should remove position successfully', async () => {
      const existing = { id: 'id1', portfolioId: 'portfolio1', name: 'PETR4' };
      mockPrismaService.investment.findUnique.mockResolvedValue(existing);
      mockPrismaService.investment.delete.mockResolvedValue(undefined);

      await service.delete('id1');

      expect(mockPrismaService.investment.findUnique).toHaveBeenCalledWith({ where: { id: 'id1' } });
      expect(mockPrismaService.investment.delete).toHaveBeenCalledWith({ where: { id: 'id1' } });
    });

    it('should throw NotFoundException if position missing', async () => {
      mockPrismaService.investment.findUnique.mockResolvedValue(null);

      await expect(service.delete('id1')).rejects.toThrow(NotFoundException);
    });
  });

  describe('getPortfolioValuation', () => {
    it('should return aggregated valuation with exact two decimals precision', async () => {
      const portfolios = [{
        id: 'portfolio1',
        userId: 'user1',
        investments: [
          { id: 'id1', name: 'PETR4', assetType: 'STOCK', quantity: 10, purchasePrice: 30 },
          { id: 'id2', name: 'VALE3', assetType: 'STOCK', quantity: 5, purchasePrice: 60 },
        ]
      }];
      mockPrismaService.portfolio.findMany.mockResolvedValue(portfolios);
      mockAssetsService.getDetails.mockImplementation(async (symbol) => {
        if (symbol === 'PETR4') return { currentPrice: 35.555, name: 'Petrobras' };
        if (symbol === 'VALE3') return { currentPrice: 58.213, name: 'Vale' };
      });

      const valuation = await service.getPortfolioValuation('user1');

      expect(valuation.positions[0].investedAmount).toBe(300);
      expect(valuation.positions[0].currentPositionValue).toBe(355.55);
      expect(valuation.positions[0].profitLossPercentage).toBe(18.52);

      expect(valuation.summary.totalInvested).toBe(600);
      expect(valuation.summary.totalCurrentValue).toBe(646.61);
      expect(valuation.summary.totalProfitLoss).toBe(46.61);
      expect(valuation.summary.isDelayed).toBe(false);
    });

    it('should handle API outage fallback gracefully and flag delay', async () => {
      const portfolios = [{
        id: 'portfolio1',
        userId: 'user1',
        investments: [
          { id: 'id1', name: 'PETR4', assetType: 'STOCK', quantity: 10, purchasePrice: 30 }
        ]
      }];
      mockPrismaService.portfolio.findMany.mockResolvedValue(portfolios);
      mockAssetsService.getDetails.mockRejectedValue(new Error('API Out of Service'));

      const valuation = await service.getPortfolioValuation('user1');

      expect(valuation.positions[0].currentMarketPrice).toBe(30);
      expect(valuation.positions[0].isDelayed).toBe(true);
      expect(valuation.summary.isDelayed).toBe(true);
    });
  });
});
