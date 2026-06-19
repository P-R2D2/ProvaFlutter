import { Injectable } from '@nestjs/common';
import { PortfolioSummary } from './portfolio-summary.service';

@Injectable()
export class PromptOptimizerService {
  
  optimizeContext(summary: PortfolioSummary | null, userProfile: string | null): string {
    let context = `User Profile: ${userProfile || 'Unknown'}\n`;
    
    if (!summary) {
       return context + "Portfolio: Empty\n";
    }

    context += `Portfolio Value: R$ ${summary.totalValue.toFixed(2)}\n`;
    context += `Diversification Score: ${summary.diversificationScore}/100\n`;
    
    context += 'Allocations: ';
    const allocStrs = Object.entries(summary.allocationByCategory)
      .map(([cat, pct]) => `${cat}(${pct}%)`);
    context += allocStrs.join(', ') + '\n';
    
    context += 'Top Positions: ';
    const posStrs = summary.largestPositions
      .map(p => `${p.name}(${p.percentage}%)`);
    context += posStrs.join(', ') + '\n';

    return context;
  }
}
