# Quickstart: NestJS Backend Authentication

## Running the Backend

1. **Navigate to the backend directory** (assuming it's created under `backend/` relative to the workspace root):
   ```bash
   cd backend
   ```

2. **Install dependencies**:
   ```bash
   npm install
   ```

3. **Set Environment Variables**:
   Create a `.env` file in the `backend/` directory:
   ```env
   JWT_SECRET=your_super_secret_jwt_key
   JWT_EXPIRATION=15m
   PORT=3000
   ```

4. **Start the development server**:
   ```bash
   npm run start:dev
   ```

## Testing the Flow

1. **Register a User**:
   ```bash
   curl -X POST http://localhost:3000/auth/register \
     -H "Content-Type: application/json" \
     -d '{"email": "test@example.com", "password": "Password123!"}'
   ```

2. **Login**:
   ```bash
   curl -X POST http://localhost:3000/auth/login \
     -H "Content-Type: application/json" \
     -d '{"email": "test@example.com", "password": "Password123!"}'
   ```
   *Copy the `accessToken` from the response.*

3. **Access a Protected Route** (if you create a test route later):
   ```bash
   curl -X GET http://localhost:3000/some-protected-route \
     -H "Authorization: Bearer <your_access_token>"
   ```
