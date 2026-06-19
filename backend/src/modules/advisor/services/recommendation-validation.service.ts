import { Injectable, Logger } from '@nestjs/common';

export interface AIRecommendation {
  message: string;
  suggestedAllocations?: Record<string, number>;
  tickers?: string[];
  isSafe?: boolean;
}

@Injectable()
export class RecommendationValidationService {
  private readonly logger = new Logger(RecommendationValidationService.name);
  
  private readonly STANDARD_DISCLAIMER = "\n\n*Disclaimer: This is AI-generated guidance and does not constitute professional financial advice. Investments carry risk. Please perform your own due diligence or consult a certified advisor.*";

  validateProfileCompatibility(recommendation: AIRecommendation, userProfile: string | null): boolean {
    if (!userProfile) return false; // Fail safe if no profile exists
    
    const profile = userProfile.toLowerCase();
    const messageLower = recommendation.message.toLowerCase();
    
    // Heuristic: Conservative shouldn't get highly volatile asset pushes
    const mentionsHighRisk = messageLower.includes('crypto') || messageLower.includes('bitcoin') || messageLower.includes('options trading');
    
    if (profile === 'conservador' && mentionsHighRisk) {
      this.logger.warn('Rejected: High risk assets recommended to conservative profile.');
      return false;
    }
    return true;
  }

  validateDiversification(recommendation: AIRecommendation): boolean {
    if (!recommendation.suggestedAllocations) return true; // Nothing to check
    
    // Reject if any single allocation is over 50% (unsafe concentration)
    for (const [asset, percentage] of Object.entries(recommendation.suggestedAllocations)) {
      if (percentage > 50) {
        this.logger.warn(`Rejected: Unsafe concentration in ${asset} (${percentage}%).`);
        return false;
      }
    }
    return true;
  }

  validate(recommendation: AIRecommendation, userProfile: string | null): AIRecommendation {
    if (recommendation.isSafe === false) {
       return recommendation; // Return fallback as is
    }

    const isProfileValid = this.validateProfileCompatibility(recommendation, userProfile);
    const isDiversified = this.validateDiversification(recommendation);

    if (!isProfileValid || !isDiversified) {
      return {
        message: 'The generated recommendation did not pass our safety and profile compatibility checks. Please adjust your prompt or contact a human advisor.',
        isSafe: false,
      };
    }

    // Append disclaimer
    if (!recommendation.message.includes('Disclaimer')) {
      recommendation.message += this.STANDARD_DISCLAIMER;
    }
    
    return recommendation;
  }
}
