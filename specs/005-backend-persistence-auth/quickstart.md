# Persistent Backend Quickstart Guide

This document describes how to configure, run, and validate the backend persistence layer locally.

## 1. Database Infrastructure Setup

We run PostgreSQL locally. You can use a local PostgreSQL service or run it via Docker:

### Running PostgreSQL with Docker
Run the following command in your terminal:
```bash
docker run --name pg-investments -e POSTGRES_PASSWORD=postgres -e POSTGRES_USER=postgres -e POSTGRES_DB=investments -p 5432:5432 -d postgres:15-alpine
```

---

## 2. Environment Configuration

1. Open `backend/.env` (create it if missing, copy from `.env.example`).
2. Add/update the following environment variables:
```env
DATABASE_URL="postgresql://postgres:postgres@localhost:5432/investments?schema=public"
JWT_SECRET="super-secret-developer-key-change-in-production"
```

---

## 3. Prisma Installation & Migrations

Navigate to the `backend/` directory and install the necessary dependencies, generate the client, and run database migrations.

```bash
cd backend

# Install Prisma CLI and Client
npm install prisma --save-dev
npm install @prisma/client

# Create and apply initial migration to PostgreSQL
npx prisma migrate dev --name init

# Generate Prisma Client
npx prisma generate
```

To view and manage database tables visually, you can start Prisma Studio:
```bash
npx prisma studio
```

---

## 4. Run Development Server

Start the NestJS dev server:
```bash
npm run start:dev
```

---

## 5. Basic API Verification

### A. Register User
```bash
curl -X POST http://localhost:3000/auth/register \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"Password123!"}'
```

### B. Login and Retrieve JWT
```bash
curl -X POST http://localhost:3000/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"Password123!"}'
```
*Copy the returned `accessToken`.*

### C. Create Portfolio
```bash
curl -X POST http://localhost:3000/portfolios \
  -H "Authorization: Bearer <your_access_token>" \
  -H "Content-Type: application/json" \
  -d '{"name":"Tech Stocks","description":"US tech equities portfolio"}'
```
