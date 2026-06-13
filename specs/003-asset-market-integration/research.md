# Research & Decisions: Asset Market Integration

**Feature**: Asset Market Integration  
**Date**: 2026-05-30  
**Status**: Approved

This document captures the research, architecture, and technology decisions for integrating the Brapi API securely through the NestJS backend and presenting it via the Flutter frontend.

---

## 1. External Market API Integration (Brapi)

### Decision
Use **Brapi** (brapi.dev) as the external financial data provider. All communication is proxied through the NestJS backend.

### Technical Detail
- **Search Endpoint**: `/api/quote/list?search={query}`
  - Used to find assets matching the symbol or company name.
  - Returns a list of symbols and company names.
- **Details Endpoint**: `/api/quote/{ticker}`
  - Used to fetch comprehensive real-time data for a selected ticker (e.g., `PETR4`).
  - Returns price, high, low, change percentage, currency, and update timestamps.
- **Authentication**: Authenticated using a query parameter (`?token=YOUR_TOKEN`). The token is loaded on the backend from environment variables (`BRAPI_API_TOKEN`).

### Alternatives Considered
- *Yahoo Finance API / RapidAPI*: Rejected due to strict rate limits on free tiers and lack of robust support for Brazilian B3 market assets.
- *Direct Flutter calling Brapi*: Rejected due to security requirements (protecting the API key) and architectural boundaries (backend must act as proxy and normalization layer).

---

## 2. Backend HTTP Client (NestJS)

### Decision
Install and use `@nestjs/axios` (which wraps `axios`) for NestJS-to-Brapi communication.

### Rationale
- Standard, officially supported NestJS HTTP module.
- Adheres to NestJS injection patterns and RxJS observables.
- Highly configurable timeout and retry handlers.

### Installation
```bash
npm install @nestjs/axios axios
```

---

## 3. Caching Strategy (NestJS Backend)

### Decision
Use `@nestjs/cache-manager` and `cache-manager` for self-contained, in-memory caching at the NestJS service layer.

### Rationale
- In-memory cache is robust, simple, and requires no external infrastructure dependencies (like Redis) for the current MVP.
- **Search Cache**: 5 minutes (companies don't change names or symbols frequently).
- **Details Cache**: 1 minute (keeps prices relatively fresh while fully protecting from concurrent typing rate-limits).

### Installation
```bash
npm install @nestjs/cache-manager cache-manager
```

---

## 4. Error Handling Framework

### Decision
Implement a NestJS `HttpExceptionFilter` and a custom Exception wrapper to trap Brapi integration errors and map them to clean client contracts.

### Rationale
- Decouples client applications from third-party server errors.
- Raw HTTP 404, 429 (Rate Limit), or 503 (Outage) errors from Brapi are caught and mapped into a standardized JSON response:
  ```json
  {
    "statusCode": number,
    "message": "User friendly message",
    "error": "Error description",
    "retryable": boolean
  }
  ```
- Ensures the client application receives standard status codes with clear directions on whether to display a "Retry" button.

---

## 5. Frontend Shimmer loading animations (Flutter)

### Decision
Install and use the `shimmer` package in Flutter to construct premium skeletal loading indicators instead of standard progress spinners.

### Rationale
- Enhances UX by matching the expected layout shape before it completes loading (visual excellence).
- Smoothly scales from search listing layouts to detailed cards.

### Installation
```yaml
dependencies:
  shimmer: ^3.0.0
```

---

## 6. Portfolio Valuation Future Readiness

### Decision
Ensure that the normalized `AssetDetails` model uses uniform `double` (Decimal) formats, distinct ticker strings, standard ISO currencies (`BRL`), and ISO 8601 update timestamps.

### Rationale
- Preparing the data payload in clean types enables the database schema for portfolios to easily link transactions to symbols (`symbol` as foreign key).
- Standardized currency fields (`BRL`) support future conversion engines for international portfolios.
