import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/chat_provider.dart';
import '../widgets/markdown_message_widget.dart';

class ChatPage extends StatefulWidget {
  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final chatProvider = context.watch<ChatProvider>();

    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: chatProvider.messages.length,
            itemBuilder: (context, index) {
              final msg = chatProvider.messages[index];
              return MarkdownMessageWidget(
                text: msg.content,
                isUser: msg.role == 'USER',
              );
            },
          ),
        ),
        if (chatProvider.isLoading)
           const Padding(padding: EdgeInsets.all(8), child: LinearProgressIndicator()),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  decoration: const InputDecoration(
                    hintText: 'Ask about your portfolio...',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.send),
                onPressed: () {
                  chatProvider.sendMessage(_controller.text);
                  _controller.clear();
                },
              )
            ],
          ),
        )
      ],
    );
  }
}
