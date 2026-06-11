# API Contract: Authentication

## 1. User Registration

Creates a new user account in the system.

- **URL**: `/auth/register`
- **Method**: `POST`
- **Headers**:
  - `Content-Type: application/json`
- **Auth Guard**: None (Public)

### Request Payload
```json
{
  "email": "user@example.com",
  "password": "SecurePassword123!"
}
```

### Success Response
- **Status**: `201 Created`
- **Payload**:
```json
{
  "id": "a90b4d45-6677-4950-ba35-9f6f467c67aa",
  "email": "user@example.com",
  "createdAt": "2026-06-10T16:00:00.000Z"
}
```

### Error Responses
- **Status**: `400 Bad Request` (Invalid email format, password too weak)
- **Status**: `409 Conflict` (Email already registered)

---

## 2. User Login

Authenticates user credentials and returns a secure session access token.

- **URL**: `/auth/login`
- **Method**: `POST`
- **Headers**:
  - `Content-Type: application/json`
- **Auth Guard**: None (Public)

### Request Payload
```json
{
  "email": "user@example.com",
  "password": "SecurePassword123!"
}
```

### Success Response
- **Status**: `200 OK`
- **Payload**:
```json
{
  "accessToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJhOTBiNGQ0NS02Njc3LTQ5NTAtYmEzNS05ZjZmNDY3YzY3YWEiLCJlbWFpbCI6InVzZXJAZXhhbXBsZS5jb20iLCJpYXQiOjE3NDk2NTc2MDAsImV4cCI6MTc0OTcwMDgwMH0.signature"
}
```

### Error Responses
- **Status**: `401 Unauthorized` (Incorrect email or password)
