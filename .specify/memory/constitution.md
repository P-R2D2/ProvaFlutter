<!--
Sync Impact Report:
- Version change: 1.1.0 -> 1.2.0
- List of modified principles:
    - [V. Data Abstraction (Repository Pattern)] -> [V. Data Abstraction & Repository Pattern] (Generalized to cover database abstraction policies)
    - [VII. Backend Modules & Security] -> [VII. Backend Modules & Security] (Updated required modules list to include Portfolios and Investments)
    - [VIII. Backend Data Abstraction] -> [VIII. Backend Data Abstraction & Persistence] (Updated to mandate PostgreSQL and Prisma ORM, and separation of business logic)
- Added sections:
    - IX. Core Entities & Relationships
    - X. Future Financial Integrations
- Removed sections: None
- Templates requiring updates: 
    - .specify/templates/plan-template.md (✅ updated)
- Follow-up TODOs: None
-->

# Investment Agenda Constitution

## Core Principles

### I. Clean Architecture (Presentation, Domain, Data)
The application MUST be structured into distinct layers to ensure separation of concerns:
- **Domain**: Strictly business logic (Entities, Use Cases, Repository interfaces). NO external dependencies.
- **Data**: Implementation of Repositories, Data Sources (local/remote APIs), and Data Models (JSON mapping). 
- **Presentation**: UI Widgets and State Management (Providers) for frontend, or Controllers/Resolvers for backend.
Dependencies MUST point inwards: Presentation -> Domain <- Data.

### II. SOLID & Feature-First Structure
- **SOLID**: All code MUST adhere to SOLID principles to ensure maintainability and testability.
- **Feature-First / Modular Structure**: Files MUST be organized by feature or module (e.g., `lib/features/investments/` for frontend, `src/modules/auth/` for backend) rather than by technical type.

### III. Responsive Material UI/UX (Frontend)
- **Material Design**: Follow Material Design standards for all UI elements.
- **Visual Excellence**: UI must be "premium," simple, and readable. Use Cards for data presentation.
- **User Feedback**: Provide immediate feedback for user actions using Snackbars and Dialogs.
- **Responsiveness**: Layouts MUST be tested and optimized for different screen sizes.

### IV. Provider State Management (Frontend)
- **Provider**: Use the `provider` package for state management.
- **Simplicity**: Logic MUST reside in `ChangeNotifier` classes (or similar) within the presentation layer, separate from the widget tree.
- **Scalability**: Keep providers granular to avoid unnecessary rebuilds.

### V. Data Abstraction & Repository Pattern
- **Repository Pattern**: All database or API interactions MUST be abstracted behind Repository interfaces defined in the Domain layer.
- **Future-Proofing**: The system MUST be prepared for swapping database systems or external services without affecting the Domain or Presentation layers.

## Backend Architecture (NestJS)

### VI. NestJS Clean Architecture & SOLID
- **NestJS Framework**: The backend MUST be built using NestJS, adhering to a Modular structure.
- **Clean Architecture & SOLID**: Backend logic MUST follow Clean Architecture principles, ensuring that business logic is isolated from transport (HTTP) and persistence mechanisms. Controllers, Services, and Repositories must have single responsibilities and rely on abstractions.

### VII. Backend Modules & Security
- **Core Modules**: The backend MUST implement distinct, isolated modules. Required modules are:
  - **Auth**: For authentication and authorization.
  - **Users**: For user management.
  - **Portfolios**: For portfolio management.
  - **Investments**: For investment management.
- **Authentication**: MUST use JWT (JSON Web Tokens) for stateless authentication.
  - Integration with **Passport JWT** is required.
  - Passwords MUST be hashed using **bcrypt**.
- **DTO Validation**: All incoming requests MUST be validated using **class-validator** through Data Transfer Objects (DTOs).

### VIII. Backend Data Abstraction & Persistence
- **Database Engine**: Relational database persistence MUST use **PostgreSQL**.
- **ORM Framework**: Database schema, migrations, and access operations MUST be implemented using **Prisma ORM**.
- **Separation of Logic**: Business logic MUST be separated from persistence. Services MUST depend on Repository interfaces defined in the Domain layer, not directly on the Prisma client or PostgreSQL queries. Prisma models and generated code MUST remain inside the Data layer.

### IX. Core Entities & Relationships
The backend database schema and domain models MUST define the following entities and relationships:
- **User**: Represents application users who own portfolios.
- **Portfolio**: Represents a collection of holdings/investments. A User can have multiple portfolios (User 1 -> N Portfolio).
- **Investment**: Represents a specific asset holding. A Portfolio can have multiple investments (Portfolio 1 -> N Investment).
- Relationships MUST be mapped and enforced in the database schema via Prisma.

### X. Future Financial Integrations
- **Integration Readiness**: The backend architecture MUST prepare for future financial integrations (e.g., brokerage APIs, real-time market data providers, banking APIs).
- **Decoupling Gateways**: All financial integration adapters, API clients, and data parsers MUST implement interfaces defined in the Domain layer to allow swapping providers without modifying core business logic.

## Code Quality & Scalability

### XI. Meaningful Naming & DRY
- **Meaningful Naming**: Use descriptive, intention-revealing names for all variables, classes, and functions.
- **DRY (Don't Repeat Yourself)**: Abstract common logic into reusable modules or utilities.

### XII. Layer-First Implementation & Testing
- **Layer-First Implementation**: When building a feature, start with the Domain (Entities/Interfaces) -> Data (Implementation) -> Presentation/Controllers.
- **Unit Testing**: Business logic in the Domain/Service layer should be unit testable with a high coverage goal.

## Governance

- **Amendment**: Any changes to these principles require a minor version bump and an update to the `plan-template.md` gates.
- **Compliance**: Every implementation plan MUST include a "Constitution Check" ensuring adherence to the layers and patterns defined here.

**Version**: 1.2.0 | **Ratified**: 2026-04-21 | **Last Amended**: 2026-06-10
