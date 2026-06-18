import { Test, TestingModule } from '@nestjs/testing';
import { INestApplication, ValidationPipe } from '@nestjs/common';
import request from 'supertest';
import { App } from 'supertest/types';
import { AppModule } from './../src/app.module';
import { PrismaService } from './../src/prisma.service';

describe('InvestmentController (e2e)', () => {
  let app: INestApplication<App>;
  let prisma: PrismaService;
  let token1: string;
  let token2: string;
  let portfolio1Id: string;
  let portfolio2Id: string;

  beforeAll(async () => {
    const moduleFixture: TestingModule = await Test.createTestingModule({
      imports: [AppModule],
    }).compile();

    app = moduleFixture.createNestApplication();
    app.useGlobalPipes(
      new ValidationPipe({
        whitelist: true,
        forbidNonWhitelisted: true,
        transform: true,
      }),
    );
    await app.init();

    prisma = app.get(PrismaService);

    // Clean DB
    await prisma.investment.deleteMany({});
    await prisma.portfolio.deleteMany({});
    await prisma.user.deleteMany({});

    // Register & Login User 1
    await request(app.getHttpServer())
      .post('/auth/register')
      .send({ email: 'user1@example.com', password: 'Password123!' });

    const loginRes1 = await request(app.getHttpServer())
      .post('/auth/login')
      .send({ email: 'user1@example.com', password: 'Password123!' });
    token1 = loginRes1.body.accessToken;

    const user1 = await prisma.user.findUnique({ where: { email: 'user1@example.com' } });

    // Create Portfolio for User 1
    const p1 = await prisma.portfolio.create({
      data: { name: 'Tech Portfolio', userId: user1!.id },
    });
    portfolio1Id = p1.id;

    // Register & Login User 2
    await request(app.getHttpServer())
      .post('/auth/register')
      .send({ email: 'user2@example.com', password: 'Password123!' });

    const loginRes2 = await request(app.getHttpServer())
      .post('/auth/login')
      .send({ email: 'user2@example.com', password: 'Password123!' });
    token2 = loginRes2.body.accessToken;

    const user2 = await prisma.user.findUnique({ where: { email: 'user2@example.com' } });

    // Create Portfolio for User 2
    const p2 = await prisma.portfolio.create({
      data: { name: 'Crypto Portfolio', userId: user2!.id },
    });
    portfolio2Id = p2.id;
  });

  afterAll(async () => {
    await prisma.$disconnect();
    await app.close();
  });

  describe('POST /portfolios/:portfolioId/investments', () => {
    it('should add a new investment to the portfolio successfully', async () => {
      const response = await request(app.getHttpServer())
        .post(`/portfolios/${portfolio1Id}/investments`)
        .set('Authorization', `Bearer ${token1}`)
        .send({
          name: 'PETR4',
          assetType: 'STOCK',
          quantity: 10,
          purchasePrice: 30,
          purchaseDate: new Date().toISOString(),
          portfolioId: portfolio1Id,
        })
        .expect(201);

      expect(response.body).toHaveProperty('id');
      expect(response.body.name).toBe('PETR4');
      expect(response.body.quantity).toBe(10);
      expect(response.body.purchasePrice).toBe(30);
    });

    it('should block non-owners from adding investments', async () => {
      await request(app.getHttpServer())
        .post(`/portfolios/${portfolio1Id}/investments`)
        .set('Authorization', `Bearer ${token2}`)
        .send({
          name: 'VALE3',
          assetType: 'STOCK',
          quantity: 20,
          purchasePrice: 60,
          purchaseDate: new Date().toISOString(),
          portfolioId: portfolio1Id,
        })
        .expect(403);
    });
  });

  describe('GET /portfolios/:portfolioId/investments', () => {
    it('should retrieve investments of a portfolio for the owner', async () => {
      const response = await request(app.getHttpServer())
        .get(`/portfolios/${portfolio1Id}/investments`)
        .set('Authorization', `Bearer ${token1}`)
        .expect(200);

      expect(response.body.length).toBe(1);
      expect(response.body[0].name).toBe('PETR4');
    });

    it('should block non-owners from listing investments', async () => {
      await request(app.getHttpServer())
        .get(`/portfolios/${portfolio1Id}/investments`)
        .set('Authorization', `Bearer ${token2}`)
        .expect(403);
    });
  });

  describe('PUT /investments/:id', () => {
    let investmentId: string;

    beforeAll(async () => {
      const investments = await prisma.investment.findMany({ where: { portfolioId: portfolio1Id } });
      investmentId = investments[0].id;
    });

    it('should update investment quantity for the owner', async () => {
      const response = await request(app.getHttpServer())
        .put(`/investments/${investmentId}`)
        .set('Authorization', `Bearer ${token1}`)
        .send({ quantity: 50 })
        .expect(200);

      expect(response.body.quantity).toBe(50);
    });

    it('should block non-owners from updating investment', async () => {
      await request(app.getHttpServer())
        .put(`/investments/${investmentId}`)
        .set('Authorization', `Bearer ${token2}`)
        .send({ quantity: 100 })
        .expect(403);
    });
  });

  describe('DELETE /investments/:id', () => {
    let investmentId: string;

    beforeAll(async () => {
      const investments = await prisma.investment.findMany({ where: { portfolioId: portfolio1Id } });
      investmentId = investments[0].id;
    });

    it('should block non-owners from deleting investment', async () => {
      await request(app.getHttpServer())
        .delete(`/investments/${investmentId}`)
        .set('Authorization', `Bearer ${token2}`)
        .expect(403);
    });

    it('should allow owner to delete investment', async () => {
      await request(app.getHttpServer())
        .delete(`/investments/${investmentId}`)
        .set('Authorization', `Bearer ${token1}`)
        .expect(200);

      const deleted = await prisma.investment.findUnique({ where: { id: investmentId } });
      expect(deleted).toBeNull();
    });
  });

  describe('Cascading Delete', () => {
    it('should delete all investments when the parent portfolio is deleted', async () => {
      // Create new investment
      const tempInvestment = await prisma.investment.create({
        data: {
          name: 'VALE3',
          assetType: 'STOCK',
          quantity: 10,
          purchasePrice: 50,
          purchaseDate: new Date(),
          portfolioId: portfolio2Id,
        },
      });

      // Verify it exists
      const beforeDelete = await prisma.investment.findUnique({ where: { id: tempInvestment.id } });
      expect(beforeDelete).not.toBeNull();

      // Delete portfolio
      await request(app.getHttpServer())
        .delete(`/portfolios/${portfolio2Id}`)
        .set('Authorization', `Bearer ${token2}`)
        .expect(200);

      // Verify investment is gone
      const afterDelete = await prisma.investment.findUnique({ where: { id: tempInvestment.id } });
      expect(afterDelete).toBeNull();
    });
  });
});
