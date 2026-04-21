# Research: Investment Agenda Technical Decisions

## Decision 1: Currency Formatting
- **Decision**: Use the `intl` package with `NumberFormat.simpleCurrency(locale: context.locale.toString())`.
- **Rationale**: Meets the specification requirement for automatic system locale detection.
- **Alternatives considered**: Manual formatting (too complex, error-prone).

## Decision 2: Unique Identification
- **Decision**: Use the `uuid` package to generate UUID v4 strings for each investment object.
- **Rationale**: Ensures unique keys for list rendering and collision-free future database sync.
- **Alternatives considered**: Integer counters (hard to maintain if data is cleared/restored).

## Decision 3: Navigation Framework
- **Decision**: Use `go_router` for named routes.
- **Rationale**: More robust than standard named routes; supports nested navigation and deep linking if needed in the future.
- **Alternatives considered**: Basic `Navigator` (harder to scale).

## Decision 4: Folder Structure
- **Decision**: Feature-first Clean Architecture.
- **Rationale**: MANDATORY by the Project Constitution. Separates UI from business logic.
