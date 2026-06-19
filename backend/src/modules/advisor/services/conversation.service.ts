import { Injectable, Logger } from '@nestjs/common';
import { PrismaClient } from '@prisma/client';
import { AIIntegrationService, ChatMessageContext } from './ai-integration.service';
import { PromptBuilderService } from './prompt-builder.service';
import { AIResponseParser } from './ai-response-parser.service';
import { RecommendationValidationService, AIRecommendation } from './recommendation-validation.service';
import { Observable } from 'rxjs';

@Injectable()
export class ConversationService {
  private readonly logger = new Logger(ConversationService.name);
  private prisma = new PrismaClient();

  constructor(
    private aiIntegrationService: AIIntegrationService,
    private promptBuilderService: PromptBuilderService,
    private aiResponseParser: AIResponseParser,
    private validationService: RecommendationValidationService
  ) {}

  async sendMessage(userId: string, sessionId: string | null, message: string) {
    let session = sessionId ? await this.prisma.chatSession.findUnique({ where: { id: sessionId }, include: { messages: true } }) : null;

    if (!session) {
      session = await this.prisma.chatSession.create({
        data: { userId },
        include: { messages: true }
      });
    }

    await this.prisma.chatMessage.create({
      data: {
        sessionId: session.id,
        role: 'USER',
        content: message
      }
    });

    const user = await this.prisma.user.findUnique({ where: { id: userId }});

    const systemInstruction = await this.promptBuilderService.buildSystemInstruction(userId);
    const history: ChatMessageContext[] = session.messages.map(m => ({
      role: m.role.toLowerCase() as any,
      content: m.content
    }));

    const rawResponse = await this.aiIntegrationService.generateResponse(systemInstruction, history, message);

    const parsed = this.aiResponseParser.parseAndValidate<AIRecommendation>(rawResponse, []);
    
    let recommendation: AIRecommendation;
    if (typeof parsed === 'string') {
       recommendation = { message: parsed as string };
    } else {
       recommendation = { ...parsed, message: (parsed as any).message || JSON.stringify(parsed) };
    }

    const validatedResponse = this.validationService.validate(recommendation, user?.perfilInvestidor || null);

    await this.prisma.chatMessage.create({
      data: {
        sessionId: session.id,
        role: 'ASSISTANT',
        content: validatedResponse.message
      }
    });

    return {
      sessionId: session.id,
      message: validatedResponse.message
    };
  }

  sendMessageStream(userId: string, sessionId: string | null, message: string): Observable<{data: any}> {
    return new Observable((subscriber) => {
      (async () => {
        try {
          let session = sessionId ? await this.prisma.chatSession.findUnique({ where: { id: sessionId }, include: { messages: true } }) : null;

          if (!session) {
            session = await this.prisma.chatSession.create({
              data: { userId },
              include: { messages: true }
            });
          }

          await this.prisma.chatMessage.create({
            data: {
              sessionId: session.id,
              role: 'USER',
              content: message
            }
          });

          const user = await this.prisma.user.findUnique({ where: { id: userId }});
          const systemInstruction = await this.promptBuilderService.buildSystemInstruction(userId);
          const history: ChatMessageContext[] = session.messages.map(m => ({
            role: m.role.toLowerCase() as any,
            content: m.content
          }));

          const stream = this.aiIntegrationService.generateResponseStream(systemInstruction, history, message);
          
          let fullResponse = '';
          for await (const chunk of stream) {
            fullResponse += chunk;
            subscriber.next({ data: { chunk, sessionId: session.id } });
          }

          const parsed = this.aiResponseParser.parseAndValidate<AIRecommendation>(fullResponse, []);
          let recommendation: AIRecommendation = typeof parsed === 'string' 
            ? { message: parsed as string } 
            : { ...parsed, message: (parsed as any).message || JSON.stringify(parsed) };
          
          const validatedResponse = this.validationService.validate(recommendation, user?.perfilInvestidor || null);

          if (validatedResponse.message !== fullResponse) {
             const diff = validatedResponse.message.replace(fullResponse, '');
             if (diff) {
               subscriber.next({ data: { chunk: diff, sessionId: session.id } });
             }
          }

          await this.prisma.chatMessage.create({
            data: {
              sessionId: session.id,
              role: 'ASSISTANT',
              content: validatedResponse.message
            }
          });

          subscriber.complete();
        } catch (err) {
          subscriber.error(err);
        }
      })();
    });
  }
}
