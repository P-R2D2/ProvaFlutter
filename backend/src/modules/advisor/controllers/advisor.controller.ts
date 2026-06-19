import { Controller, Post, Body, Req, UseGuards, Sse, Res, HttpCode } from '@nestjs/common';
import { ConversationService } from '../services/conversation.service';
import { JwtAuthGuard } from '../../auth/guards/jwt-auth.guard';

@Controller('advisor')
export class AdvisorController {
  constructor(private readonly conversationService: ConversationService) {}

  @UseGuards(JwtAuthGuard)
  @Post('chat')
  async chat(@Req() req: any, @Body() body: { message: string; sessionId?: string }) {
    const userId = req.user.id;
    return this.conversationService.sendMessage(userId, body.sessionId || null, body.message);
  }

  @UseGuards(JwtAuthGuard)
  @Post('stream')
  @HttpCode(200)
  streamChat(@Req() req: any, @Body() body: { message: string; sessionId?: string }, @Res() res: any) {
    const userId = req.user.id;
    
    res.status(200);
    res.setHeader('Content-Type', 'text/event-stream');
    res.setHeader('Cache-Control', 'no-cache');
    res.setHeader('Connection', 'keep-alive');

    const stream$ = this.conversationService.sendMessageStream(userId, body.sessionId || null, body.message);
    
    stream$.subscribe({
      next: (data) => {
        res.write(`data: ${JSON.stringify(data.data)}\n\n`);
      },
      error: (err) => {
        console.error('STREAM ERROR:', err);
        res.write(`data: {"error": "Internal error"}\n\n`);
        res.end();
      },
      complete: () => {
        res.end();
      }
    });
  }
}
