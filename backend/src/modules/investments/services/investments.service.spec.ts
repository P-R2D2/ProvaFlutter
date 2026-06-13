import { Test, TestingModule } from '@nestjs/testing';
import { NotFoundException } from '@nestjs/common';
import { InvestmentsService } from './investments.service';
import { INVESTMENT_REPOSITORY } from '../domain/investment.repository.interface';
import { AssetsService } from '../../assets/assets.service';

describe('InvestmentsService', () => {
  let service: InvestmentsService;
  let repo: any;
  let assetsService: AssetsService;

  const mockInvestmentRepository = {
    findById: jest.fn(),
    findByPortfolio: jest.fn(),
    findByUser: jest.fn(),
    create: jest.fn(),
    update: jest.fn(),
    delete: jest.fn(),
    findByPortfolioAndSymbol: jest.fn(),
  };

  const mockAssetsService = {
    getDetails: jest.fn(),
  };

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        InvestmentsService,
        {
          provide: INVESTMENT_REPOSITORY,
          useValue: mockInvestmentRepository,
        },
        {
          provide: AssetsService,
          useValue: mockAssetsService,
        },
      ],
    }).compile();

    service = module.get<InvestmentsService>(InvestmentsService);
    repo = module.get<any>(INVESTMENT_REPOSITORY);
    assetsService = module.get<AssetsService>(AssetsService);

    jest.clearAllMocks();
  });

  describe('create', () => {
    it('should create a new investment position if it does not exist', async () => {
      const dto = { assetSymbol: 'petr4', assetName: 'Petrobras', quantity: 10, averagePurchasePrice: 30 };
      mockAssetsService.getDetails.mockResolvedValue({ currentPrice: 35, name: 'Petrobras' });
      repo.findByPortfolioAndSymbol.mockResolvedValue(null);
      repo.create.mockResolvedValue({ id: 'id1', ...dto, assetSymbol: 'PETR4', portfolioId: 'portfolio1' });

      const result = await service.create('portfolio1', dto);

      expect(assetsService.getDetails).toHaveBeenCalledWith('PETR4');
      expect(repo.findByPortfolioAndSymbol).toHaveBeenCalledWith('portfolio1', 'PETR4');
      expect(repo.create).toHaveBeenCalledWith({
        assetSymbol: 'PETR4',
        assetName: 'Petrobras',
        quantity: 10,
        averagePurchasePrice: 30,
        portfolioId: 'portfolio1',
      });
      expect(result.assetSymbol).toBe('PETR4');
    });

    it('should update and average an existing position', async () => {
      const dto = { assetSymbol: 'PETR4', assetName: 'Petrobras', quantity: 15, averagePurchasePrice: 28 };
      const existing = { id: 'id1', portfolioId: 'portfolio1', assetSymbol: 'PETR4', quantity: 10, averagePurchasePrice: 30 };
      mockAssetsService.getDetails.mockResolvedValue({ currentPrice: 35, name: 'Petrobras' });
      repo.findByPortfolioAndSymbol.mockResolvedValue(existing);
      repo.update.mockResolvedValue({ ...existing, quantity: 25, averagePurchasePrice: 28.8 });

      await service.create('portfolio1', dto);

      expect(repo.update).toHaveBeenCalledWith('id1', {
        quantity: 25,
        averagePurchasePrice: 28.8,
      });
    });
  });

  describe('delete', () => {
    it('should remove position successfully', async () => {
      const existing = { id: 'id1', portfolioId: 'portfolio1', assetSymbol: 'PETR4' };
      repo.findById.mockResolvedValue(existing);
      repo.delete.mockResolvedValue(undefined);

      await service.delete('id1');

      expect(repo.findById).toHaveBeenCalledWith('id1');
      expect(repo.delete).toHaveBeenCalledWith('id1');
    });

    it('should throw NotFoundException if position missing', async () => {
      repo.findById.mockResolvedValue(null);

      await expect(service.delete('id1')).rejects.toThrow(NotFoundException);
    });
  });

  describe('getPortfolioValuation', () => {
    it('should return aggregated valuation with exact two decimals precision', async () => {
      const investments = [
        { id: 'id1', assetSymbol: 'PETR4', assetName: 'Petrobras', quantity: 10, averagePurchasePrice: 30 },
        { id: 'id2', assetSymbol: 'VALE3', assetName: 'Vale', quantity: 5, averagePurchasePrice: 60 },
      ];
      repo.findByUser.mockResolvedValue(investments);
      mockAssetsService.getDetails.mockImplementation(async (symbol) => {
        if (symbol === 'PETR4') return { currentPrice: 35.555, name: 'Petrobras' };
        if (symbol === 'VALE3') return { currentPrice: 58.213, name: 'Vale' };
      });

      const valuation = await service.getPortfolioValuation('user1');

      // PETR4:
      // invested = 10 * 30 = 300.00
      // value = 10 * 35.555 = 355.55
      // profitLoss = 355.55 - 300 = 55.55
      // profitLoss% = (55.55 / 300) * 100 = 18.52%
      expect(valuation.positions[0].investedAmount).toBe(300);
      expect(valuation.positions[0].currentPositionValue).toBe(355.55);
      expect(valuation.positions[0].profitLossPercentage).toBe(18.52);

      // Total return check
      expect(valuation.summary.totalInvested).toBe(600);
      expect(valuation.summary.totalCurrentValue).toBe(646.61);
      expect(valuation.summary.totalProfitLoss).toBe(46.61);
      expect(valuation.summary.isDelayed).toBe(false);
    });

    it('should handle API outage fallback gracefully and flag delay', async () => {
      const investments = [{ id: 'id1', assetSymbol: 'PETR4', assetName: 'Petrobras', quantity: 10, averagePurchasePrice: 30 }];
      repo.findByUser.mockResolvedValue(investments);
      mockAssetsService.getDetails.mockRejectedValue(new Error('API Out of Service'));

      const valuation = await service.getPortfolioValuation('user1');

      expect(valuation.positions[0].currentMarketPrice).toBe(30); // fallback to purchase price
      expect(valuation.positions[0].isDelayed).toBe(true);
      expect(valuation.summary.isDelayed).toBe(true);
    });
  });
});
