import { Test, TestingModule } from '@nestjs/testing';
import { INestApplication, ValidationPipe } from '@nestjs/common';
import request from 'supertest';
import { App } from 'supertest/types';
import { AppModule } from './../src/app.module';
import { PrismaService } from './../src/prisma.service';

describe('AuthController (e2e)', () => {
  let app: INestApplication<App>;
  let prisma: PrismaService;

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
  });

  beforeEach(async () => {
    // Clear database state
    await prisma.investment.deleteMany({});
    await prisma.portfolio.deleteMany({});
    await prisma.user.deleteMany({});
  });

  afterAll(async () => {
    await prisma.$disconnect();
    await app.close();
  });

  describe('/auth/register (POST)', () => {
    it('should successfully register a new user', async () => {
      const response = await request(app.getHttpServer())
        .post('/auth/register')
        .send({ email: 'test@example.com', password: 'Password123!' })
        .expect(201);

      expect(response.body).toHaveProperty('id');
      expect(response.body.email).toBe('test@example.com');
      expect(response.body).not.toHaveProperty('passwordHash');
    });

    it('should reject duplicate email registration', async () => {
      await request(app.getHttpServer())
        .post('/auth/register')
        .send({ email: 'test@example.com', password: 'Password123!' })
        .expect(201);

      await request(app.getHttpServer())
        .post('/auth/register')
        .send({ email: 'test@example.com', password: 'Password123!' })
        .expect(409);
    });

    it('should reject malformed email', async () => {
      await request(app.getHttpServer())
        .post('/auth/register')
        .send({ email: 'not-an-email', password: 'Password123!' })
        .expect(400);
    });
  });

  describe('/auth/login (POST)', () => {
    beforeEach(async () => {
      // Seed user
      await request(app.getHttpServer())
        .post('/auth/register')
        .send({ email: 'login@example.com', password: 'Password123!' });
    });

    it('should login successfully and return access token', async () => {
      const response = await request(app.getHttpServer())
        .post('/auth/login')
        .send({ email: 'login@example.com', password: 'Password123!' })
        .expect(200);

      expect(response.body).toHaveProperty('accessToken');
      expect(typeof response.body.accessToken).toBe('string');
      expect(response.body).toHaveProperty('refreshToken');
      expect(typeof response.body.refreshToken).toBe('string');
    });

    it('should reject incorrect password', async () => {
      await request(app.getHttpServer())
        .post('/auth/login')
        .send({ email: 'login@example.com', password: 'WrongPassword' })
        .expect(401);
    });

    it('should reject login for non-existent user', async () => {
      await request(app.getHttpServer())
        .post('/auth/login')
        .send({ email: 'none@example.com', password: 'Password123!' })
        .expect(401);
    });
  });

  describe('/auth/refresh (POST)', () => {
    let refreshToken: string;

    beforeEach(async () => {
      // Seed user
      await request(app.getHttpServer())
        .post('/auth/register')
        .send({ email: 'refresh@example.com', password: 'Password123!' });

      const loginRes = await request(app.getHttpServer())
        .post('/auth/login')
        .send({ email: 'refresh@example.com', password: 'Password123!' });
      refreshToken = loginRes.body.refreshToken;
    });

    it('should successfully rotate tokens with valid refresh token', async () => {
      const response = await request(app.getHttpServer())
        .post('/auth/refresh')
        .send({ refreshToken })
        .expect(200);

      expect(response.body).toHaveProperty('accessToken');
      expect(response.body).toHaveProperty('refreshToken');
      expect(response.body.refreshToken).not.toBe(refreshToken);
    });

    it('should reject invalid or missing refresh token', async () => {
      await request(app.getHttpServer())
        .post('/auth/refresh')
        .send({ refreshToken: 'invalid-token' })
        .expect(401);
    });

    it('should terminate session on token reuse (RTR Breach)', async () => {
      // Rotate once
      const response1 = await request(app.getHttpServer())
        .post('/auth/refresh')
        .send({ refreshToken })
        .expect(200);

      // Re-use first refresh token
      await request(app.getHttpServer())
        .post('/auth/refresh')
        .send({ refreshToken })
        .expect(401);

      // Even the rotated new token should now be invalidated
      await request(app.getHttpServer())
        .post('/auth/refresh')
        .send({ refreshToken: response1.body.refreshToken })
        .expect(401);
    });
  });

  describe('/auth/logout (POST)', () => {
    let accessToken: string;
    let refreshToken: string;

    beforeEach(async () => {
      await request(app.getHttpServer())
        .post('/auth/register')
        .send({ email: 'logout@example.com', password: 'Password123!' });

      const loginRes = await request(app.getHttpServer())
        .post('/auth/login')
        .send({ email: 'logout@example.com', password: 'Password123!' });
      accessToken = loginRes.body.accessToken;
      refreshToken = loginRes.body.refreshToken;
    });

    it('should successfully log out and invalidate refresh token', async () => {
      await request(app.getHttpServer())
        .post('/auth/logout')
        .set('Authorization', `Bearer ${accessToken}`)
        .expect(200);

      // Refresh token should now be invalid
      await request(app.getHttpServer())
        .post('/auth/refresh')
        .send({ refreshToken })
        .expect(401);
    });
  });
});
