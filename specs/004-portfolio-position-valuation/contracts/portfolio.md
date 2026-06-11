# API Contract: Portfolio Position Valuation

This document defines the REST endpoints exposed by the backend and consumed by the Flutter client.

**Base Path**: `/api/investments`  
**Authentication**: Required (JWT Bearer Token in `Authorization` header).

---

## 1. Register or Update Asset Position
Allows users to add a new B3 position to their portfolio or modify an existing one.

- **Method**: `POST`
- **Path**: `/api/investments`
- **Headers**:
  ```http
  Authorization: Bearer <token>
  Content-Type: application/json
  ```
- **Request Body**:
  ```json
  {
    "symbol": "PETR4",
    "quantity": 10.0,
    "averagePurchasePrice": 30.0
  }
  ```
- **Response**: `201 Created`
  ```json
  {
    "id": "a3b4c5d6-e7f8-90a1-b2c3-d4e5f6a7b8c9",
    "symbol": "PETR4",
    "quantity": 10.0,
    "averagePurchasePrice": 30.0,
    "createdAt": "2026-05-29T22:00:00.000Z",
    "updatedAt": "2026-05-29T22:00:00.000Z"
  }
  ```
- **Error Responses**:
  - `400 Bad Request` (Invalid payload, negative quantity/price, missing symbol).
  - `401 Unauthorized` (Invalid/expired token).
  - `404 Not Found` (Symbol ticker not found on Brapi pricing service).

---

## 2. Get Portfolio Valuation & Summary
Retrieves the user's consolidated investment portfolio with real-time valuations.

- **Method**: `GET`
- **Path**: `/api/investments`
- **Headers**:
  ```http
  Authorization: Bearer <token>
  ```
- **Response**: `200 OK`
  ```json
  {
    "summary": {
      "totalInvested": 300.00,
      "totalCurrentValue": 350.00,
      "totalProfitLoss": 50.00,
      "totalReturnPercentage": 16.67,
      "isDelayed": false
    },
    "positions": [
      {
        "id": "a3b4c5d6-e7f8-90a1-b2c3-d4e5f6a7b8c9",
        "symbol": "PETR4",
        "name": "Petroleo Brasileiro S.A. - Petrobras",
        "quantity": 10.00,
        "averagePurchasePrice": 30.00,
        "currentMarketPrice": 35.00,
        "investedAmount": 300.00,
        "currentPositionValue": 350.00,
        "profitLoss": 50.00,
        "profitLossPercentage": 16.67,
        "isDelayed": false
      }
    ]
  }
  ```
- **Error Responses**:
  - `401 Unauthorized` (Missing or invalid bearer token).

---

## 3. Delete Asset Position
Closes and completely deletes a position from the user's tracking list.

- **Method**: `DELETE`
- **Path**: `/api/investments/:id`
- **Headers**:
  ```http
  Authorization: Bearer <token>
  ```
- **Response**: `200 OK`
  ```json
  {
    "success": true,
    "message": "Position successfully removed"
  }
  ```
- **Error Responses**:
  - `401 Unauthorized` (Invalid/expired token).
  - `404 Not Found` (Position ID does not belong to the authenticated user or does not exist).
