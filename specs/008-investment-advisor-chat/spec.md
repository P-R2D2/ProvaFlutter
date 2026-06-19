# Feature Specification: Intelligent Investment Advisor Chat

**Feature Branch**: `008-investment-advisor-chat`  
**Created**: 2026-06-19  
**Status**: Draft  
**Input**: User description: "Create a new feature called Intelligent Investment Advisor Chat..."

## Clarifications

### Session 2026-06-19
- Q: How should proactive insights (e.g., detecting excessive concentration) be triggered? → A: Scheduled (Batch): Evaluated periodically (e.g., daily) via a background job.
- Q: How should AI conversation history be persisted? → A: Rolling Window: Stored in the database but purged after a set period (e.g., 30 days).
- Q: How should AI hallucinations be mitigated and recommendations validated? → A: Heuristic & Disclaimer: Validate ticker/asset formats using heuristics and always append a standard financial disclaimer.
- Q: How should multiple distinct portfolios be summarized and injected into the AI context? → A: Distinct but Combined: Provide all portfolios as distinct entities to allow holistic analysis.
- Q: How should the architecture prepare for future real-time market data integration? → A: Tool Calling: Design the AI interaction layer using native LLM tool/function calling capabilities.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Context-Aware Beginner Guidance (Priority: P1)

A user with no current investments opens the chat to get started with investing. The assistant automatically knows their investor profile and goals from onboarding and guides them to build their first portfolio.

**Why this priority**: Getting new users to start investing is critical for user activation and demonstrating the value of the intelligent assistant.

**Independent Test**: Can be fully tested by creating a new user with an investor profile but empty portfolio, opening the chat, and verifying the assistant proactively guides them to an initial asset allocation without asking for their profile details.

**Acceptance Scenarios**:

1. **Given** an authenticated user with an investor profile but no investments, **When** they open the chat for the first time, **Then** the assistant greets them and suggests a foundational portfolio allocation based on their risk tolerance and goals.
2. **Given** the assistant suggests a portfolio, **When** the user asks "why these investments?", **Then** the assistant explains the rationale in accessible, beginner-friendly language.

---

### User Story 2 - Automated Portfolio Analysis (Priority: P1)

An experienced user with multiple investments opens the chat to understand the health of their portfolio. The assistant analyzes their current assets against their risk profile and goals.

**Why this priority**: Delivering personalized insights to existing investors is the core value proposition of the feature for the active user base.

**Independent Test**: Can be tested by logging in as a user with a diverse portfolio, opening the chat, and asking "How is my portfolio doing?", verifying the response reflects actual asset allocation and profile matching.

**Acceptance Scenarios**:

1. **Given** a user with existing investments, **When** they ask for a portfolio review, **Then** the assistant evaluates the portfolio's fixed/variable income exposure, concentration, and diversification.
2. **Given** a portfolio that is too heavily concentrated in one asset class, **When** the assistant analyzes it, **Then** it highlights the concentration risk and suggests steps to rebalance according to the user's profile.

---

### User Story 3 - Proactive Insights (Priority: P2)

The system automatically detects that a user's portfolio has deviated significantly from their recommended asset allocation due to market movements.

**Why this priority**: Proactive engagement keeps users returning to the app and helps them manage risk effectively before they explicitly ask for help.

**Independent Test**: Can be tested by simulating a portfolio deviation and verifying the chat interface presents a proactive alert or recommendation.

**Acceptance Scenarios**:

1. **Given** a user's portfolio concentration exceeds their risk profile threshold, **When** the system evaluates the portfolio, **Then** the assistant generates a proactive recommendation to improve diversification.
2. **Given** a proactive recommendation is generated, **When** the user opens the application, **Then** they see an indicator or message in the chat panel alerting them to the new insight.

---

### User Story 4 - Continuous and Persistent Chat Experience (Priority: P2)

A user is navigating between different screens in the application while having a conversation with the assistant.

**Why this priority**: A seamless UX ensures users can reference their portfolios while receiving advice without losing context.

**Independent Test**: Can be tested by starting a conversation, navigating across different application pages, and verifying the chat state remains intact and accessible.

**Acceptance Scenarios**:

1. **Given** the user is in an active chat session, **When** they navigate to a different screen (e.g., from Dashboard to Add Investment), **Then** the chat panel remains accessible and the conversation history is preserved.
2. **Given** the chat panel is open, **When** the user minimizes it, **Then** it collapses to a floating docked state without losing the session context.

### Edge Cases

- What happens when the user's investor profile is incomplete or missing? (Assistant should prompt them to complete the onboarding interview).
- How does the system handle temporary unavailability of the AI provider? (Graceful error message in the chat UI without breaking the application).
- What happens if the system cannot retrieve the complete portfolio context in time? (Chat should fall back to general guidance or inform the user that portfolio data is syncing).
- How does the system handle malformed LLM responses? (The resilient parsing layer attempts recovery, and falls back to safe generic responses if parsing fails).

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The system MUST provide a floating chat interface docked to the right side of the application that can be expanded or collapsed at any time.
- **FR-002**: The system MUST preserve conversation history across sessions using a rolling window (e.g., storing in the database and purging after 30 days) to maintain recent context.
- **FR-003**: The core system MUST generate and inject a summarized portfolio context (including investor profile, objectives, total invested, asset allocation, categories, largest positions, sector allocation, diversification metrics, and risk exposure) rather than sending raw portfolio entities directly to the AI.
- **FR-004**: The interface MUST display responses progressively as they are generated and support formatted text (e.g., bolding, lists).
- **FR-005**: The assistant MUST be able to analyze and evaluate various investment categories including fixed income, variable income, funds, stocks, ETFs, FIIs, and government bonds.
- **FR-006**: The system MUST proactively evaluate portfolios via scheduled batch jobs (e.g., daily) and generate insights when it detects excessive concentration, profile deviation, or lack of diversification.
- **FR-007**: The user interface MUST NOT communicate directly with any external AI providers; all requests MUST be routed securely through the system's core services.
- **FR-008**: The system MUST ensure that integration credentials for AI providers are kept secure and never exposed to the user interface.
- **FR-009**: The system MUST implement a recommendation validation layer that validates every AI recommendation before returning it, rejecting recommendations that are incompatible with the investor profile, unsafe portfolio concentrations, or unsupported investment advice, and automatically appends mandatory financial disclaimers.
- **FR-010**: The feature MUST be restricted to authenticated users only.
- **FR-011**: The system MUST implement a resilient parsing layer that extracts JSON from mixed text responses, removes Markdown formatting, validates response schemas, and recovers from malformed JSON whenever possible (returning a safe fallback when parsing fails).
- **FR-012**: The system MUST cache generated portfolio summaries and only regenerate them when the underlying portfolio data changes.

### Key Entities

- **Chat Session**: Represents an active conversation between the user and the assistant, containing the message history.
- **AI Context**: An aggregated data structure containing the user's profile, goals, risk tolerance, and current investments.
- **Proactive Insight**: A system-generated recommendation or alert based on automated portfolio analysis.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: 100% of integration credentials are restricted to secure core services, passing security audits.
- **SC-002**: Users can expand, collapse, and interact with the chat panel on any main application screen without navigating away from their current view.
- **SC-003**: Context assembly must successfully complete in under 1 second.
- **SC-004**: AI response processing must begin displaying to the user in under 2 seconds.
- **SC-005**: System architecture supports future extensibility for real-time market data and valuation integrations by designing the backend interaction layer to support native LLM tool/function calling.

## Assumptions

- Users have a stable internet connection capable of supporting progressive responses.
- An investor profile is already generated and available in the database from a previous onboarding flow.
- The external AI provider supports generating responses progressively and contextual prompting.
- The existing authentication system will be used to secure access to the chat core capabilities.
