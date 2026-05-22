# Feature Specification: NestJS Backend Authentication

**Feature Branch**: `002-nestjs-backend-auth`  
**Created**: 2026-05-15  
**Status**: Draft  
**Input**: User description: "Create a NestJS backend for the Investment Agenda application. Current scope: Authentication, Users, Clean Architecture, Modular structure, Repository abstraction, In-memory storage, Security (bcrypt, JWT), Validation (class-validator)."

## Clarifications

### Session 2026-05-15
- Q: What should the JWT expiration strategy be? → A: Short-lived Access Token (e.g., 15m) + Refresh Token (stored in memory).
- Q: How should the system handle token invalidation upon logout? → A: Server invalidates refresh token upon logout; client simply deletes access token.
- Q: Should route protection be applied globally or locally? → A: Global Guard (secure by default; explicitly mark routes as @Public()).
- Q: What level of password strength validation should be enforced? → A: Strict Validation (min 8 chars, upper, lower, number, special character).
- Q: What should the bcrypt salt rounds (cost factor) be? → A: Standard Default (10 rounds).

## User Scenarios & Testing *(mandatory)*

### User Story 1 - User Registration (Priority: P1)

A new user wants to create an account by providing their email and a secure password so that they can access the application.

**Why this priority**: Without an account, the user cannot interact with any authenticated features of the application.

**Independent Test**: Can be fully tested by submitting a valid registration payload to the registration endpoint and verifying that a success response (or token) is returned and the user is stored in-memory.

**Acceptance Scenarios**:

1. **Given** a valid, unregistered email and password, **When** the user submits the registration request, **Then** the system creates the user, hashes the password, and returns a success response.
2. **Given** an invalid email format or missing password, **When** the user submits the request, **Then** the system rejects it with validation errors.
3. **Given** an already registered email, **When** the user attempts to register, **Then** the system returns a conflict/error message.

---

### User Story 2 - User Login (Priority: P1)

An existing user wants to authenticate with their email and password so that they receive a token to access protected resources.

**Why this priority**: Users need a way to securely prove their identity in subsequent requests.

**Independent Test**: Can be tested independently by logging in with a pre-registered account and receiving a valid JWT.

**Acceptance Scenarios**:

1. **Given** valid credentials, **When** the user submits a login request, **Then** the system validates the password against the hash and returns a valid JWT.
2. **Given** invalid credentials, **When** the user submits a login request, **Then** the system returns an unauthorized error message.

---

### User Story 3 - Secure Route Access (Priority: P2)

An authenticated user wants to access a protected application endpoint to retrieve their personal data.

**Why this priority**: Validates that the system correctly enforces security and route protection using the generated JWTs.

**Independent Test**: Can be tested by making requests to a protected endpoint with and without a valid JWT.

**Acceptance Scenarios**:

1. **Given** a valid JWT in the Authorization header, **When** the user accesses a protected route, **Then** the system grants access.
2. **Given** an expired or invalid JWT, **When** the user accesses a protected route, **Then** the system denies access with an unauthorized error.

---

### User Story 4 - User Logout (Priority: P2)

An authenticated user wants to securely log out so that their active session is terminated.

**Why this priority**: Crucial for security on shared devices, ensuring long-lived refresh tokens cannot be used after the user intends to end their session.

**Independent Test**: Can be tested by logging out and subsequently attempting to use the old refresh token to obtain a new access token (which must fail).

**Acceptance Scenarios**:

1. **Given** an authenticated user with a valid refresh token, **When** the user submits a logout request, **Then** the system removes/invalidates the refresh token from memory and returns a success response.

### Edge Cases

- What happens when a user attempts to login while their account is locked or disabled? (Assumption: No account locking in current scope).
- How does the system handle concurrent registrations with the same email?

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST allow users to register with an email and password.
- **FR-002**: System MUST allow users to authenticate using their credentials to receive a short-lived access JWT (e.g., 15m) and a refresh token.
- **FR-003**: System MUST implement route protection globally (secure by default), requiring developers to explicitly bypass the JWT guard for public endpoints (like login/register).
- **FR-004**: System MUST hash user passwords securely (using bcrypt with a cost of 10 rounds) before storing them.
- **FR-005**: System MUST validate all incoming request payloads using DTO validation rules, enforcing strict password validation (min 8 chars, upper, lower, number, special character) during registration.
- **FR-006**: System MUST persist user data using an abstract Repository interface, temporarily implemented with in-memory storage.
- **FR-007**: System MUST securely manage refresh tokens in-memory to allow users to obtain new access tokens without re-authenticating.
- **FR-008**: System MUST provide a logout endpoint that invalidates the user's refresh token from in-memory storage.

### Key Entities

- **User**: Represents the account (attributes: ID, email, password hash).
- **AuthToken**: Represents the access credentials (attributes: short-lived JWT access token, long-lived refresh token).

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Users can successfully register and receive a response in under 1 second.
- **SC-002**: 100% of generated access tokens are signed, valid, and successfully restrict access to protected routes.
- **SC-003**: Invalid requests (bad email format, weak passwords) are rejected with clear validation error messages 100% of the time.
- **SC-004**: System architecture enforces clean separation of concerns, ensuring Domain/Service logic has zero dependency on the HTTP transport or specific database implementation.

## Assumptions

- Temporary in-memory persistence is acceptable for this initial phase; database integration will be implemented in a future iteration.
- Investment CRUD operations and financial APIs are completely out of scope for this spec.
- Passwords are provided over a secure connection (HTTPS in production).
