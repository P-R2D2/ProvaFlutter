import { Test, TestingModule } from '@nestjs/testing';
import { INestApplication, ValidationPipe } from '@nestjs/common';
import request from 'supertest';
import { App } from 'supertest/types';
import { AppModule } from './../src/app.module';
import { PrismaService } from './../src/prisma.service';

describe('PortfolioController (e2e)', () => {
  let app: INestApplication<App>;
  let prisma: PrismaService;
  let token1: string;
  let token2: string;
  let user1Id: string;
  let user2Id: string;

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
    user1Id = user1!.id;

    // Register & Login User 2
    await request(app.getHttpServer())
      .post('/auth/register')
      .send({ email: 'user2@example.com', password: 'Password123!' });

    const loginRes2 = await request(app.getHttpServer())
      .post('/auth/login')
      .send({ email: 'user2@example.com', password: 'Password123!' });
    token2 = loginRes2.body.accessToken;

    const user2 = await prisma.user.findUnique({ where: { email: 'user2@example.com' } });
    user2Id = user2!.id;
  });

  afterAll(async () => {
    await prisma.$disconnect();
    await app.close();
  });

  describe('/portfolios (POST)', () => {
    it('should create a portfolio successfully', async () => {
      const response = await request(app.getHttpServer())
        .post('/portfolios')
        .set('Authorization', `Bearer ${token1}`)
        .send({ name: 'Tech Investments', description: 'Tech stocks portfolio' })
        .expect(201);

      expect(response.body).toHaveProperty('id');
      expect(response.body.name).toBe('Tech Investments');
      expect(response.body.userId).toBe(user1Id);
    });

    it('should reject duplicate portfolio names for the same user', async () => {
      await request(app.getHttpServer())
        .post('/portfolios')
        .set('Authorization', `Bearer ${token1}`)
        .send({ name: 'Tech Investments' })
        .expect(409);
    });

    it('should allow another user to create a portfolio with the same name', async () => {
      const response = await request(app.getHttpServer())
        .post('/portfolios')
        .set('Authorization', `Bearer ${token2}`)
        .send({ name: 'Tech Investments' })
        .expect(201);

      expect(response.body.userId).toBe(user2Id);
    });
  });

  describe('/portfolios (GET)', () => {
    it('should return only portfolios owned by the authenticated user', async () => {
      const res = await request(app.getHttpServer())
        .get('/portfolios')
        .set('Authorization', `Bearer ${token1}`)
        .expect(200);

      expect(res.body.length).toBe(1);
      expect(res.body[0].name).toBe('Tech Investments');
      expect(res.body[0].userId).toBe(user1Id);
    });
  });

  describe('/portfolios/:id (GET)', () => {
    let portfolioId: string;

    beforeAll(async () => {
      const portfolios = await prisma.portfolio.findMany({ where: { userId: user1Id } });
      portfolioId = portfolios[0].id;
    });

    it('should return portfolio details for the owner', async () => {
      const response = await request(app.getHttpServer())
        .get(`/portfolios/${portfolioId}`)
        .set('Authorization', `Bearer ${token1}`)
        .expect(200);

      expect(response.body.name).toBe('Tech Investments');
    });

    it('should block non-owners from retrieving portfolio details', async () => {
      await request(app.getHttpServer())
        .get(`/portfolios/${portfolioId}`)
        .set('Authorization', `Bearer ${token2}`)
        .expect(403);
    });
  });

  describe('/portfolios/:id (PUT)', () => {
    let portfolioId: string;

    beforeAll(async () => {
      const portfolios = await prisma.portfolio.findMany({ where: { userId: user1Id } });
      portfolioId = portfolios[0].id;
    });

    it('should update portfolio name successfully for the owner', async () => {
      const response = await request(app.getHttpServer())
        .put(`/portfolios/${portfolioId}`)
        .set('Authorization', `Bearer ${token1}`)
        .send({ name: 'Renewable Energy', description: 'Green energy' })
        .expect(200);

      expect(response.body.name).toBe('Renewable Energy');
    });

    it('should block non-owners from updating portfolio', async () => {
      await request(app.getHttpServer())
        .put(`/portfolios/${portfolioId}`)
        .set('Authorization', `Bearer ${token2}`)
        .send({ name: 'Hacked name' })
        .expect(403);
    });
  });

  describe('/portfolios/:id (DELETE)', () => {
    let portfolio1Id: string;
    let portfolio2Id: string;

    beforeAll(async () => {
      const portfolios1 = await prisma.portfolio.findMany({ where: { userId: user1Id } });
      portfolio1Id = portfolios1[0].id;

      const portfolios2 = await prisma.portfolio.findMany({ where: { userId: user2Id } });
      portfolio2Id = portfolios2[0].id;
    });

    it('should block non-owners from deleting portfolio', async () => {
      await request(app.getHttpServer())
        .delete(`/portfolios/${portfolio1Id}`)
        .set('Authorization', `Bearer ${token2}`)
        .expect(403);
    });

    it('should allow owner to delete portfolio successfully', async () => {
      await request(app.getHttpServer())
        .delete(`/portfolios/${portfolio1Id}`)
        .set('Authorization', `Bearer ${token1}`)
        .expect(200);

      const deleted = await prisma.portfolio.findUnique({ where: { id: portfolio1Id } });
      expect(deleted).toBeNull();
    });
  });
});
