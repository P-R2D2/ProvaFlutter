import 'package:flutter/material.dart';
import '../pages/chat_page.dart';

class FloatingChatWidget extends StatefulWidget {
  final Widget child;

  const FloatingChatWidget({Key? key, required this.child}) : super(key: key);

  @override
  State<FloatingChatWidget> createState() => _FloatingChatWidgetState();
}

class _FloatingChatWidgetState extends State<FloatingChatWidget> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        Positioned(
          right: 16,
          bottom: 16, // Positioned within the Scaffold body
          child: _isExpanded
              ? _buildExpandedChat()
              : _buildFloatingButton(),
        ),
      ],
    );
  }

  Widget _buildFloatingButton() {
    return FloatingActionButton(
      onPressed: () => setState(() => _isExpanded = true),
      child: const Icon(Icons.chat),
      backgroundColor: Theme.of(context).primaryColor,
    );
  }

  Widget _buildExpandedChat() {
    return Material(
      elevation: 8,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: Container(
        width: 320,
        height: 500,
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
        ),
        child: Column(
          children: [
            Container(
              color: Theme.of(context).primaryColor,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Advisor', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  InkWell(
                    onTap: () => setState(() => _isExpanded = false),
                    child: const Icon(Icons.close, color: Colors.white),
                  )
                ],
              ),
            ),
            Expanded(child: ChatPage()),
          ],
        ),
      ),
    );
  }
}
