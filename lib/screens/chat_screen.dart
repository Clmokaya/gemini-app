import 'package:firebase_ai/firebase_ai.dart';
import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  // Initialise the model
  // Insert code 4.1
  late final GenerativeModel _model;
  late final ChatSession _chat;

  final TextEditingController _controller = TextEditingController();
  final List<({String role, String text})> _messages = [];
  bool _isLoading = false;

  // Set up Firebase AI
  // Insert code 4.2

  @override
  void initState() {
    super.initState();
    // 2. Setup Firebase AI
    _model = FirebaseAI.googleAI().generativeModel(model: 'gemini-2.5-flash');

    _chat = _model.startChat();
  }

  // Add the sendMessage Logic
  // Insert code 4.3

  Future<void> _sendMessage() async {
    final message = _controller.text;
    if (message.isEmpty) return;

    setState(() {
      _messages.add((role: 'user', text: message));
      _isLoading = true;
    });
    _controller.clear();

    // Call the API here
    // Insert code 4.4
    try {
      // 4. Call the API
      final result = await _chat.sendMessage(Content.text(message));
      final response = result.text;

      setState(() {
        if (response != null) {
          _messages.add((role: 'model', text: response));
        }
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _messages.add((role: 'model', text: 'Error: $e'));
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(title: const Text('Gemini Chat'), centerTitle: true),
        body: Column(
          children: [
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final msg = _messages[index];
                  final isUser = msg.role == 'user';
                  return Align(
                    alignment: isUser
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isUser
                            ? Colors.deepPurple.shade100
                            : Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(msg.text),
                    ),
                  );
                },
              ),
            ),

            // Insert the LinearProgressIndicator after Expanded
            // if (_isLoading) const LinearProgressIndicator(),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText: 'Ask Gemini...',
                        border: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(20.0)),
                        ),
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    onPressed: _isLoading ? null : _sendMessage,
                    icon: const Icon(Icons.send),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
