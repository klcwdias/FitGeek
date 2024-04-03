import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../widgets/btmnavbar.dart';
import 'model/response_model.dart';

class ChatGptPage extends StatefulWidget {
  const ChatGptPage({super.key});

  @override
  State<ChatGptPage> createState() => _ChatGptPageState();
}

class _ChatGptPageState extends State<ChatGptPage> {
  late final TextEditingController promptController;
  List<ChatMessage> chatMessages = [];
  late ResponseModel _responseModel;

  @override
  void initState() {
    super.initState();
    promptController = TextEditingController();
  }

  int _currentIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  void dispose() {
    promptController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat Assistant'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: chatMessages.length,
              itemBuilder: (context, index) {
                final message = chatMessages[index];
                return ChatBubble(
                  message: message.text,
                  isUserMessage:
                      message.chatMessageType == ChatMessageType.user,
                );
              },
            ),
          ),
          Container(
            color: Colors.grey[100],
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: promptController,
                    decoration: const InputDecoration(
                      hintText: 'Ask me Anything!',
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () => completeFun(promptController.text),
                  icon: const Icon(Icons.send),
                  color: Colors.green,
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BtmNavBar(
        currentIndex: _currentIndex,
        onItemSelected: _onItemTapped,
      ),
    );
  }

  completeFun(String userMessage) async {
    setState(() {
      chatMessages.add(ChatMessage(
          text: userMessage, chatMessageType: ChatMessageType.user));
      promptController.clear();
    });

    final response = await http.post(
      Uri.parse('https://api.openai.com/v1/chat/completions'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer OPEN-AI Key'
      },
      body: jsonEncode({
        "model": "gpt-3.5-turbo-0125",
        "max_tokens": 250,
        "temperature": 0,
        "top_p": 1,
        "messages": [
          {"role": "system", "content": "Hello, let's have a conversation."},
          {"role": "user", "content": userMessage}
        ]
      }),
    );

    setState(() {
      _responseModel = ResponseModel.fromJson(json.decode(response.body));
      if (_responseModel.choices.isNotEmpty) {
        chatMessages.add(ChatMessage(
          text: _responseModel.choices.last.message.content,
          chatMessageType: ChatMessageType.bot,
        ));
      } else {
        chatMessages.add(ChatMessage(
          text: 'No response available',
          chatMessageType: ChatMessageType.bot,
        ));
      }
    });
  }
}

class ChatBubble extends StatelessWidget {
  final String message;
  final bool isUserMessage;

  const ChatBubble(
      {super.key, required this.message, required this.isUserMessage});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isUserMessage ? Alignment.topRight : Alignment.topLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isUserMessage ? Colors.blue[200] : Colors.grey[200],
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          message,
          style: const TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}

class ChatMessage {
  final String text;
  final ChatMessageType chatMessageType;

  ChatMessage({required this.text, required this.chatMessageType});
}

enum ChatMessageType { user, bot }
