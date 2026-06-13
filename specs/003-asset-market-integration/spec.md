# Feature Specification: Asset Market Integration

**Feature Branch**: `003-asset-market-integration`  
**Created**: 2026-05-30  
**Status**: Draft  
**Input**: User description: "Integrate the application with Brapi to provide real market asset information through NestJS backend and display on Flutter front-end."

## Clarifications

### Session 2026-05-30

- Q: Which Brapi endpoints should be used for asset search and detail retrieval? → A: Use `/api/quote/list?search={query}` for search and `/api/quote/{ticker}` for asset details.
- Q: Which fields should be normalized by the backend? → A: Normalize `symbol`, `name`, `currentPrice`, `dayHigh`, `dayLow`, `changePercent`, `currency`, and `updatedAt`.
- Q: How should API failures be handled? → A: Backend returns standard REST error codes with `{ "statusCode": number, "message": string, "error": string, "retryable": boolean }` payload. Frontend displays a retry option or warning based on `retryable`.
- Q: How should asset search results be cached? → A: Cache search results for 5 minutes and detailed quotes for 1 minute in-memory on the NestJS backend.
- Q: How should loading states be handled? → A: Use skeletal loading animations (shimmer effects) on both the search results list and the asset details view.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Search and Find Assets (Priority: P1)

As an active investor, I want to search for market assets by their symbol or company name so that I can quickly locate specific assets I am interested in.

**Why this priority**: Core entry point for the market integration feature. Users must be able to find assets before they can select or view details.

**Independent Test**: Fully testable via the Search input field. Typing a query (e.g., "PETR4" or "Petrobras") returns a populated list of matching assets with their symbol and company name.

**Acceptance Scenarios**:

1. **Given** the user is on the Search screen, **When** they type a valid symbol (e.g., "VALE3") in the search input, **Then** the matching asset is displayed in the results list with its full name and symbol.
2. **Given** the user is on the Search screen, **When** they type a valid company name (e.g., "Itau"), **Then** all matching assets (e.g., "ITUB3", "ITUB4") are listed in the search results.
3. **Given** the user is on the Search screen, **When** they enter a query that yields no matches, **Then** an informative "No assets found" message is displayed.

---

### User Story 2 - View Detailed Asset Information (Priority: P1)

As an investor, I want to select an asset from the search results and view its comprehensive real-time details so that I can make informed investment decisions.

**Why this priority**: Essential MVP functionality. Simply searching is not useful unless the user can view the asset's current market status.

**Independent Test**: Fully testable by tapping/clicking any asset in the search results. This must open a details view showing the symbol, company name, current market price, and additional market data (e.g., daily high, daily low, price change percentage).

**Acceptance Scenarios**:

1. **Given** a list of search results, **When** the user taps on an asset (e.g., "PETR4"), **Then** they are presented with a detailed view containing:
   - Symbol ("PETR4")
   - Company Name ("Petroleo Brasileiro S.A. - Petrobras")
   - Current Market Price (e.g., "R$ 38.50")
   - Additional market information (e.g., change percentage, day high/low).
2. **Given** the user is viewing asset details, **When** they navigate back, **Then** they are returned to their previous search results list with their search query preserved.

---

### User Story 3 - Graceful Handling of External API Failures (Priority: P2)

As a user, I want the system to handle external service outages or rate limits gracefully so that my application experience is not broken or frozen.

**Why this priority**: External integrations (like Brapi) are subject to rate limiting, network issues, or downtime. The system must remain stable and provide clear feedback.

**Independent Test**: Testable by simulating an API timeout or error on the backend. The frontend must display a user-friendly error message with a retry action instead of crashing.

**Acceptance Scenarios**:

1. **Given** the backend fails to reach the external market data provider, **When** the user performs a search, **Then** the UI displays an error message stating "Unable to retrieve market data. Please try again later."
2. **Given** a network failure during details retrieval, **When** the user attempts to view asset details, **Then** they see a failure screen with a "Retry" button that allows them to re-attempt the request.

---

### User Story 4 - Portfolio Integration Foundation (Priority: P3)

As a developer/future user, I want the backend asset model to support portfolio integration so that we can easily link search results to portfolio valuation in future updates.

**Why this priority**: Prepares the architecture for the next phase of development without over-engineering the current MVP.

**Independent Test**: Verify that the backend response includes clean, standardized entities (UUIDs or clean symbols) suitable for database primary/foreign keys in a future portfolio schema.

**Acceptance Scenarios**:

1. **Given** a normalized asset payload from the backend, **When** the client parses it, **Then** the payload includes a persistent identifier and standard numeric values (float/double) that can be easily persisted in a local/remote database for valuation.

---

### Edge Cases

- **Special Characters in Search**: If the user enters special characters (e.g., "@#$*"), the system must sanitize the input and return zero results gracefully rather than crashing.
- **Empty Search Query**: When the user clears the search input, the search results list should reset to an empty state or display a "Type to search" prompt.
- **Outdated Prices (Delayed Feed)**: If the market provider returns delayed data, the UI should optionally show a "Delayed Data" indicator or timestamp.
- **Rapid Keystrokes (Rate Limiting)**: If the user types very rapidly, the frontend must debounce requests to prevent flooding the backend with intermediate search calls.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The system MUST allow users to search for market assets using either their symbol (ticker) or company name.
- **FR-002**: The search interface MUST display search results in a responsive list, showing the asset symbol and company name for each match.
- **FR-003**: The system MUST allow users to select a single asset from the search results list to view its complete details.
- **FR-004**: The system MUST retrieve and display the following core data points in the asset details view:
  - Symbol (ticker)
  - Full company name
  - Current market price
  - High, Low, and Change Percentage for the day (if available)
- **FR-005**: All client-side communication with the market data provider MUST be proxied through the backend API gateway. The mobile frontend MUST NOT call the external market data provider directly.
- **FR-006**: The backend gateway MUST sanitize and normalize the external market data payload before serving it to the client, removing extraneous provider-specific metadata and casting numbers to uniform types.
- **FR-007**: The backend gateway MUST handle external API errors, map them to standard REST HTTP status codes (e.g., 404, 429, 503), and return a standardized JSON error response containing a `retryable` boolean flag.
- **FR-008**: The backend API gateway MUST query the Brapi `/api/quote/list?search={query}` endpoint to fulfill search requests and `/api/quote/{ticker}` to retrieve individual asset details.
- **FR-009**: The Flutter frontend MUST display custom skeletal shimmer placeholder animations while waiting for search results or asset detail payloads from the API.

### Key Entities *(include if feature involves data)*

- **MarketAsset**:
  - Represents a searchable asset.
  - Attributes: `symbol` (String, unique identifier), `name` (String, company name).
- **AssetDetails**:
  - Represents full market status of a selected asset.
  - Attributes: `symbol` (String), `name` (String), `currentPrice` (Decimal/Double), `dayHigh` (Decimal/Double), `dayLow` (Decimal/Double), `changePercent` (Decimal/Double), `currency` (String), `updatedAt` (DateTime).

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Users can complete a search and view details for any valid asset in under 3 seconds under normal network conditions.
- **SC-002**: 100% of external API communication is routed through the backend gateway (verified by network inspection; no direct client-to-Brapi calls).
- **SC-003**: The search results debounce mechanism limits client API requests to at most 1 request per 300ms of active typing.
- **SC-004**: System handles external provider downtime gracefully by displaying a localized error page/toast within 2 seconds of the failure.

## Assumptions

- **A-001**: The external market data provider (Brapi) requires an API authentication token, which will be stored securely in the backend server's environment variables.
- **A-002**: Asset pricing data is provided in Brazilian Real (BRL) as the primary currency, reflecting the default market catalog.
- **A-003**: Historical price charts (e.g., sparklines or interactive charts) are considered out of scope for the initial MVP version of this feature.
- **A-004**: Caching is applied in-memory at the backend proxy layer: search results are cached for 5 minutes, and individual asset details are cached for 1 minute.
