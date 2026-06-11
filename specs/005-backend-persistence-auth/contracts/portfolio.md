# API Contract: Portfolios

All portfolio endpoints are protected and require a valid JWT token in the `Authorization: Bearer <token>` header.

---

## 1. Create Portfolio

- **URL**: `/portfolios`
- **Method**: `POST`
- **Auth Guard**: JWT Auth Guard

### Request Payload
```json
{
  "name": "My Growth Assets",
  "description": "Long-term stock holdings"
}
```

### Success Response
- **Status**: `201 Created`
- **Payload**:
```json
{
  "id": "e0a29c15-0810-4aa5-a45c-15a0cbbd130a",
  "name": "My Growth Assets",
  "description": "Long-term stock holdings",
  "userId": "a90b4d45-6677-4950-ba35-9f6f467c67aa",
  "createdAt": "2026-06-10T16:05:00.000Z",
  "updatedAt": "2026-06-10T16:05:00.000Z"
}
```

### Error Responses
- **Status**: `400 Bad Request` (Validation errors, missing fields)
- **Status**: `409 Conflict` (Portfolio name already exists for this user)

---

## 2. List Portfolios

Retrieves all portfolios belonging to the authenticated user.

- **URL**: `/portfolios`
- **Method**: `GET`
- **Auth Guard**: JWT Auth Guard

### Success Response
- **Status**: `200 OK`
- **Payload**:
```json
[
  {
    "id": "e0a29c15-0810-4aa5-a45c-15a0cbbd130a",
    "name": "My Growth Assets",
    "description": "Long-term stock holdings",
    "createdAt": "2026-06-10T16:05:00.000Z",
    "updatedAt": "2026-06-10T16:05:00.000Z"
  }
]
```

---

## 3. Get Portfolio by ID

- **URL**: `/portfolios/:id`
- **Method**: `GET`
- **Auth Guard**: JWT Auth Guard, Ownership Guard

### Success Response
- **Status**: `200 OK`
- **Payload**:
```json
{
  "id": "e0a29c15-0810-4aa5-a45c-15a0cbbd130a",
  "name": "My Growth Assets",
  "description": "Long-term stock holdings",
  "investments": [],
  "createdAt": "2026-06-10T16:05:00.000Z",
  "updatedAt": "2026-06-10T16:05:00.000Z"
}
```

### Error Responses
- **Status**: `403 Forbidden` (User does not own this portfolio)
- **Status**: `404 Not Found` (Portfolio does not exist)

---

## 4. Update Portfolio

- **URL**: `/portfolios/:id`
- **Method**: `PUT`
- **Auth Guard**: JWT Auth Guard, Ownership Guard

### Request Payload
```json
{
  "name": "My Growth Assets Updated",
  "description": "Updated description"
}
```

### Success Response
- **Status**: `200 OK`
- **Payload**:
```json
{
  "id": "e0a29c15-0810-4aa5-a45c-15a0cbbd130a",
  "name": "My Growth Assets Updated",
  "description": "Updated description",
  "userId": "a90b4d45-6677-4950-ba35-9f6f467c67aa",
  "createdAt": "2026-06-10T16:05:00.000Z",
  "updatedAt": "2026-06-10T16:10:00.000Z"
}
```

---

## 5. Delete Portfolio

- **URL**: `/portfolios/:id`
- **Method**: `DELETE`
- **Auth Guard**: JWT Auth Guard, Ownership Guard

### Success Response
- **Status**: `204 No Content`
