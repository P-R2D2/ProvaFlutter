# Data Model: Intelligent Investment Advisor Chat

## Entities

### `ChatSession` (PostgreSQL via Prisma)
Represents a continuous conversational context for a user.
- `id` (UUID, PK)
- `userId` (UUID, FK to User)
- `createdAt` (DateTime)
- `updatedAt` (DateTime)
- `lastActive` (DateTime) - Used for the 30-day rolling window purge.

### `ChatMessage` (PostgreSQL via Prisma)
Represents individual messages within a session.
- `id` (UUID, PK)
- `sessionId` (UUID, FK to ChatSession)
- `role` (Enum: `USER`, `ASSISTANT`, `SYSTEM`)
- `content` (String)
- `createdAt` (DateTime)

### `ProactiveInsight` (PostgreSQL via Prisma)
Stores generated insights from the batch job.
- `id` (UUID, PK)
- `userId` (UUID, FK to User)
- `type` (Enum: `CONCENTRATION`, `DIVERSIFICATION`, `OPPORTUNITY`)
- `content` (String) - Markdown formatted recommendation.
- `isRead` (Boolean) - For UI notification dots.
- `createdAt` (DateTime)

## Validation Rules
- `ChatMessage.role` must be strictly typed.
- LLM outputs are validated heuristically before being saved as `ChatMessage` with `role=ASSISTANT` or as a `ProactiveInsight`.
