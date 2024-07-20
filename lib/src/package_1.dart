import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ChatbotIntegration extends StatefulWidget {
  final String chatbotId;

  const ChatbotIntegration({
    required this.chatbotId,
    super.key,
  });

  @override
  ChatbotIntegrationState createState() => ChatbotIntegrationState();
}

class ChatbotIntegrationState extends State<ChatbotIntegration> {
  late String _chatbotUrl;
  String? _chatIconUrl;

  @override
  void initState() {
    super.initState();
    _chatbotUrl = 'https://app.kipps.ai/iframe/${widget.chatbotId}';
    _fetchChatIcon();
    if (Platform.isAndroid) {
      WebView.platform = SurfaceAndroidWebView();
    }
  }

  Future<void> _fetchChatIcon() async {
    final response = await http.get(Uri.parse(
        'https://backend.kipps.ai/kipps/chatbot/${widget.chatbotId}'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        _chatIconUrl = data['chat_icon_image'];
      });
    } else {
      throw Exception('Failed to load chatbot icon');
    }
  }

  void _showChatbotModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return FractionallySizedBox(
          heightFactor: 0.9,
          child: Stack(
            children: [
              WebView(
                initialUrl: _chatbotUrl,
                javascriptMode: JavascriptMode.unrestricted,
              ),
              Positioned(
                top: 10,
                right: 10,
                child: GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                  child: const CircleAvatar(
                    radius: 15,
                    backgroundColor: Colors.black,
                    child: Icon(
                      Icons.close,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      // radius: 30,
      child: FloatingActionButton(
          onPressed: () => _showChatbotModal(context),
          child: _chatIconUrl != null
              ? Image.network(_chatIconUrl!)
              : Image.network(
                  'https://chatx-ai-dev.s3.amazonaws.com/Primary.png')),
    );
  }
}
