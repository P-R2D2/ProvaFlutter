# Research: NestJS Backend Authentication

## 1. Module Structure
- **Decision**: Two main modules: `AuthModule` and `UsersModule`. `AuthModule` imports `UsersModule` to validate credentials. Both modules reside in `backend/src/modules/`.
- **Rationale**: Follows NestJS Clean Architecture and modular design principles, isolating domain logic.
- **Alternatives considered**: Monolithic module (rejected to adhere to constitution).

## 2. Auth Flow & JWT Generation
- **Decision**: Stateless JWT implementation. Login returns an access token (15m expiry) and a refresh token. `@nestjs/jwt` and `@nestjs/passport` used for validating tokens.
- **Rationale**: Aligns with the clarified specification.
- **Alternatives considered**: Stateful sessions (rejected due to specification).

## 3. Password Hashing
- **Decision**: Use `bcrypt` with a cost factor of 10. Hashing happens in the `UsersService` before saving to the repository.
- **Rationale**: Standard best practice for Node.js backends. Met the clarification decision.

## 4. In-Memory Repository Structure
- **Decision**: Create `UserRepository` interface and `InMemoryUserRepository` implementation. Inject via custom providers in NestJS using symbols.
- **Rationale**: Abstracting persistence enables seamless future database integration as mandated by the constitution.

## 5. Route Protection
- **Decision**: Global `JwtAuthGuard` applied using `APP_GUARD`. Create `@Public()` decorator to bypass protection for `/auth/login` and `/auth/register`.
- **Rationale**: Secure by default architecture, preventing accidental exposure of new endpoints.

## 6. Validation Pipeline
- **Decision**: Use global `ValidationPipe` with `class-validator` and `class-transformer`. Define strict rules for password DTOs (min 8 chars, upper, lower, number, special char).
- **Rationale**: Met the clarification decision for strict validation.
