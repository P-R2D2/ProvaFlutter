# Data Model: Portfolio Position Valuation

This document defines the schema, validations, and relationships of the `Investment` domain entity and DTO data models.

## 1. Database Entity: `Investment`

Mapped via TypeORM to the `investments` table.

| Attribute | Type | DB Column | Constraints | Description |
| :--- | :--- | :--- | :--- | :--- |
| `id` | `string` | `id` (UUID) | Primary Key, Generated UUID | Unique position identifier |
| `userId` | `string` | `userId` (UUID) | Foreign Key -> `users.id` | Owner of this position |
| `symbol` | `string` | `symbol` (varchar) | Not Null, Uppercase | B3 Ticker Symbol (e.g. `PETR4`) |
| `quantity` | `number` | `quantity` (decimal/real) | Not Null, Positive | Number of units held |
| `averagePurchasePrice` | `number` | `averagePurchasePrice` (decimal) | Not Null, Positive | Cost basis per unit |
| `createdAt` | `Date` | `createdAt` (datetime) | Default: now() | Insertion timestamp |
| `updatedAt` | `Date` | `updatedAt` (datetime) | Default: now() | Last update timestamp |

### Relationships
- `User` has many `Investment` positions (`1:N`).

---

## 2. API Data Transfer Objects (DTOs)

### `RegisterPositionDto` (Request Body)
Used in `POST /api/investments` to add or update a position.

- `symbol`: `string`
  - Must be a valid non-empty string.
  - Automatically converted to uppercase.
- `quantity`: `number`
  - Must be a number greater than 0.
- `averagePurchasePrice`: `number`
  - Must be a number greater than 0.

### `PortfolioValuationDto` (Response Position Object)
Transient representation returned in list array.

- `id`: `string`
- `symbol`: `string`
- `name`: `string`
- `quantity`: `number` (2 decimal places)
- `averagePurchasePrice`: `number` (2 decimal places)
- `currentMarketPrice`: `number` (2 decimal places)
- `investedAmount`: `number` (2 decimal places)
- `currentPositionValue`: `number` (2 decimal places)
- `profitLoss`: `number` (signed, 2 decimal places)
- `profitLossPercentage`: `number` (signed, 2 decimal places)
- `isDelayed`: `boolean`

### `PortfolioSummaryDto` (Response Global Summary)
Transient container for global portfolio aggregates.

- `totalInvested`: `number` (2 decimal places)
- `totalCurrentValue`: `number` (2 decimal places)
- `totalProfitLoss`: `number` (signed, 2 decimal places)
- `totalReturnPercentage`: `number` (signed, 2 decimal places)
- `isDelayed`: `boolean`

---

## 3. Validation Rules

1. **Quantity Guard**: `quantity > 0`. Updates with quantity = 0 remove the position.
2. **Price Guard**: `averagePurchasePrice > 0`.
3. **Symbol Match**: Symbol is validated via search/details in `AssetsService`.
