# Implementation Plan: Investment Agenda

**Branch**: `001-investment-agenda` | **Date**: 2026-04-21 | **Spec**: [spec.md](spec.md)
**Input**: Feature specification from `specs/001-investment-agenda/spec.md`

## Summary

The objective is to build a Flutter application for tracking investments. The app will include authentication (hardcoded), a CRUD interface for investments (Name, Amount, Monthly Return), a dashboard with total sum calculation, and clear visual feedback using Material Design. The architecture will follow Clean Architecture (Domain, Data, Presentation) using the Provider package for state management and GoRouter for named route navigation.

## Technical Context

**Language/Version**: Dart 3.x / Flutter 3.x  
**Primary Dependencies**: `provider`, `uuid`, `intl`, `go_router`  
**Storage**: In-memory list abstracted via a Repository interface  
**Testing**: Unit tests for Domain entities and Use Cases; Widget tests for critical UI components  
**Target Platform**: Mobile (Android/iOS), Portrait mode  
**Project Type**: Mobile Application  
**Performance Goals**: UI updates < 100ms; Total sum calculation < 10ms  
**Constraints**: Hardcoded credentials, no initial cloud persistence  
**Scale/Scope**: < 100 investments per user session (initial POC)

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

- [x] I. Clean Architecture: Logic is strictly separated into Domain, Data, and Presentation.
- [x] II. Feature-First: All application logic is organized under the `lib/features/` directory.
- [x] III. Responsive UI: Material Design, Cards, and Snackbars are prioritized.
- [x] IV. Provider: State management is handled via the Provider package.
- [x] V. Repository Pattern: Data sources are abstracted behind Domain repository interfaces.
- [x] VI. Code Quality: Composable widgets and meaningful naming conventions are used.

## Project Structure

### Documentation (this feature)

```text
specs/001-investment-agenda/
├── plan.md              # This file
├── research.md          # Decision log for logic and UI choices
├── data-model.md        # Investment entity and UUID structure
├── quickstart.md        # Setup and run instructions
└── tasks.md             # Actionable task list
```

### Source Code (repository root)

```text
lib/
├── core/
│   ├── theme/           # App colors and styles
│   ├── routes/          # GoRouter configuration
│   └── usecases/        # Base UseCase interface
├── features/
│   └── investments/
│       ├── domain/
│       │   ├── entities/
│       │   ├── repositories/
│       │   └── usecases/
│       ├── data/
│       │   ├── models/
│       │   ├── repositories/
│       │   └── datasources/
│       └── presentation/
│           ├── providers/
│           ├── widgets/
│           └── pages/
└── main.dart
```

## Development Phases

### Phase 1: Project Setup & Core Logic
**Objective**: Initialize the Flutter project, add dependencies, and set up core architectural scaffolding.
- **Outcome**: A compilation-ready project with `provider` and `go_router` configured.
- **Dependencies**: None.

### Phase 2: Domain Layer (Models & Use Cases)
**Objective**: Define the `Investment` entity and the business logic for CRUD operations and total calculation.
- **Outcome**: `investment.dart` entity and UseCase classes (Add, Update, Delete, GetTotals).
- **Dependencies**: Phase 1.

### Phase 3: Data Layer (Repository Implementation)
**Objective**: Implement the `InvestmentRepository` using an in-memory data source.
- **Outcome**: Functional repository that persists data during the session.
- **Dependencies**: Phase 2.

### Phase 4: State Management (Provider)
**Objective**: Create the `InvestmentProvider` to bridge the Domain layer and the UI.
- **Outcome**: A ChangeNotifier that exposes the investment list and total amount.
- **Dependencies**: Phase 3.

### Phase 5: Authentication (Login Feature)
**Objective**: Implement a simple login screen with hardcoded credentials and logic to protect the dashboard.
- **Outcome**: Login screen that redirects to the dashboard on success.
- **Dependencies**: Phase 1 (Routes).

### Phase 6: Home Screen (Dashboard)
**Objective**: Build the main dashboard with the investment list (Cards) and the total invested amount summary.
- **Outcome**: A responsive dashboard listing investments and showing the live total.
- **Dependencies**: Phase 4 & 5.

### Phase 7: Investment Form (Add/Edit)
**Objective**: Create a reusable form for adding and editing investments with inline validation.
- **Outcome**: Modal or screen for data entry with immediate validation feedback.
- **Dependencies**: Phase 4.

### Phase 8: Confirmation & Deletion
**Objective**: Implement the deletion flow including the Material confirmation dialog.
- **Outcome**: Users can delete items only after explicit confirmation.
- **Dependencies**: Phase 6.

### Phase 9: Navigation & Polish
**Objective**: Finalize Named Routes transition and polish UI with micro-animations and Snackbars for feedback.
- **Outcome**: Smooth transitions and clear success/error notifications.
- **Dependencies**: All previous phases.
