# Feature Specification: Investment Agenda

**Feature Branch**: `001-investment-agenda`  
**Created**: 2026-04-21  
**Status**: Draft  
**Input**: User description for a Flutter mobile app to manage and track investments.

## Clarifications

### Session 2026-04-21
- Q: How should the application handle currency symbols and number formatting? → A: Option A (System Locale: Automatically detect and use device settings).
- Q: What should the Dashboard display when the user has not yet added any investments? → A: Option A (Illustration + Call to Action).
- Q: Should the application use named routes or direct Navigator pushes? → A: Option A (Named Routes).
- Q: How should the system communicate input errors or unexpected process failures? → A: Option A (Inline + Snackbars).
- Q: How should each investment be uniquely identified? → A: Option A (UUID String).

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Secure Access (Priority: P1)
As a user, I want to log in using my credentials so that I can access my private investment dashboard.

**Why this priority**: Authentication is the entry point to the application and protects user data.

**Independent Test**: The user can enter hardcoded credentials on the Login screen and be redirected to the Home screen. Invalid inputs should show an error.

**Acceptance Scenarios**:
1. **Given** the user is on the Login screen, **When** they enter correct hardcoded credentials and tap "Login", **Then** they are redirected to the Home screen (Dashboard).
2. **Given** the user is on the Login screen, **When** they enter incorrect credentials, **Then** an error message is displayed and they remain on the Login screen.

---

### User Story 2 - Portfolio Dashboard (Priority: P1)
As a user, I want to see a summary of all my investments and the total amount invested in one place.

**Why this priority**: This is the core value proposition of the app—tracking the overall financial state.

**Independent Test**: Add multiple investments and verify the "Total Invested" counter reflects the sum of all "Amount Invested" fields.

**Acceptance Scenarios**:
1. **Given** the user is on the Home screen, **When** they have existing investments, **Then** they see a card for each investment and a global "Total Invested" sum.
2. **Given** the user has no investments, **When** they view the Dashboard, **Then** an illustrative empty state appears with an "Add your first investment" button.

---

### User Story 3 - Investment Management (Priority: P2)
As a user, I want to add, edit, and delete investments so that my portfolio remains up to date.

**Why this priority**: Essential for maintaining an accurate investment log.

**Independent Test**: Complete a full CRUD (Create, Read, Update, Delete) cycle: Add an investment, modify its content, and then delete it.

**Acceptance Scenarios**:
1. **Given** the user is on the Dashboard, **When** they choose to add a new investment, **Then** they are presented with an entry form.
2. **Given** the user is on the Entry Form, **When** they fill in Name, Amount, and Monthly Return and save, **Then** they are returned to the Dashboard and the new item is listed.
3. **Given** the user is on the Dashboard, **When** they choose to delete an investment, **Then** a confirmation prompt appears.
4. **Given** a confirmation prompt is open, **When** the user confirms deletion, **Then** the investment is removed from the list and the total amount updates.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST authenticate users using hardcoded credentials [NEEDS CLARIFICATION: What are the default credentials?].
- **FR-002**: System MUST allow users to input Investment Name, Amount Invested, and Monthly Return.
- **FR-003**: System MUST provide a Dashboard showing a list of investment cards and the total sum of all amounts, formatted according to the user's localized system settings.
- **FR-004**: System MUST display a confirmation dialog before permanently deleting an investment.
- **FR-005**: System MUST allow editing existing investments via a form populated with previous values.
- **FR-006**: System MUST persist investment data for the duration of the application session.
- **FR-007**: System MUST implement navigation between restricted and unrestricted screens using a named route management system.
- **FR-008**: System MUST perform inline field validation on the Investment Form (e.g., non-empty name, numeric amounts).
- **FR-009**: System MUST provide immediate user feedback via Snackbars for successful or failed data operations (save, edit, delete).

### Key Entities

- **Investment**: Represents a single financial asset. Contains:
    - `id` (String, unique UUID v4)
    - `name` (String)
    - `amountInvested` (Double)
    - `monthlyReturn` (Double)

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: 100% of users can access the dashboard after entering correct credentials.
- **SC-002**: All investment list updates (add/edit/delete) reflect in the UI in under 1 second.
- **SC-003**: The "Total Invested" calculation is accurate and formatted correctly (currency symbol and separators) according to the system locale at all times.
- **SC-004**: Zero investments are deleted without user confirmation.

## Assumptions

- Users will only access the app on mobile devices in portrait mode initially.
- No network connection is required for the initial version (using in-memory list).
- Standard Material Design "premium" widgets will be used for cards and forms.
- Data validation (e.g., preventing negative amounts) will be implemented as standard practice [NEEDS CLARIFICATION: Are there specific validation ranges for amounts or returns?].
