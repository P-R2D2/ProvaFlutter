# Data Model: Investment Entity

## Investment

| Field | Type | Description | Validation |
| :--- | :--- | :--- | :--- |
| `id` | String | Unique UUID v4 | Non-empty |
| `name` | String | Name of the investment | Min 1 char |
| `amountInvested` | Double | Principal amount | Must be > 0 |
| `monthlyReturn` | Double | Expected monthly return | Numeric |

## State Transitions
- **Creation**: Status set to active once saved.
- **Update**: `amountInvested` or `monthlyReturn` modification triggers "Total" recalculation.
- **Deletion**: Permanent removal from the in-memory list.
