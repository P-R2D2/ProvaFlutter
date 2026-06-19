import { Test, TestingModule } from '@nestjs/testing';
import { AIResponseParser } from '../src/modules/advisor/services/ai-response-parser.service';
import { RecommendationValidationService, AIRecommendation } from '../src/modules/advisor/services/recommendation-validation.service';

describe('AI Parsing and Validation Pipeline', () => {
  let parser: AIResponseParser;
  let validator: RecommendationValidationService;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [AIResponseParser, RecommendationValidationService],
    }).compile();

    parser = module.get<AIResponseParser>(AIResponseParser);
    validator = module.get<RecommendationValidationService>(RecommendationValidationService);
  });

  it('should extract JSON correctly from raw LLM output with markdown', () => {
    const rawOutput = "Here is my advice: \n```json\n{\n  \"message\": \"Invest in bonds\",\n  \"suggestedAllocations\": {\"bonds\": 100}\n}\n```";
    const result = parser.parseAndValidate<AIRecommendation>(rawOutput, ['message']);
    
    expect(result.message).toBe("Invest in bonds");
    expect(result.suggestedAllocations?.bonds).toBe(100);
  });

  it('should fallback securely when JSON is broken', () => {
    const rawOutput = "Here is my advice: \n```json\n{\n  \"message\": \"Invest in bonds\" \n";
    const result = parser.parseAndValidate<AIRecommendation>(rawOutput, ['message']);
    
    expect(result.isSafe).toBe(true);
    expect(result.message).toContain('unable to provide');
  });

  it('validator should reject highly concentrated recommendations', () => {
    const rec: AIRecommendation = {
      message: "Go all in on TSLA",
      suggestedAllocations: { "TSLA": 100 }
    };

    const validated = validator.validate(rec, 'Agressivo');
    expect(validated.isSafe).toBe(false);
    expect(validated.message).toContain('safety');
  });
});
