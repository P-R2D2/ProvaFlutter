import { Injectable, Logger } from '@nestjs/common';
import { Cron, CronExpression } from '@nestjs/schedule';

@Injectable()
export class ProactiveInsightsService {
  private readonly logger = new Logger(ProactiveInsightsService.name);

  // Example cron job to generate proactive insights
  @Cron(CronExpression.EVERY_DAY_AT_MIDNIGHT)
  async generateDailyInsights() {
    this.logger.debug('Running proactive insights generation job');
    // Implement insight generation logic here
  }
}
