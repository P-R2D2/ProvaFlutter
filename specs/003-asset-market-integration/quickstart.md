# Quickstart: Asset Market Integration

**Feature**: Asset Market Integration  
**Date**: 2026-05-30  
**Status**: Approved

This guide outlines how to run, configure, and verify the Asset Market Integration feature in development.

---

## 1. Backend Setup & Configuration (NestJS)

### 1.1 Install Dependencies
Navigate to the `backend` folder and install axios and cache manager libraries:
```bash
cd backend
npm install @nestjs/axios axios @nestjs/cache-manager cache-manager
```

### 1.2 Configure Environment Variables
Add your Brapi token to the backend `.env` file (or set it in your terminal session):
```env
BRAPI_API_TOKEN=your_real_brapi_api_token_here
```
*Note: In local development, the service falls back to mock responses if no token is configured, preventing local failures.*

### 1.3 Start Backend Dev Server
```bash
npm run start:dev
```

---

## 2. Frontend Setup & Configuration (Flutter)

### 2.1 Install Dependencies
Navigate to the `investment_agenda` directory and install the shimmer library:
```bash
cd investment_agenda
flutter pub add shimmer
```

### 2.2 Run Mobile Application
```bash
flutter run
```

---

## 3. Verification Guide

### 3.1 Verify Backend Endpoints
You can check that the proxy gateway is working correctly via `curl` or Postman:

#### Test Search API:
```bash
curl -H "Authorization: Bearer <YOUR_JWT_TOKEN>" "http://localhost:3000/api/assets/search?query=PETR4"
```

#### Test Details API:
```bash
curl -H "Authorization: Bearer <YOUR_JWT_TOKEN>" "http://localhost:3000/api/assets/details/PETR4"
```

### 3.2 Verify Frontend UI
1. Navigate to the newly implemented **Market** or **Search** icon on the bottom navigation.
2. In the input box, type `VALE3`.
3. Verify that the **shimmer loading skeleton** list displays.
4. Verify that the matching asset displays `VALE S.A.` in the list.
5. Tap the asset list card.
6. Verify that a beautiful details page is pushed, showing high/low boundaries, price changes, and currency fields.
