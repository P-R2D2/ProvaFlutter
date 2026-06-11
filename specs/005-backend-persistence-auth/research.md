# Technical Research & Decisions

This document details the architectural decisions and best practices evaluated for the NestJS, PostgreSQL, Prisma ORM, and JWT authentication backend integration.

## 1. Database & Persistence Setup

### Decision: PostgreSQL + Prisma ORM
We select PostgreSQL as the primary relational database and Prisma ORM for schema definition, type safety, and migration management.

### Rationale
- **Relational Integrity**: Essential for enforcing cascade constraints between `User` -> `Portfolio` -> `Investment`.
- **Type Safety**: Prisma generates TypeScript clients matching database models automatically, eliminating type discrepancies between runtime and database.
- **Migration Pipeline**: Prisma Migrations provide a version-controlled, predictable way to update schema across local development and production.

### Connection Lifecycle Management
Prisma connection is managed inside a custom `PrismaService` which implements NestJS `OnModuleInit` and handles clean shutdown logic (`enableShutdownHooks` is no longer needed in Prisma 5+, but standard hook shutdown works well).
```typescript
@Injectable()
export class PrismaService extends PrismaClient implements OnModuleInit {
  async onModuleInit() {
    await this.$connect();
  }
}
```

---

## 2. Authentication Flow & Security

### Password Hashing (bcrypt)
Passwords will be hashed using `bcrypt` with a work factor (salt rounds) of `10`. This strikes an optimal balance between security resistance to brute-force attacks and authentication latency (under 80ms).

### JWT Authentication Strategy
- **Session Tokens**: Handled via `@nestjs/jwt`.
- **Secret Management**: Stored in environment variables (`JWT_SECRET`) with an expiration of `24h` by default.
- **Passport Integration**: Use `passport-jwt` strategy to validate incoming `Authorization: Bearer <token>` headers and automatically populate `request.user` with user metadata.

### Global Route Protection Gate
To prevent developers from forgetting to protect new endpoints, we register a global `JwtAuthGuard`. 
- **Opt-out mechanism**: Routes that must be public (like `/auth/register` and `/auth/login`) are annotated with a custom `@Public()` decorator.
- **Implementation**: The global guard checks the metadata key `isPublic` on the handler/class and bypasses authentication if present.

---

## 3. Modular Architecture & Cross-Module Boundaries

We enforce modularity within NestJS to keep modules self-contained:
1. **AuthModule**: Handles login, signup, token signing. Depends on `UsersModule`.
2. **UsersModule**: Handles user queries and creation. Exports `UsersService`.
3. **PortfoliosModule**: Handles portfolio CRUD. Imports `UsersModule` for authentication context.
4. **InvestmentsModule**: Handles investment transactions. Imports `PortfoliosModule` to validate parent relationships.

---

## 4. DTO Validation & Ownership Validation Guards

### Request Validation (DTOs)
All controller endpoints use class-validator decorator constraints (e.g. `@IsEmail()`, `@IsString()`, `@IsNotEmpty()`, `@Min()`, `@IsDecimal()`) on incoming payloads. Global ValidationPipe is registered in `main.ts` with `whitelist: true` to strip unmapped parameters automatically.

### Resource Ownership Guard
- **Problem**: Users must not be able to read or modify portfolios/investments belonging to other users.
- **Solution**: A custom NestJS `OwnershipGuard` is created.
  - The guard reads the request params (e.g. `portfolioId` or `investmentId`).
  - It uses the corresponding repository to load the resource.
  - It compares the resource's owner ID with `request.user.id`.
  - If they match, access is granted; otherwise, a `ForbiddenException` is thrown.
- **Application**: Applied selectively at the controller level: `@UseGuards(OwnershipGuard)`.

---

## 5. Future Readiness for Portfolio Valuation

To ensure the backend is prepared for future stock market integrations (like Brapi API proxies) and dynamic portfolio valuation:
- **Clean Architecture Domain Entities**: The domain entities `Portfolio` and `Investment` are completely decoupled from Prisma ORM generated types.
- **Repository Interface Isolation**: Services only interact with Repository interfaces. When we implement valuation, the calculation service can fetch investment entities from repositories, fetch stock values from the Brapi Adapter, and run valuation logic cleanly in the Domain layer without database dependencies.
