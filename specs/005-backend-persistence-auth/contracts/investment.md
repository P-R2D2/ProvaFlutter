# API Contract: Investments

All investment endpoints are protected and require a valid JWT token in the `Authorization: Bearer <token>` header, along with ownership verification on the parent portfolio.

---

## 1. Add Investment to Portfolio

- **URL**: `/portfolios/:portfolioId/investments`
- **Method**: `POST`
- **Auth Guard**: JWT Auth Guard, Ownership Guard (validating ownership of `:portfolioId`)

### Request Payload
```json
{
  "assetSymbol": "PETR4",
  "assetName": "Petróleo Brasileiro S.A.",
  "quantity": 100,
  "averagePurchasePrice": 35.50
}
```

### Success Response
- **Status**: `201 Created`
- **Payload**:
```json
{
  "id": "f5b39d15-0810-4aa5-a45c-15a0cbbd130a",
  "assetSymbol": "PETR4",
  "assetName": "Petróleo Brasileiro S.A.",
  "quantity": 100,
  "averagePurchasePrice": "35.50",
  "portfolioId": "e0a29c15-0810-4aa5-a45c-15a0cbbd130a",
  "createdAt": "2026-06-10T16:15:00.000Z",
  "updatedAt": "2026-06-10T16:15:00.000Z"
}
```

### Error Responses
- **Status**: `400 Bad Request` (Invalid payload: negative quantity/price, empty strings)
- **Status**: `403 Forbidden` (User does not own the parent portfolio)

---

## 2. List Investments in Portfolio

- **URL**: `/portfolios/:portfolioId/investments`
- **Method**: `GET`
- **Auth Guard**: JWT Guard, Ownership Guard (validating ownership of `:portfolioId`)

### Success Response
- **Status**: `200 OK`
- **Payload**:
```json
[
  {
    "id": "f5b39d15-0810-4aa5-a45c-15a0cbbd130a",
    "assetSymbol": "PETR4",
    "assetName": "Petróleo Brasileiro S.A.",
    "quantity": 100,
    "averagePurchasePrice": "35.50",
    "createdAt": "2026-06-10T16:15:00.000Z",
    "updatedAt": "2026-06-10T16:15:00.000Z"
  }
]
```

---

## 3. Update Investment

Updates an existing investment transaction. Note: this route has the investment ID in params. Ownership is verified against the owner of the portfolio that holds the investment.

- **URL**: `/investments/:id`
- **Method**: `PUT`
- **Auth Guard**: JWT Guard, Ownership Guard (resolving ownership of the investment)

### Request Payload
```json
{
  "quantity": 120,
  "averagePurchasePrice": 34.00
}
```

### Success Response
- **Status**: `200 OK`
- **Payload**:
```json
{
  "id": "f5b39d15-0810-4aa5-a45c-15a0cbbd130a",
  "assetSymbol": "PETR4",
  "assetName": "Petróleo Brasileiro S.A.",
  "quantity": 120,
  "averagePurchasePrice": "34.00",
  "portfolioId": "e0a29c15-0810-4aa5-a45c-15a0cbbd130a",
  "createdAt": "2026-06-10T16:15:00.000Z",
  "updatedAt": "2026-06-10T16:20:00.000Z"
}
```

---

## 4. Delete Investment

- **URL**: `/investments/:id`
- **Method**: `DELETE`
- **Auth Guard**: JWT Guard, Ownership Guard (resolving ownership of the investment)

### Success Response
- **Status**: `204 No Content`
