import { Injectable, InternalServerErrorException, Logger } from '@nestjs/common';
import OpenAI from 'openai';

import { ConfigService } from '@nestjs/config';

export interface ChatMessageContext {
  role: 'user' | 'model' | 'system' | 'assistant';
  content: string;
}

@Injectable()
export class AIIntegrationService {
  private readonly logger = new Logger(AIIntegrationService.name);
  private openai: OpenAI;

  constructor(private configService: ConfigService) {
    const apiKey = this.configService.get<string>('OPENAI_API_KEY');
    if (!apiKey) {
      this.logger.warn('OPENAI_API_KEY not found in environment variables. AI features will fail.');
    }
    this.openai = new OpenAI({ apiKey: apiKey || 'missing-key' });
  }

  async generateResponse(systemInstruction: string, history: ChatMessageContext[], currentMessage: string): Promise<string> {
    try {
      const messages: any[] = [
        { role: 'system', content: systemInstruction },
        ...history.map((msg) => ({
          role: msg.role === 'model' ? 'assistant' : msg.role,
          content: msg.content,
        })),
        { role: 'user', content: currentMessage }
      ];

      const response = await this.openai.chat.completions.create({
        model: 'gpt-4o-mini',
        messages: messages,
      });

      return response.choices[0].message.content || '';
    } catch (error) {
      this.logger.error('Error calling AI Provider', error);
      throw new InternalServerErrorException('Failed to communicate with AI provider');
    }
  }

  async *generateResponseStream(systemInstruction: string, history: ChatMessageContext[], currentMessage: string): AsyncGenerator<string, void, unknown> {
    try {
      const messages: any[] = [
        { role: 'system', content: systemInstruction },
        ...history.map((msg) => ({
          role: msg.role === 'model' ? 'assistant' : msg.role,
          content: msg.content,
        })),
        { role: 'user', content: currentMessage }
      ];

      const stream = await this.openai.chat.completions.create({
        model: 'gpt-4o-mini',
        messages: messages,
        stream: true,
      });

      for await (const chunk of stream) {
        const chunkText = chunk.choices[0]?.delta?.content || '';
        if (chunkText) {
          yield chunkText;
        }
      }
    } catch (error: any) {
      this.logger.error('Error calling AI Provider stream: ' + (error.message || error));
      yield '\n\n**Desculpe, ocorreu um erro de comunicação com a IA.**\n';
      if (error.status === 401) {
         yield 'A chave da OpenAI fornecida é inválida ou expirou.';
      } else if (error.status === 429) {
         yield 'A cota da OpenAI foi excedida ou há muitos acessos (Erro 429).';
      } else {
         yield 'Verifique o console do backend para mais detalhes sobre o erro.';
      }
    }
  }
}
