import { Injectable, Logger } from '@nestjs/common';

@Injectable()
export class AIResponseParser {
  private readonly logger = new Logger(AIResponseParser.name);

  extractJson(text: string): string | null {
    try {
      const start = text.indexOf('{');
      const end = text.lastIndexOf('}');
      if (start === -1 || end === -1 || end < start) {
        return null;
      }
      return text.substring(start, end + 1);
    } catch (e) {
      this.logger.error('Failed to extract JSON', e);
      return null;
    }
  }

  cleanMarkdown(text: string): string {
    return text.replace(/```(json)?/gi, '').trim();
  }

  validateSchema<T>(jsonStr: string, schemaKeys: string[]): T | null {
    try {
      const parsed = JSON.parse(jsonStr);
      for (const key of schemaKeys) {
        if (parsed[key] === undefined) {
          this.logger.warn(`Missing key in JSON schema: ${key}`);
          return null;
        }
      }
      return parsed as T;
    } catch (e) {
      this.logger.error('JSON Parse error', e);
      return null;
    }
  }

  getSafeFallback(context: string): any {
    return {
      message: 'I am currently unable to provide a detailed recommendation based on your prompt. However, diversifying your portfolio and matching your risk profile remains the best course of action. Please consult a financial professional for personalized advice.',
      isSafe: true,
      context: context
    };
  }

  parseAndValidate<T>(rawResponse: string, schemaKeys: string[]): T {
    let cleanText = this.cleanMarkdown(rawResponse);
    let jsonStr = this.extractJson(cleanText);

    if (!jsonStr) {
      if (schemaKeys.length === 0) {
        return rawResponse as unknown as T;
      }
      this.logger.warn('Failed to extract JSON. Falling back.');
      return this.getSafeFallback('Extraction failed');
    }

    const validated = this.validateSchema<T>(jsonStr, schemaKeys);
    if (!validated) {
      this.logger.warn('Schema validation failed. Falling back.');
      return this.getSafeFallback('Validation failed');
    }

    return validated;
  }
}
