import { Module } from '@nestjs/common';
import { AdvisorController } from './controllers/advisor.controller';
import { ConversationService } from './services/conversation.service';
import { AIResponseParser } from './services/ai-response-parser.service';
import { RecommendationValidationService } from './services/recommendation-validation.service';
import { PortfolioSummaryService } from './services/portfolio-summary.service';
import { PromptOptimizerService } from './services/prompt-optimizer.service';
import { PromptBuilderService } from './services/prompt-builder.service';
import { AIIntegrationService } from './services/ai-integration.service';
import { ProactiveInsightsService } from './services/proactive-insights.service';
import { ScheduleModule } from '@nestjs/schedule';

@Module({
  imports: [ScheduleModule.forRoot()],
  controllers: [AdvisorController],
  providers: [
    ConversationService,
    AIResponseParser,
    RecommendationValidationService,
    PortfolioSummaryService,
    PromptOptimizerService,
    PromptBuilderService,
    AIIntegrationService,
    ProactiveInsightsService,
  ],
  exports: [ConversationService],
})
export class AdvisorModule {}
