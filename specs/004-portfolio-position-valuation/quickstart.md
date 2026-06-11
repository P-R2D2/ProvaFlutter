# Quickstart: Portfolio Position Valuation Verification

Follow this guide to spin up the local development servers, run tests, and manually verify the portfolio position valuation features.

## 1. Prerequisites & Environment Setup

Verify the `backend/.env` file contains your Brapi API token, or leave it empty/default to run using the built-in sandbox mock data.

```bash
# Verify backend environment
cd backend
cat .env
```

---

## 2. Running Backend Tests & Server

Compile and run the NestJS unit tests to ensure existing integrations remain unbroken:

```bash
# Run NestJS unit tests
npm run test
```

Start the NestJS backend development server:

```bash
# Start backend server
npm run start:dev
```
*The server will start on port `3000` (base endpoint `http://localhost:3000`).*

---

## 3. Running Frontend Tests & App

Navigate to the Flutter project folder, check dependency synchronization, and execute the automated widget and unit tests:

```bash
cd investment_agenda
flutter pub get
flutter test
```

To run the Flutter client in your preferred target platform emulator or browser:

```bash
flutter run
```

---

## 4. Manual Verification Flow

1. **Register User**: Go to register screen on the Flutter app and create an account (e.g. `test@example.com` / `Password123!`).
2. **Log In**: Authenticate using your new credentials.
3. **Add Asset Position**:
   - Tap the "+" or search bar, select `PETR4` or `VALE3`.
   - Enter Quantity = `10` and Average Price = `30.00`.
   - Tap "Confirm/Save".
4. **Inspect Dashboard**:
   - Check individual stock card displaying Current Price, Invested, Value, and exact color-coded Returns (green for profit, red for loss).
   - Check top consolidated "Portfolio Summary" card (e.g., Total Invested: R$ 300,00, Current Value, Profit/Loss, and Return %).
