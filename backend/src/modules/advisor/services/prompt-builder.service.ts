import { Injectable } from '@nestjs/common';
import { PrismaClient } from '@prisma/client';
import { PortfolioSummaryService } from './portfolio-summary.service';
import { PromptOptimizerService } from './prompt-optimizer.service';

@Injectable()
export class PromptBuilderService {
  private prisma = new PrismaClient();

  constructor(
    private portfolioSummaryService: PortfolioSummaryService,
    private promptOptimizerService: PromptOptimizerService
  ) {}

  async buildSystemInstruction(userId: string): Promise<string> {
    const user = await this.prisma.user.findUnique({
      where: { id: userId }
    });

    const summary = await this.portfolioSummaryService.generateSummary(userId);
    const optimizedContext = this.promptOptimizerService.optimizeContext(summary, user?.perfilInvestidor || null);

    return `You are an Intelligent Investment Advisor. You provide financial guidance to users based on their portfolio and risk profile.
You MUST output your recommendations in JSON format if the user asks for specific asset allocations, or provide plain text markdown for general questions.

Here is the current user context:
${optimizedContext}

Always adhere to safe investment guidelines. Never guarantee returns.`;
  }
}
