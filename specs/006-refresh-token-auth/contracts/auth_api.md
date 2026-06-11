# API Contracts: Authentication Endpoints

## 1. POST /auth/login

Authenticates a user and returns a token pair.

- **Request Body**:
  ```json
  {
    "email": "user@example.com",
    "password": "password123"
  }
  ```

- **Response (200 OK)**:
  ```json
  {
    "accessToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "refreshToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
  }
  ```

---

## 2. POST /auth/refresh

Obtains a new access token and refresh token pair using an existing valid refresh token.

- **Request Body**:
  ```json
  {
    "refreshToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
  }
  ```

- **Response (200 OK)**:
  ```json
  {
    "accessToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "refreshToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
  }
  ```

- **Response (401 Unauthorized)**:
  - Triggered if the refresh token is expired, invalid, or has been revoked (e.g. rotated previously).
  ```json
  {
    "statusCode": 401,
    "message": "Invalid or expired refresh token",
    "error": "Unauthorized"
  }
  ```

---

## 3. POST /auth/logout

Invalidates the active refresh token and logs out the user.

- **Headers**:
  - `Authorization: Bearer <accessToken>`

- **Response (200 OK)**:
  - Clears `refreshTokenHash` on the database.
  ```json
  {
    "success": true
  }
  ```
