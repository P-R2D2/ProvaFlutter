# Implementation Plan: Asset Market Integration

**Branch**: `003-asset-market-integration` | **Date**: 2026-05-30 | **Spec**: [spec.md](./spec.md)
**Input**: Feature specification from `/specs/003-asset-market-integration/spec.md`

---

## Summary

Integrate the application with the **Brapi API** to retrieve live stock market asset listings, search outcomes, and details, ensuring all communication occurs securely through the NestJS backend. The frontend will consume these normalized, cached records to display interactive list cards, details, and shimmer animations, laying the design foundation for future portfolio valuations.

---

## Technical Context

- **Language/Version**: NestJS v11 (TypeScript ^5.7.3), Flutter v3.11 (Dart ^3.11.0)
- **Primary Dependencies**:
  - *Backend*: `@nestjs/axios` (^4.0.0), `axios`, `@nestjs/cache-manager`, `cache-manager` (^5.0.0), `class-validator` (^0.15.1), `class-transformer`
  - *Frontend*: `provider` (^6.1.5), `shimmer` (^3.0.0), `http` (^1.2.2)
- **Storage**: In-memory caching for query throttling (transient); future SQLite schema readiness.
- **Testing**: Jest (NestJS unit & integration tests), `flutter_test` (Flutter provider and parser unit tests)
- **Target Platform**: Linux Server (NestJS Container), Android & iOS mobile devices (Flutter client)
- **Project Type**: Mobile Client + API Proxy Gateway
- **Performance Goals**: API latency p95 < 200ms on cache hit; Flutter list scrolling and shimmer animations at solid 60 fps.
- **Constraints**: Zero direct mobile client-to-Brapi external calls. All third-party exceptions intercepted, categorized, and served as unified JSON. A local Mock Fallback mode is implemented inside the backend gateway service to return realistic mock asset quotes if the API token environment variable is missing or on remote API outage.
- **Scale/Scope**: Up to 10k active users; caching details for 1 minute to avoid API rate bounds.

---

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

- [x] I. Clean Architecture: Does the design strictly separate Domain, Data, and Presentation/Controllers?
- [x] II. Feature-First/Modular: Is the logic organized under `features/` or backend `modules/`?
- [x] III. Responsive UI: Are Material design and responsiveness prioritized (Frontend)?
- [x] IV. Provider: Is state management handled via Provider (Frontend)?
- [x] V. Repository Pattern: Are data sources abstracted behind Repositories?
- [x] VI. Code Quality: Are names meaningful and logic DRY?
- [x] VII. Backend Security: Is JWT used for authentication and class-validator for DTOs?
- [x] VIII. Backend Modular Structure: Are Auth and Users modules isolated in NestJS?

---

## Project Structure

### Documentation (this feature)

```text
specs/003-asset-market-integration/
├── spec.md              # Feature specification
├── plan.md              # This file (Implementation Plan)
├── research.md          # Technical research & decisions (Phase 0)
├── data-model.md        # Data models & schemas (Phase 1)
├── quickstart.md        # Setup & verification quickstart (Phase 1)
└── contracts/
    └── assets.md        # REST API endpoints interface contract (Phase 1)
```

### Source Code

#### Backend Module (NestJS)
Organized under the new `assets` modular group:
```text
backend/src/modules/assets/
├── assets.module.ts
├── assets.controller.ts
├── assets.service.ts
├── dto/
│   ├── search-query.dto.ts
│   ├── market-asset.dto.ts
│   └── asset-details.dto.ts
└── interfaces/
    └── assets-service.interface.ts
```

#### Frontend Feature Module (Flutter)
Adheres to the repository's feature-first clean architecture boundary:
```text
investment_agenda/lib/features/assets/
├── data/
│   ├── models/
│   │   ├── market_asset_model.dart
│   │   └── asset_details_model.dart
│   └── datasources/
│       └── assets_remote_data_source.dart
├── domain/
│   ├── entities/
│   │   ├── market_asset.dart
│   │   └── asset_details.dart
│   ├── repositories/
│   │   └── assets_repository.dart
│   └── usecases/
│       ├── search_assets_usecase.dart
│       └── get_asset_details_usecase.dart
└── presentation/
    ├── providers/
    │   └── assets_provider.dart
    └── pages/
        ├── asset_search_page.dart
        └── asset_details_page.dart
```

**Structure Decision**: Web application & Mobile structure split, maintaining clean isolation between the `backend/` NestJS modular architecture and `investment_agenda/` Flutter feature directories.

---

## Complexity Tracking

*No constitution violations present. All architecture aligns 100% with the Investment Agenda principles.*
