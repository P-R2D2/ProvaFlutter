import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../data/services/chat_api_service.dart';
import '../providers/auth_provider.dart';

class OnboardingChatPage extends StatefulWidget {
  const OnboardingChatPage({super.key});

  @override
  State<OnboardingChatPage> createState() => _OnboardingChatPageState();
}

class _OnboardingChatPageState extends State<OnboardingChatPage> {
  final _chatService = ChatApiService();
  final _textController = TextEditingController();
  final _scrollController = ScrollController();
  
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;
  bool _isFinished = false;

  @override
  void initState() {
    super.initState();
    // Iniciar a conversa (a IA recebe a primeira mensagem 'system' no backend, mas precisa de um trigger inicial)
    _sendMessage("Olá, vamos começar!");
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    final userMessage = text.trim();
    setState(() {
      if (userMessage != "Olá, vamos começar!") {
        _messages.add(ChatMessage(role: 'user', content: userMessage));
      } else {
        // Envia mensagem invisível para a IA responder a primeira pergunta
        _messages.add(ChatMessage(role: 'user', content: userMessage));
      }
      _isLoading = true;
    });
    _textController.clear();
    _scrollToBottom();

    try {
      final token = context.read<AuthProvider>().currentToken;
      if (token == null) return;

      final response = await _chatService.sendMessage(_messages, token);

      setState(() {
        // Remove a mensagem invisível da view (mas mantém na lista de envio para contexto se necessário, ou podemos escondê-la na UI)
        _messages.add(ChatMessage(role: response.role, content: response.content));
        _isLoading = false;
        if (response.finalizado) {
          _isFinished = true;
        }
      });
      _scrollToBottom();

      if (response.finalizado) {
        // Marca como concluído no AuthProvider para permitir acesso ao Dashboard
        if (mounted) {
          context.read<AuthProvider>().completeEntrevista();
        }
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _messages.add(ChatMessage(role: 'system', content: 'Erro: ${e.toString()}'));
      });
      _scrollToBottom();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Text('🐷', style: TextStyle(fontSize: 24)),
            SizedBox(width: 8),
            Text('Conselheiro Porquinho'),
          ],
        ),
        automaticallyImplyLeading: false, // Força a não voltar
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => context.read<AuthProvider>().logout(),
          )
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final isUser = msg.role == 'user';
                final isSystem = msg.role == 'system';

                // Esconde a mensagem inicial do usuário na interface
                if (isUser && msg.content == "Olá, vamos começar!") {
                  return const SizedBox.shrink();
                }

                return Align(
                  alignment: isSystem 
                      ? Alignment.center 
                      : (isUser ? Alignment.centerRight : Alignment.centerLeft),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.75,
                    ),
                    decoration: BoxDecoration(
                      color: isSystem 
                          ? Colors.grey.withValues(alpha: 0.2)
                          : (isUser ? theme.colorScheme.primary : theme.colorScheme.surfaceContainerHighest),
                      borderRadius: BorderRadius.circular(16).copyWith(
                        bottomRight: isUser ? const Radius.circular(4) : const Radius.circular(16),
                        bottomLeft: !isUser && !isSystem ? const Radius.circular(4) : const Radius.circular(16),
                      ),
                    ),
                    child: Text(
                      msg.content,
                      style: TextStyle(
                        color: isSystem
                            ? theme.colorScheme.onSurface
                            : (isUser ? theme.colorScheme.onPrimary : theme.colorScheme.onSurfaceVariant),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: CircularProgressIndicator(),
            ),
          if (_isFinished)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: FilledButton.icon(
                onPressed: () => context.go('/'),
                icon: const Icon(Icons.check),
                label: const Text('Ir para o Dashboard'),
                style: FilledButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
              ),
            )
          else
            Container(
              padding: const EdgeInsets.all(16),
              color: theme.colorScheme.surface,
              child: SafeArea(
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _textController,
                        enabled: !_isLoading,
                        decoration: const InputDecoration(
                          hintText: 'Digite sua resposta...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(24)),
                          ),
                          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        ),
                        onSubmitted: _sendMessage,
                      ),
                    ),
                    const SizedBox(width: 8),
                    FloatingActionButton(
                      onPressed: _isLoading ? null : () => _sendMessage(_textController.text),
                      mini: true,
                      child: const Icon(Icons.send),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
