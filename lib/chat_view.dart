import 'dart:convert';
import 'dart:developer';

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

    final jsonData = extractJson(response);

    if (jsonData != null && jsonData['code'] != null) {
      List files = jsonData['code'];

      for (var file in files) {
        print("File: ${file['fileName']}");
        print("Path: ${file['filePath']}");
        print("Code:\n${file['code']}");
        await projectController.createFile(file['fileName'], file['filePath']);
        await projectController.addCodeInFile(
          file['filePath'],
          file['fileName'],
          file['code'],
        );
      }
    } else {
      print("No valid JSON found in response");
    }

    setState(() {
      messages.add({'viper': response});
    });
  }

  /// Extracts first valid JSON object from AI response text
  Map<String, dynamic>? extractJson(String response) {
    try {
      int start = response.indexOf('{');
      int end = response.lastIndexOf('}');
      if (start == -1 || end == -1) return null;

      String jsonString = response.substring(start, end + 1);

      // Fix unescaped newlines inside "code": "...".
      // Replace "code": " ... " with "code": " ...escaped..."
      jsonString = jsonString.replaceAllMapped(
        RegExp(r'"code":\s*"([\s\S]*?)"(?=\s*[},])'),
        (match) {
          final raw = match.group(1)!;
          final fixed = raw
              .replaceAll(r'\"', '"') // already escaped quotes stay normal
              .replaceAll('\n', r'\n'); // escape newlines
          return '"code": "$fixed"';
        },
      );

      return jsonDecode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      print("JSON extraction failed: $e");
      return null;
    }
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
