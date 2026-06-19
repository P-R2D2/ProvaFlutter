# Quickstart: Intelligent Investment Advisor Chat

## Setup

1. **Backend Configuration**:
   Ensure your `.env` contains the required AI provider keys:
   ```env
   AI_PROVIDER_API_KEY=your-api-key
   ```
2. **Database Migration**:
   Run Prisma migrations to create the new `ChatSession`, `ChatMessage`, and `ProactiveInsight` tables:
   ```bash
   cd backend
   npx prisma migrate dev --name add_advisor_tables
   ```

## Local Testing

1. **Run Backend**: `npm run start:dev`
2. **Run App**: `flutter run`
3. **Verify Chat**: Authenticate, open the floating chat widget, and ask "How is my portfolio doing?"
4. **Test Proactive Insights**: Manually trigger the daily cron job endpoint or service method to verify batch evaluations.
