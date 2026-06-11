# Implementation Plan: Persistent Backend Storage & Authentication

**Branch**: `005-backend-persistence-auth` | **Date**: 2026-06-10 | **Spec**: [spec.md](spec.md)
**Input**: Feature specification from `/specs/005-backend-persistence-auth/spec.md`

## Summary

This plan outlines the architecture and execution steps to extend the backend with PostgreSQL persistence and secure JWT authentication. We will replace the transient SQLite/TypeORM structures with a highly decoupled, production-ready NestJS design utilizing Prisma ORM.

Key accomplishments will include:
1. Bootstrapping PostgreSQL and Prisma ORM.
2. Building modular NestJS modules for `auth`, `users`, `portfolios`, and `investments`.
3. Enforcing route protection via a global JWT guard and resource-level Guards for ownership validation.
4. Isolating business logic from persistence structures via Repository interfaces to support future financial integrations (like Brapi) and portfolio valuation.

## Technical Context

**Language/Version**: TypeScript Node.js v18+  
**Primary Dependencies**: @nestjs/common, @nestjs/jwt, @nestjs/passport, passport, passport-jwt, @prisma/client, prisma, bcrypt, class-validator, class-transformer  
**Storage**: PostgreSQL relational database via Prisma ORM  
**Testing**: Jest (unit and e2e integration tests)  
**Target Platform**: Linux Server  
**Project Type**: Backend REST Web Service  
**Performance Goals**: JWT validation and token generation < 100ms; database operations < 100ms  
**Constraints**: Global JWT auth enforced by default (public routes bypass using `@Public()`); strict ownership validation via NestJS Guard before accessing database resource handlers  
**Scale/Scope**: Multi-user relational persistence  

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

- [x] I. Clean Architecture: Does the design strictly separate Domain, Data, and Presentation/Controllers?
- [x] II. Feature-First/Modular: Is the logic organized under `features/` or backend `modules/`?
- [x] III. Responsive UI: N/A (Backend only)
- [x] IV. Provider: N/A (Backend only)
- [x] V. Data Abstraction & Repository Pattern: Are database and API interactions abstracted behind Repository interfaces?
- [x] VI. Code Quality: Are names meaningful and logic DRY?
- [x] VII. Backend Security: Is JWT used for authentication, bcrypt for password hashing, and class-validator for DTOs?
- [x] VIII. Backend Modular Structure: Are modules (Auth, Users, Portfolios, Investments) modular and isolated in NestJS?
- [x] IX. Backend Persistence & ORM: Does the backend use PostgreSQL with Prisma ORM, keeping business logic strictly separated?
- [x] X. Future Financial Integrations: Are external integrations decoupled via adapters/gateways defined in the Domain layer?

## Project Structure

### Documentation

```text
specs/005-backend-persistence-auth/
├── plan.md              # This file
├── research.md          # Technical research & decisions (Phase 0)
├── data-model.md        # Relational models & Prisma Schema (Phase 1)
├── quickstart.md        # Migration and local start guides (Phase 1)
├── checklists/
│   └── requirements.md  # Spec checklist
└── contracts/
    ├── auth.md          # Authentication API endpoints contract
    ├── portfolio.md     # Portfolio CRUD API contract
    └── investment.md    # Investment CRUD API contract
```

### Source Code

```text
backend/
├── prisma/
│   └── schema.prisma           # Prisma DB schema definitions
├── src/
│   ├── app.module.ts           # Root module loading Auth, Users, Portfolios, Investments
│   ├── main.ts                 # Entrypoint registering global pipes and guards
│   ├── common/
│   │   ├── decorators/
│   │   │   └── public.decorator.ts      # @Public() decorator
│   │   └── guards/
│   │       ├── jwt-auth.guard.ts        # Global JWT enforcement Guard
│   │       └── ownership.guard.ts       # Resource ownership checking Guard
│   └── modules/
│       ├── auth/
│       │   ├── auth.controller.ts
│       │   ├── auth.service.ts
│       │   ├── auth.module.ts
│       │   └── strategies/
│       │       └── jwt.strategy.ts
│       ├── users/
│       │   ├── domain/
│       │   │   ├── user.entity.ts       # Domain model (decoupled from Prisma)
│       │   │   └── user.repository.ts   # Repository interface
│       │   ├── data/
│       │   │   └── prisma-user.repository.ts # Prisma implementation
│       │   ├── users.service.ts
│       │   └── users.module.ts
│       ├── portfolios/
│       │   ├── domain/
│       │   │   ├── portfolio.entity.ts
│       │   │   └── portfolio.repository.ts
│       │   ├── data/
│       │   │   └── prisma-portfolio.repository.ts
│       │   ├── dtos/
│       │   │   ├── create-portfolio.dto.ts
│       │   │   └── update-portfolio.dto.ts
│       │   ├── portfolios.controller.ts
│       │   ├── portfolios.service.ts
│       │   └── portfolios.module.ts
│       └── investments/
│           ├── domain/
│           │   ├── investment.entity.ts
│           │   └── investment.repository.ts
│           ├── data/
│           │   └── prisma-investment.repository.ts
│           ├── dtos/
│           │   ├── create-investment.dto.ts
│           │   └── update-investment.dto.ts
│           ├── investments.controller.ts
│           ├── investments.service.ts
│           └── investments.module.ts
└── test/
```

**Structure Decision**: A modular, domain-driven structure has been chosen. Clean Architecture is enforced by defining Entities and Repository interfaces under `domain/` directories and locating their Prisma implementation under `data/` directories, preventing persistence leakage into core services.

## Complexity Tracking

*All constitution checks are fully passed. No complexity-tracking entries required.*
