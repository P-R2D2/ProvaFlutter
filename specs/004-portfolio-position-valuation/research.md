# Research: Portfolio Position Valuation Architecture

This document tracks technical research, design patterns, and decisions made for implementing the portfolio valuation logic.

## 1. Persistence & Data Shape

### Decision
Store raw position inputs (`userId`, `symbol`, `quantity`, `averagePurchasePrice`) in a TypeORM relational database table.

### Rationale
- SQLite (`better-sqlite3`) is already integrated and fully sufficient for this project's scale.
- Calculations depend only on these raw inputs and real-time market prices, so storing computed aggregates (`investedAmount`, `profitLoss`) is unnecessary and introduces high risk of out-of-sync data.

### Alternatives Considered
- **Pre-aggregating aggregates in DB**: Rejected. While it reduces CPU calculations on GETs, it introduces heavy write/update synchronization overhead and risks returning stale valuations when market prices change.
- **Client-Side Storage**: Rejected. Violates the strict requirement to hold business rules on the backend and limits cross-device portability.

---

## 2. Arithmetic Precision & Rounding

### Decision
Utilize double-precision numbers internally for dynamic operations in NestJS, and apply exact rounding to 2 decimal places (using `toFixed(2)` or standard scalar math) during serialization in the DTO response mapping layer.

### Rationale
- Preserves full precision during sums and multiplications, preventing minor float deviations from compounding into incorrect cents.
- Direct output matches the spec's requirement for clear dashboard-ready representation (e.g. `16.67%`).

---

## 3. Pricing Reliability & Fallbacks

### Decision
Leverage the existing `AssetsService.getDetails` method, which queries Brapi with a 1-minute NestJS in-memory cache. If the query times out or returns rate limits, the valuation handler catches the exception, uses the cache if available, or falls back to the average purchase price (cost basis) and marks `isDelayed: true` in the output.

### Rationale
- The 1-minute TTL significantly reduces external API load and protects downstream systems from rate limit exhaustion.
- Falling back to cost basis preserves dashboard rendering capability, delivering a robust user experience even during Brapi outages.

---

## 4. Separation of Concerns & Clean API Boundaries

### Decision
Implement strict layer separation:
- **Presentation**: `InvestmentsController` exposes REST endpoints (`POST /api/investments`, `GET /api/investments`, `DELETE /api/investments/:id`).
- **Domain/Business Logic**: `InvestmentsService` implements calculations, position CRUD, and aggregates summaries.
- **Data**: TypeORM entity `Investment` manages database schemas.

The Flutter client remains a pure presentation layer: it handles API request dispatching, JWT authorization headers, and UI state rendering, with zero local calculation logic.
