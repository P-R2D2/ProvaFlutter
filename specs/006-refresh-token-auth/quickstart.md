# Quickstart: Refresh Token Authentication Flow

## 1. Backend Setup

### Environment Variables
Update the `backend/.env` file with separate secrets and expirations if desired:
```env
JWT_SECRET=super_secret_access_key
JWT_REFRESH_SECRET=super_secret_refresh_key
```

### Database Migration
After making schema changes, run the Prisma migration command to apply the changes to PostgreSQL:
```bash
npx prisma migrate dev --name add_user_refresh_token_hash
```

---

## 2. Frontend Setup

### Add Dependencies
Add `flutter_secure_storage` to your `pubspec.yaml`:
```yaml
dependencies:
  flutter_secure_storage: ^9.2.2
```

Then run:
```bash
flutter pub get
```

### Authenticated HTTP Client Usage
Replace direct `http.Client` dependency injection with `AuthenticatedHttpClient`.
```dart
final client = AuthenticatedHttpClient(
  authProvider: context.read<AuthProvider>(),
);
```
All repository/datasource calls will automatically be intercepted, authenticated, refreshed, and retries will happen transparently.
