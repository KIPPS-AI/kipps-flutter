
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;

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
  late WebUri _chatbotUrl;
  String? _chatIconUrl;
  OverlayEntry? _overlayEntry;

  @override
  void initState() {
    super.initState();
    _chatbotUrl = WebUri('https://app.kipps.ai/iframe/${widget.chatbotId}');
    _fetchChatIcon();
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

  void _showChatbot(BuildContext context) {
    if (kIsWeb) {
      _showChatbotOverlay(context);
    } else {
      _showChatbotModal(context);
    }
  }

  void _showChatbotModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      enableDrag: false,
      builder: (BuildContext context) {
        return FractionallySizedBox(
          heightFactor: 0.9,
          child: Stack(
            children: [
              InAppWebView(
                initialUrlRequest: URLRequest(url: _chatbotUrl),
                initialSettings: InAppWebViewSettings(
                  javaScriptEnabled: true,
                ),
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

  void _showChatbotOverlay(BuildContext context) {
  _overlayEntry = OverlayEntry(
    builder: (context) => Stack(
      children: [
        Positioned.fill(
          child: GestureDetector(
            onTap: () {
              _overlayEntry?.remove();
              _overlayEntry = null;
              setState(() {});
            },
            child: Container(
              color: Colors.black54,
            ),
          ),
        ),
        Positioned(
          bottom: 70,
          right: 20,
          child: Material(
            elevation: 8.0,
            color: Colors.transparent,
            child: Stack(
              children: [
                Container(
                  width: 400,
                  height: 600,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 10.0,
                        spreadRadius: 2.0,
                      ),
                    ],
                  ),
                  child: InAppWebView(
                    initialUrlRequest: URLRequest(url: _chatbotUrl),
                    initialSettings: InAppWebViewSettings(
                      javaScriptEnabled: true,
                    ),
                  ),
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: GestureDetector(
                    onTap: () {
                      _overlayEntry?.remove();
                      _overlayEntry = null;
                      setState(() {});
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
          ),
        ),
      ],
    ),
  );

  Overlay.of(context).insert(_overlayEntry!);
}

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      child: FloatingActionButton(
        onPressed: () => _showChatbot(context),
        child: _chatIconUrl != null
            ? Image.network(_chatIconUrl!)
            : Image.network(
                'https://chatx-ai-dev.s3.amazonaws.com/Primary.png'),
      ),
    );
  }
}
