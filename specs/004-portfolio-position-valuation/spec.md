# Feature Specification: Portfolio Position Valuation

**Feature Branch**: `004-portfolio-position-valuation`  
**Created**: 2026-05-29  
**Status**: Draft  
**Input**: User description: "Create a new feature called Portfolio Position Valuation. Objective: Allow users to track profit and loss for each asset in their portfolio using real market prices obtained from Brapi."


## Clarifications

### Session 2026-05-29

- Q: How should average purchase price be stored? → A: High-precision decimal (`DECIMAL(18, 4)`) for absolute accuracy.
- Q: How should portfolio totals be aggregated? → A: Dynamic backend aggregation: Calculated on the fly on every GET dashboard request.
- Q: How should unavailable market prices be handled? → A: Resilient hierarchy (Cache → Last known / Cost basis fallback) with an `isDelayed` boolean flag.
- Q: How should negative returns be represented? → A: Signed raw numeric values (e.g. negative numbers `-450.50`), allowing the frontend to apply dynamic visual styling.
- Q: How should percentage calculations be rounded? → A: Rounded to exactly 2 decimal places on the backend (e.g. `16.67`) for direct dashboard representation.

## User Scenarios & Testing *(mandatory)*


### User Story 1 - Asset Position Registration (Priority: P1)

An investor wants to add or update an asset position in their portfolio so they can begin tracking its performance. The user selects an asset from the search results, enters the quantity purchased, and defines their average purchase price.

**Why this priority**: It is the foundational CRUD entry point. Without registering position assets, no portfolio valuation or tracking calculations can occur.

**Independent Test**: The user can search B3 tickers (e.g., PETR4) via Brapi integration, select the asset, input a quantity of 10 and an average price of R$ 30.00, and register it. The position is successfully persisted and retrieved.

**Acceptance Scenarios**:

1. **Given** an authenticated user on the "Add Asset" screen, **When** they search for "PETR4", select the asset, input quantity `10` and average price `30.00`, and submit, **Then** the system persists the position under their portfolio and returns a success status.
2. **Given** a user inputting a negative quantity `-5` or a negative average price `-10.00`, **When** they attempt to register the asset, **Then** the system blocks the submission and displays a clear validation error.

---

### User Story 2 - Portfolio Valuation Dashboard (Priority: P1)

An investor wants to open their dashboard to view a consolidated summary of their investments, along with a detailed list of each position displaying real-time market prices, invested amounts, and overall profit/loss stats.

**Why this priority**: This delivers the core value of the feature—giving investors immediate visual feedback on their net worth and individual asset performance using current market values.

**Independent Test**: Loading the dashboard displays a summary card (Total Invested, Total Current Value, Total Profit/Loss, Total Return %) and a table list of positions containing correct mathematical calculations.

**Acceptance Scenarios**:

1. **Given** a user has a position of `10` shares of PETR4 with an average purchase price of `30.00` (Invested: R$ 300.00) and the current Brapi market price is `35.00` (Current Value: R$ 350.00), **When** they load the dashboard, **Then** they see a Profit/Loss of `+ R$ 50.00` and a Profit/Loss percentage of `+ 16.67%`.
2. **Given** multiple active positions in the portfolio, **When** the dashboard loads, **Then** the Portfolio Summary correctly sums all positions:
   - `Total Invested` = Sum of all (quantity * averagePurchasePrice)
   - `Total Current Value` = Sum of all (quantity * currentMarketPrice)
   - `Total Profit/Loss` = `Total Current Value` - `Total Invested`
   - `Total Return Percentage` = `((Total Current Value - Total Invested) / Total Invested) * 100`

---

### User Story 3 - Graceful Handling of External Price Glitches (Priority: P2)

An investor loads their portfolio when the external Brapi pricing service is temporarily down or under rate limits, and expects to see their portfolio valued using cached fallback prices or standard cached quotes rather than encountering an application crash.

**Why this priority**: Ensures system reliability and a premium user experience even when downstream dependencies fail.

**Independent Test**: Simulating a Brapi API timeout or 503 error during portfolio load uses the in-memory backend cache or mock fallback prices to value the position, showing a warning banner to the user that prices may be delayed.

**Acceptance Scenarios**:

1. **Given** the Brapi service is offline, **When** the user loads the dashboard, **Then** the backend uses the cached asset details (from the 1-minute NestJS cache) or falls back to mock quotes, and returns the calculated position correctly.

---

### Edge Cases

- **Zero Position Quantities**: If a user updates their asset position quantity to `0`, the system must remove that asset position from the portfolio tracking view.
- **Extreme Price Glips**: If an asset's market price drops to zero or is not fetchable from Brapi/Cache, the system uses the last known price or average purchase price as a temporary fallback to avoid division-by-zero errors in Return Percentage.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The system MUST allow users to register an asset position by specifying the asset symbol (validated via Brapi), quantity (must be positive), and average purchase price (must be positive).
- **FR-002**: The backend MUST perform all mathematical position calculations:
  - `Invested Amount` = `quantity * averagePurchasePrice`
  - `Current Position Value` = `quantity * currentMarketPrice`
  - `Profit/Loss` = `currentPositionValue - investedAmount`
  - `Profit/Loss Percentage` = `((currentPositionValue - investedAmount) / investedAmount) * 100`
  - Percentage and currency calculations MUST be rounded on the backend to exactly 2 decimal places for direct, unified client representation.
- **FR-003**: The backend MUST dynamically consolidate all active positions on every dashboard GET request to produce a global, real-time Portfolio Summary containing `Total Invested`, `Total Current Value`, `Total Profit/Loss`, and `Total Return Percentage`.
- **FR-004**: The backend MUST retrieve real-time market prices utilizing the existing `AssetsService` proxy. If unavailable (rate-limit or outage), the system MUST employ a resilient hierarchy (cached price → average cost basis fallback) and append an `isDelayed: true` flag to notify the client.
- **FR-005**: The frontend MUST only serve as a presentation layer, displaying calculated fields directly as returned by the API with no inline calculation logic. Raw negative financial numbers are returned as signed numeric values from the backend, and the frontend handles visual formatting (e.g., color coding and signs).
- **FR-006**: Dividend calculations are explicitly OUT OF SCOPE. The system MUST focus solely on capital gain position valuation.

### Key Entities *(include if feature involves data)*

- **PortfolioPosition**: Represents a user's holding in a specific asset.
  - `id`: Unique identifier (UUID).
  - `userId`: Identifier of the owner (foreign key to User).
  - `symbol`: The asset ticker symbol (e.g., PETR4).
  - `quantity`: Quantity of the asset held (decimal).
  - `averagePurchasePrice`: Average cost basis per share (DECIMAL(18, 4)).
  - `createdAt`: Timestamp.
  - `updatedAt`: Timestamp.

- **PortfolioValuation**: A transient representation of a calculated portfolio position returned to the client.
  - `symbol`: Asset symbol.
  - `name`: Asset company name.
  - `quantity`: Quantity held.
  - `averagePurchasePrice`: Average purchase price.
  - `currentMarketPrice`: Real-time market price.
  - `investedAmount`: Cost basis.
  - `currentPositionValue`: Current market value.
  - `profitLoss`: Value change.
  - `profitLossPercentage`: Percent return.
  - `isDelayed`: Boolean flag indicating if the market price used is stale or fallback.

- **PortfolioSummary**: Transient overall performance metrics.
  - `totalInvested`: Sum of all cost bases.
  - `totalCurrentValue`: Sum of all current positions.
  - `totalProfitLoss`: Total net gain/loss.
  - `totalReturnPercentage`: Overall percent return.
  - `isDelayed`: Boolean flag indicating if any asset valuation in the summary was delayed.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Investors can add or update an asset position in under 1.5 seconds.
- **SC-002**: Valuation dashboard loads and renders all positions and sums in under 800ms.
- **SC-003**: Arithmetic calculations on the backend must be accurate to 2 decimal places, preventing rounding issues on large portfolios.
- **SC-004**: System supports offline mock price fallbacks, achieving 100% dashboard uptime even during Brapi service outages.

## Assumptions

- **Single Portfolio per User**: Each authenticated user has exactly one consolidated investment portfolio.
- **SQL Persistence**: Positions are persisted in the existing relational database using NestJS TypeORM.
- **Auth Context**: All API requests are protected by the global JWT auth guard, allowing the backend to map positions securely to the authenticated user ID.
- **Standard B3 Trading**: All traded symbols represent B3 equities or real estate funds denominated in BRL, eliminating any currency conversion needs.
