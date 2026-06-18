# Research: Carteira de Investimentos

## Decision 1: Portfolio entity separation
**Decision**: Create separate tables for `Portfolio` (Carteira) and `Investment` (Investimento).
**Rationale**: Allows the user to have multiple distinct portfolios as defined in FR-003. A Portfolio belongs to a User, and an Investment belongs to a Portfolio.
**Alternatives considered**: Having only an `Investment` table tied directly to `User`. Rejected because it prevents creating distinct named portfolios (like "Aposentadoria" vs "Curto Prazo").

## Decision 2: Prisma Schema structure
**Decision**: Add `Portfolio` model with 1-to-many relationship to `Investment`. Add `Investment` model with fields `name`, `assetType`, `quantity`, `purchasePrice`, and `purchaseDate`.
**Rationale**: FR-004 requires these specific fields to calculate future profitability.
**Alternatives considered**: Using a JSON payload for investment details. Rejected because it violates normalization and makes SQL-based reporting/filtering much harder.
