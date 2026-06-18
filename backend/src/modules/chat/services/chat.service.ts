import { Injectable, InternalServerErrorException } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import OpenAI from 'openai';
import { ChatMessageDto } from '../dtos/chat-message.dto';
import { UsersService } from '../../users/services/users.service';

@Injectable()
export class ChatService {
  private openai: OpenAI;

  private readonly systemPrompt = `Você é o 'Conselheiro Porquinho', um assistente financeiro amigável. Sua missão é fazer uma entrevista para determinar o perfil de investidor do usuário.
Regras:
Faça EXATAMENTE 7 perguntas, aguardando a resposta do usuário antes de enviar a próxima.
As perguntas devem avaliar tolerância ao risco, prazo e experiência prévia.
Atribua mentalmente uma nota de 0 a 100 baseada nas respostas.
Regra de Classificação: 0-30 pontos (CONSERVADOR), 31-70 pontos (MODERADO), 71-100 pontos (ARROJADO).
REGRA DE ENCERRAMENTO: Ao receber a resposta da 7ª pergunta, você NÃO DEVE enviar texto comum. Sua resposta deve ser EXCLUSIVAMENTE um objeto JSON válido neste formato: {"finalizado": true, "pontuacao": X, "perfil": "NOME_DO_PERFIL", "mensagem_despedida": "Mensagem final aqui"}`;

  constructor(
    private readonly configService: ConfigService,
    private readonly usersService: UsersService,
  ) {
    this.openai = new OpenAI({
      apiKey: this.configService.get<string>('OPENAI_API_KEY') || process.env.OPENAI_API_KEY || 'sk-dummy-key-for-local-development',
    });
  }

  async processChat(userId: string, chatDto: ChatMessageDto) {
    try {
      const messages: OpenAI.Chat.ChatCompletionMessageParam[] = [
        { role: 'system', content: this.systemPrompt },
        ...chatDto.messages as OpenAI.Chat.ChatCompletionMessageParam[],
      ];

      const response = await this.openai.chat.completions.create({
        model: 'gpt-4o-mini',
        temperature: 0.2,
        messages,
      });

      const replyContent = response.choices[0]?.message?.content || '';

      // Tentar fazer o parse caso a resposta seja o JSON final
      let parsed: any = null;
      try {
        // Extrai apenas a parte que parece um JSON usando regex
        const jsonMatch = replyContent.match(/\{[\s\S]*\}/);
        if (jsonMatch) {
          parsed = JSON.parse(jsonMatch[0]);
        } else {
          const cleanContent = replyContent.replace(/```json/gi, '').replace(/```/g, '').trim();
          parsed = JSON.parse(cleanContent);
        }
      } catch (e) {
        // Não é JSON ou falhou no parse, segue o fluxo normal
      }

      if (parsed && parsed.finalizado) {
        try {
          const user = await this.usersService.findById(userId);
          if (user) {
            user.entrevistaConcluida = true;
            user.pontuacaoPerfil = parsed.pontuacao;
            user.perfilInvestidor = parsed.perfil;
            await this.usersService.update(user);
          }
          return {
            role: 'assistant',
            content: parsed.mensagem_despedida || 'Entrevista finalizada.',
            finalizado: true,
            perfil: parsed.perfil,
            pontuacao: parsed.pontuacao,
          };
        } catch (dbError) {
          console.error('Erro ao salvar dados da entrevista:', dbError);
          // Podemos retornar o json na mesma para o frontend, ou lidar de forma amigável
        }
      }

      return {
        role: 'assistant',
        content: replyContent,
        finalizado: false,
      };
    } catch (error) {
      console.error('Error calling OpenAI:', error);
      throw new InternalServerErrorException('Erro ao processar mensagem com a IA');
    }
  }
}
