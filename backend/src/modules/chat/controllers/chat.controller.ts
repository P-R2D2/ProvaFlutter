import { Controller, Post, Body, Request } from '@nestjs/common';
import { ChatService } from '../services/chat.service';
import { ChatMessageDto } from '../dtos/chat-message.dto';

@Controller('chat')
export class ChatController {
  constructor(private readonly chatService: ChatService) {}

  @Post('porquinho')
  async chatPorquinho(@Request() req: any, @Body() body: ChatMessageDto) {
    const userId = req.user?.userId || req.user?.sub;
    return this.chatService.processChat(userId, body);
  }
}
