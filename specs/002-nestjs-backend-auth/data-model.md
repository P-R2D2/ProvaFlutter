# Data Model: NestJS Backend Authentication

## Entities

### User
Represents a registered user in the system.

**Attributes:**
- `id`: string (UUID, generated upon creation)
- `email`: string (Must be unique across all users)
- `passwordHash`: string (bcrypt hash of the user's password)
- `refreshToken`: string | null (Stores the currently active refresh token for the user. Set to null upon logout.)

**Validation Rules:**
- `email`: Valid email format.
- `password`: Must meet strict validation during creation/update (not stored).

### AuthToken
Represents the credentials returned to the client upon successful authentication.

**Attributes:**
- `accessToken`: string (Short-lived JWT, e.g., 15m)
- `refreshToken`: string (Long-lived opaque token, e.g., UUID)
