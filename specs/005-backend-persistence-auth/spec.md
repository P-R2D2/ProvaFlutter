# Feature Specification: Persistent Backend Storage & Authentication

**Feature Branch**: `005-backend-persistence-auth`  
**Created**: 2026-06-10  
**Status**: Draft  
**Input**: User description: "Extend the Investment Agenda backend with persistent storage."

## Clarifications

### Session 2026-06-10

- Q: Should Portfolio names be unique per user? → A: Yes, portfolio names must be unique per user.
- Q: How should cascading deletes behave for Users, Portfolios, and Investments? → A: Complete cascade deletion (User -> Portfolios -> Investments).
- Q: How should ownership validation be enforced? → A: Enforced via NestJS Guards/Interceptors (requests are intercepted and validated before route handlers execute).
- Q: How should JWT authorization be applied? → A: Globally enabled by default (all routes secure by default; public routes opt-out using a `@Public()` decorator).




## User Scenarios & Testing *(mandatory)*

### User Story 1 - Secure User Authentication & Registration (Priority: P1)

Users must be able to securely create an account and authenticate themselves to protect their financial data.

**Why this priority**: Core security foundation. Without user authentication, portfolios cannot be uniquely associated with individuals, exposing private investment data.

**Independent Test**: Can be verified by attempting to register a new user, logging in with valid and invalid credentials, and checking that the system correctly grants or denies access tokens.

**Acceptance Scenarios**:

1. **Given** no user account exists with the email `user@example.com`, **When** a registration request is submitted with this email and a valid password, **Then** a new user account is created and stored securely.
2. **Given** a registered user exists with the email `user@example.com` and password `Password123!`, **When** a login request is submitted with these credentials, **Then** the system returns a secure session access token.
3. **Given** a registered user exists with the email `user@example.com`, **When** a login request is submitted with an incorrect password, **Then** the request is rejected with a clear authentication error and no token is generated.

---

### User Story 2 - Session Validation & Access Control (Priority: P1)

The system must protect user resources by verifying session credentials on every stateful request.

**Why this priority**: Crucial for enforcing data privacy. It ensures only authenticated users can access, create, or update portfolios and investments.

**Independent Test**: Can be verified by attempting to request portfolio lists or add investments using valid tokens, expired tokens, or no tokens, and confirming that invalid requests return unauthorized access responses.

**Acceptance Scenarios**:

1. **Given** an authenticated user with a valid session token, **When** they make a request to list their portfolios, **Then** the system successfully returns their portfolio data.
2. **Given** a client request with an expired, tampered, or missing session token, **When** they attempt to access or modify any portfolio resources, **Then** the request is rejected with a standard unauthenticated response.

---

### User Story 3 - Relational Portfolio & Investment Management (Priority: P1)

Authenticated users must be able to organize their assets into named portfolios and persist specific holding transactions.

**Why this priority**: Core functional capability. Allows users to store and organize their asset details without losing information when sessions close.

**Independent Test**: Can be verified by creating portfolios, adding investments to those portfolios, retrieving them, and attempting to access another user's portfolios to ensure they are blocked.

**Acceptance Scenarios**:

1. **Given** a logged-in user, **When** they request to create a portfolio named "Retirement Fund" with an optional description, **Then** the portfolio is created, linked to that user, and successfully persisted.
2. **Given** a user's portfolio, **When** they register an investment for asset symbol "PETR4" with quantity 100 and average purchase price 35.50, **Then** the investment is successfully added to that portfolio and persisted.
3. **Given** User A owns Portfolio A, **When** User B (authenticated but different) attempts to view or add investments to Portfolio A, **Then** the request is rejected as unauthorized.

---

### Edge Cases

- **Duplicate Email Registration**: If a registration request is sent with an email address already registered in the system, the registration must fail with a descriptive conflict message.
- **Negative/Zero Values**: Attempting to add an investment with a quantity or purchase price less than or equal to zero must be rejected with validation errors.
- **Cascading Deletes**: If a portfolio is deleted, all associated investments must be deleted automatically. If a user account is deleted, all their portfolios and investments must be deleted automatically.
- **Malformed Symbol formats**: Adding an investment with empty asset symbols or invalid formats must be rejected.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST allow users to register with a unique email address and a password.
- **FR-002**: System MUST securely hash user passwords before they are persisted.
- **FR-003**: System MUST validate registration credentials (e.g. valid email structure, minimum password strength).
- **FR-004**: System MUST allow users to log in with correct credentials to obtain a secure stateless session token.
- **FR-005**: System MUST validate the stateless session token on every protected API endpoint request.
- **FR-006**: System MUST allow authenticated users to create portfolios with a name and optional description.
- **FR-007**: System MUST enforce that a portfolio belongs to exactly one user and cannot be accessed or modified by anyone else.
- **FR-008**: System MUST allow users to manage (add, read, update, delete) investments inside their own portfolios.
- **FR-009**: System MUST validate that investment quantities and average purchase prices are positive decimal/numeric values.
- **FR-010**: System MUST prevent duplicate portfolio names for the same user.
- **FR-011**: System MUST cascade-delete all child records (portfolios and investments) if their parent owner (user or portfolio) is deleted.

### Key Entities *(include if feature involves data)*

- **User**: Represents a registered user.
  - Attributes: ID, email, password hash, creation timestamp, update timestamp.
  - Relationships: Has a 1-to-many (1 -> N) relationship with Portfolios.
- **Portfolio**: Represents a named container for investments owned by a user.
  - Attributes: ID, name, description, user ID reference, creation timestamp, update timestamp.
  - Relationships: Belongs to one User, has a 1-to-many (1 -> N) relationship with Investments.
- **Investment**: Represents a specific asset holding transaction inside a portfolio.
  - Attributes: ID, asset symbol (e.g. PETR4), asset name (e.g. Petrobras), quantity, average purchase price, portfolio ID reference, creation timestamp, update timestamp.
  - Relationships: Belongs to one Portfolio.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: 100% of user accounts, portfolios, and investment transactions are successfully persisted and retrievable across server and database restarts.
- **SC-002**: 100% of unauthorized requests (unauthenticated or accessing other users' data) are blocked and logged.
- **SC-003**: Database transaction integrity is preserved; partial or invalid writes (e.g. investment without portfolio) are completely rolled back.
- **SC-004**: Core read and write operations for portfolios and investments complete in under 200ms under standard loads.

## Assumptions

- **AS-001**: A relational database structure is utilized to enforce foreign key constraints between users, portfolios, and investments.
- **AS-002**: Standard JWT (JSON Web Tokens) and password hashing algorithms (such as bcrypt) are utilized for authentication.
- **AS-003**: All portfolio valuation, return calculations, dividend yields, and price history tracking are out of scope for this phase.
- **AS-004**: Real-time stock market value syncing is out of scope for this phase.
- **AS-005**: NestJS implementation relies on a global JWT Authentication Guard (opt-out via `@Public()`) and resource-level Guards for ownership validation.
- **AS-006**: The PostgreSQL database schema defines a unique constraint on portfolio `(userId, name)` and explicit indexes on all foreign keys (`userId` and `portfolioId`) for optimized query lookup.
- **AS-007**: Business logic in services is decoupled from database persistence by interacting through Repository interfaces, separating the domain model from Prisma generated types to ease future integration of valuation features.

