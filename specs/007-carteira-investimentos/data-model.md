# Data Model: Carteira de Investimentos

## Backend Schema (Prisma)

```prisma
model Portfolio {
  id          String       @id @default(uuid())
  name        String       // e.g., "Aposentadoria", "Reserva de Emergência"
  userId      String       // FK to User
  user        User         @relation(fields: [userId], references: [id])
  investments Investment[]
  createdAt   DateTime     @default(now())
  updatedAt   DateTime     @updatedAt

  @@map("portfolios")
}

model Investment {
  id            String    @id @default(uuid())
  name          String    // e.g., "Tesouro IPCA+ 2045", "PETR4"
  assetType     String    // e.g., "FIXED_INCOME", "STOCK", "CRYPTO"
  quantity      Float     // Support for fractional shares
  purchasePrice Float     // Unitary price at purchase
  purchaseDate  DateTime
  portfolioId   String    // FK to Portfolio
  portfolio     Portfolio @relation(fields: [portfolioId], references: [id])
  createdAt     DateTime  @default(now())
  updatedAt     DateTime  @updatedAt

  @@map("investments")
}
```

*Note: The existing `User` model must be updated to include `portfolios Portfolio[]`.*

## Frontend Entities (Dart)

```dart
class PortfolioEntity {
  final String id;
  final String name;
  final String userId;
  final List<InvestmentEntity> investments;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Constructor, fromJson, toJson omitted for brevity
}

enum AssetType {
  fixedIncome,
  stock,
  crypto,
  other
}

class InvestmentEntity {
  final String id;
  final String name;
  final AssetType assetType;
  final double quantity;
  final double purchasePrice;
  final DateTime purchaseDate;
  final String portfolioId;

  // Constructor, fromJson, toJson omitted for brevity
}
```

## Validation Rules

- **Portfolio Name**: Max 50 characters, must not be empty.
- **Investment Name**: Max 100 characters, must not be empty.
- **Quantity**: Must be > 0.
- **Purchase Price**: Must be >= 0.
- **Purchase Date**: Cannot be a future date (must be <= today).
