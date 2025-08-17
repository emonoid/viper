import 'package:flutter/material.dart';
import 'package:viper/api_service.dart';
import 'package:viper/controller.dart';

class ChatScreen extends StatefulWidget {
  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> messages = [];
  final ProjectController projectController = ProjectController();

  @override
  void initState() {
    super.initState();
    projectController.initProject('MyFlutterProject');
  }

  void _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      messages.add({'user': text});
    });

    _controller.clear();

    // Simulate AI response (replace with your LLM API call)
    String response = await ApiService().sendMessage(text);
    String aiResponse = "$response";

    // Example usage: create file & add code
    // await projectController.createFile('main.dart');
    // await projectController.addCodeInFile('', 'main.dart', aiResponse);

    setState(() {
      messages.add({'viper': aiResponse});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Viper'), centerTitle: true),
      body: Column(
        children: [
          Container(
            height: 40,
            width: 250,
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(55),
              color: Colors.white,
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: messages.length,
              itemBuilder: (_, index) {
                final msg = messages[index];
                if (msg.containsKey('user')) {
                  return ListTile(
                    title: Align( 
                      alignment: Alignment.centerRight,
                      child: Container(
                        padding: EdgeInsets.all(8),
                        color: Colors.blue[100],
                        child: Text(msg['user']!),
                      ),
                    ),
                  );
                } else {
                  return ListTile(
                    title: Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        padding: EdgeInsets.all(8),
                        color: Colors.grey[300],
                        child: Text(msg['viper']!),
                      ),
                    ),
                  );
                }
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.all(8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Ask AI to generate code...',
                    ),
                  ),
                ),
                IconButton(icon: Icon(Icons.send), onPressed: _sendMessage),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
