# REST API Contracts: Asset Market Integration

**Feature**: Asset Market Integration  
**Date**: 2026-05-30  
**Status**: Approved

This document defines the API interface contracts between the Flutter mobile client and the NestJS backend API Gateway.

---

## 1. Authentication
All endpoints require a Bearer token in the `Authorization` header, leveraging the existing JWT auth system.

```http
Authorization: Bearer <JWT_TOKEN>
```

---

## 2. Search Assets

Finds market assets matching the search query by ticker symbol or company name.

- **URL**: `/api/assets/search`
- **Method**: `GET`
- **Query Parameters**:
  - `query` (String, required): The search text (e.g. `PETR4` or `Itau`). Minimum 1 character.

### Request Example
```http
GET /api/assets/search?query=VALE3 HTTP/1.1
Host: localhost:3000
Authorization: Bearer <JWT_TOKEN>
```

### Response Success (200 OK)
Returns an array of matching assets.
```json
[
  {
    "symbol": "VALE3",
    "name": "VALE S.A."
  }
]
```

### Response Empty (200 OK)
```json
[]
```

### Response Error - Unauthorized (401 Unauthorized)
```json
{
  "statusCode": 401,
  "message": "Unauthorized"
}
```

### Response Error - Missing/Invalid Parameters (400 Bad Request)
```json
{
  "statusCode": 400,
  "message": [
    "query must be longer than or equal to 1 characters"
  ],
  "error": "Bad Request"
}
```

---

## 3. Retrieve Asset Details

Retrieves full normalized market metrics and current price for a specific ticker symbol.

- **URL**: `/api/assets/details/:ticker`
- **Method**: `GET`
- **Path Parameters**:
  - `ticker` (String, required): The exact asset symbol/ticker (e.g., `PETR4`).

### Request Example
```http
GET /api/assets/details/PETR4 HTTP/1.1
Host: localhost:3000
Authorization: Bearer <JWT_TOKEN>
```

### Response Success (200 OK)
```json
{
  "symbol": "PETR4",
  "name": "Petroleo Brasileiro S.A. - Petrobras",
  "currentPrice": 38.50,
  "dayHigh": 39.10,
  "dayLow": 38.10,
  "changePercent": 1.25,
  "currency": "BRL",
  "updatedAt": "2026-05-30T10:30:00.000Z"
}
```

### Response Error - Asset Not Found (404 Not Found)
```json
{
  "statusCode": 404,
  "message": "Asset with ticker 'PETR4XX' not found",
  "error": "Not Found",
  "retryable": false
}
```

### Response Error - External Rate Limit (429 Too Many Requests)
```json
{
  "statusCode": 429,
  "message": "External market service rate-limit reached. Please try again later.",
  "error": "Too Many Requests",
  "retryable": true
}
```

### Response Error - External Outage (503 Service Unavailable)
```json
{
  "statusCode": 503,
  "message": "Market pricing service is currently offline. Please try again later.",
  "error": "Service Unavailable",
  "retryable": true
}
```
