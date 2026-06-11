# Data Model: Refresh Token Authentication Flow

## Database Schema Changes (Prisma)

We will update the `User` model in the Prisma schema to store the cryptographically hashed refresh token:

```prisma
model User {
  id               String      @id @default(uuid())
  email            String      @unique
  passwordHash     String
  refreshTokenHash String?     // Added to store the bcrypt hash of the active refresh token
  createdAt        DateTime    @default(now())
  updatedAt        DateTime    @updatedAt
  portfolios       Portfolio[]

  @@map("users")
}
```

### Constraints & Lifecycle
- **Uniqueness**: Only one active refresh token hash can exist per user at any time (supporting a single active session).
- **Nullability**: `refreshTokenHash` is nullable. When a user logs out or is revoked due to a replay attack, `refreshTokenHash` is set to `null`.
- **Token Rotation**: On successful refresh, the old hash is replaced with the new hash.
