<!--
Sync Impact Report:
- Version change: 1.0.0 -> 1.1.0
- List of modified principles:
    - [I. Clean Architecture] -> Updated to encompass backend concepts (Controllers).
    - [II. SOLID & Feature-First Structure] -> Updated to include backend modular structure.
- Added sections:
    - VI. NestJS Clean Architecture & SOLID
    - VII. Backend Modules & Security
    - VIII. Backend Data Abstraction
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

### V. Data Abstraction (Repository Pattern)
- **Repository Pattern**: All database or API interactions MUST be abstracted behind Repository interfaces defined in the Domain layer.
- **Future-Proofing**: The system MUST be prepared for swapping local storage (SQLite) with cloud storage (Firebase/Supabase) without affecting the Domain or Presentation layers.

## Backend Architecture (NestJS)

### VI. NestJS Clean Architecture & SOLID
- **NestJS Framework**: The backend MUST be built using NestJS, adhering to a Modular structure.
- **Clean Architecture & SOLID**: Backend logic MUST follow Clean Architecture principles, ensuring that business logic is isolated from transport (HTTP) and persistence mechanisms. Controllers, Services, and Repositories must have single responsibilities and rely on abstractions.

### VII. Backend Modules & Security
- **Core Modules**: The backend MUST implement distinct, isolated modules. Initial required modules are:
  - **Auth**: For authentication and authorization.
  - **Users**: For user management.
- **Authentication**: MUST use JWT (JSON Web Tokens) for stateless authentication.
  - Integration with **Passport JWT** is required.
  - Passwords MUST be hashed using **bcrypt**.
- **DTO Validation**: All incoming requests MUST be validated using **class-validator** through Data Transfer Objects (DTOs).

### VIII. Backend Data Abstraction
- **Repository Pattern**: Data persistence MUST be abstracted using the Repository Pattern.
- **Database Agnosticism**: Persistence MUST remain abstracted for future database integration. Services MUST depend on Repository interfaces, not directly on ORMs or database clients.

## Code Quality & Scalability

### IX. Meaningful Naming & DRY
- **Meaningful Naming**: Use descriptive, intention-revealing names for all variables, classes, and functions.
- **DRY (Don't Repeat Yourself)**: Abstract common logic into reusable modules or utilities.

## Development Workflow

### X. Layer-First Implementation & Testing
- **Layer-First Implementation**: When building a feature, start with the Domain (Entities/Interfaces) -> Data (Implementation) -> Presentation/Controllers.
- **Unit Testing**: Business logic in the Domain/Service layer should be unit testable with a high coverage goal.

## Governance

- **Amendment**: Any changes to these principles require a minor version bump and an update to the `plan-template.md` gates.
- **Compliance**: Every implementation plan MUST include a "Constitution Check" ensuring adherence to the layers and patterns defined here.

**Version**: 1.1.0 | **Ratified**: 2026-04-21 | **Last Amended**: 2026-05-15
