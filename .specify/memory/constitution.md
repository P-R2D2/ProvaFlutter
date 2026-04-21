<!--
Sync Impact Report:
- Version change: [PROJECT_NAME] Constitution -> 1.0.0
- List of modified principles:
    - [PRINCIPLE_1_NAME] -> I. Clean Architecture (Presentation, Domain, Data)
    - [PRINCIPLE_2_NAME] -> II. SOLID & Feature-First Structure
    - [PRINCIPLE_3_NAME] -> III. Responsive Material UI/UX
    - [PRINCIPLE_4_NAME] -> IV. Provider State Management
    - [PRINCIPLE_5_NAME] -> V. Data Abstraction (Repository Pattern)
- Added sections: VI. Code Quality & Scalability, VII. Development Workflow
- Templates requiring updates:
    - .specify/templates/plan-template.md (Reflects Repository pattern gates)
    - .specify/templates/tasks-template.md (Reflects layer-based ordering)
- Follow-up TODOs: None
-->

# Investment Agenda Constitution

## Core Principles

### I. Clean Architecture (Presentation, Domain, Data)
The application MUST be structured into three distinct layers to ensure separation of concerns:
- **Domain**: Strictly business logic (Entities, Use Cases, Repository interfaces). NO external dependencies (no Flutter, no external plugins).
- **Data**: Implementation of Repositories, Data Sources (local/remote APIs), and Data Models (JSON mapping). 
- **Presentation**: UI Widgets and State Management (Providers).
Dependencies MUST point inwards: Presentation -> Domain <- Data.

### II. SOLID & Feature-First Structure
- **SOLID**: All code MUST adhere to SOLID principles to ensure maintainability and testability.
- **Feature-First**: Files MUST be organized by feature (e.g., `lib/features/investments/`) rather than by technical type (e.g., `lib/models/`). Each feature folder should contain its own `presentation`, `domain`, and `data` subdirectories.

### III. Responsive Material UI/UX
- **Material Design**: Follow Material Design standards for all UI elements.
- **Visual Excellence**: UI must be "premium," simple, and readable. Use Cards for data presentation.
- **User Feedback**: Provide immediate feedback for user actions using Snackbars and Dialogs.
- **Responsiveness**: Layouts MUST be tested and optimized for different screen sizes.

### IV. Provider State Management
- **Provider**: Use the `provider` package for state management.
- **Simplicity**: Logic MUST reside in `ChangeNotifier` classes (or similar) within the presentation layer, separate from the widget tree.
- **Scalability**: Keep providers granular to avoid unnecessary rebuilds.

### V. Data Abstraction (Repository Pattern)
- **Repository Pattern**: All database or API interactions MUST be abstracted behind Repository interfaces defined in the Domain layer.
- **Future-Proofing**: The system MUST be prepared for swapping local storage (SQLite) with cloud storage (Firebase/Supabase) without affecting the Domain or Presentation layers.

## VI. Code Quality & Scalability

- **Meaningful Naming**: Use descriptive, intention-revealing names for all variables, classes, and functions.
- **DRY (Don't Repeat Yourself)**: Abstract common logic and UI components into reusable widgets and utilities.
- **Small Widgets**: Keep widgets small and composable. Avoid large, deeply nested build methods.

## VII. Development Workflow

- **Layer-First Implementation**: When building a feature, start with the Domain (Entities/Interfaces) -> Data (Implementation) -> Presentation (UI).
- **Unit Testing**: Business logic in the Domain layer should be unit testable with 100% logic coverage goal.

## Governance

- **Amendment**: Any changes to these principles require a minor version bump and an update to the `plan-template.md` gates.
- **Compliance**: Every implementation plan MUST include a "Constitution Check" ensuring adherence to the layers and patterns defined here.

**Version**: 1.0.0 | **Ratified**: 2026-04-21 | **Last Amended**: 2026-04-21
