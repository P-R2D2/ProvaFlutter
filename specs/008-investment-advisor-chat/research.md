# Research: Intelligent Investment Advisor Chat

## Technical Decisions

### LLM Integration Library
- **Decision**: Use official AI SDK in NestJS (e.g., `@google/generative-ai` or `openai`).
- **Rationale**: Provides native support for streaming, tool-calling (function calling), and easy configuration of safety settings and heuristics, aligning with SC-005.
- **Alternatives considered**: Direct REST HTTP calls (harder to manage streaming and tool execution seamlessly).

### Context Building and Token Management
- **Decision**: Pre-build an aggregated context string representing portfolios and profiles, combined with a rolling 30-day chat history from the DB.
- **Rationale**: Distinct but combined presentation of portfolios allows holistic LLM analysis. DB rolling window balances context utility with database optimization.
- **Alternatives considered**: Agentic workflow fetching portfolios dynamically (can be too slow for initial UX latency).

### Frontend Streaming Strategy
- **Decision**: Use Dart streams from a Flutter `Provider` to handle Server-Sent Events (SSE) from the NestJS backend.
- **Rationale**: Flutter's `StreamBuilder` and Provider integrate natively to render markdown text chunks as they arrive, fulfilling the <2s start time constraint.
- **Alternatives considered**: WebSockets (overkill since the communication is primarily request/stream-response).

### Proactive Insights Batch Job
- **Decision**: Use `@nestjs/schedule` for daily batch evaluation of portfolios.
- **Rationale**: Scheduled evaluations reduce API load and token usage compared to event-driven checks, fulfilling FR-006 efficiently.
- **Alternatives considered**: Event-driven on every investment add (can cause bursts of unnecessary API calls and rate limiting).

### LLM Parsing and Safety Validation
- **Decision**: Introduce explicit `AIResponseParser` and `RecommendationValidationService` layers.
- **Rationale**: Direct LLM output is inherently non-deterministic. A dedicated parsing layer ensures structured data integrity (extracting JSON/stripping markdown) and fallback capability. The validation layer enforces business constraints (disclaimers, profile matching) regardless of the AI provider's internal safety measures.
- **Alternatives considered**: Relying on AI provider's strict JSON mode (not universally supported and doesn't solve business constraint validation).

### Context Optimization and Caching
- **Decision**: Summarize portfolio data via `PortfolioSummaryService` and cache it, optimizing prompts via `PromptOptimizerService`.
- **Rationale**: Sending raw portfolio holdings for a power user can quickly exhaust token limits or increase latency. Caching the summary ensures the <1s context assembly constraint (SC-003) is met.
- **Alternatives considered**: Fetching and parsing raw DB entities on every prompt (fails latency checks and increases API costs).
