import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl = "https://api.groq.com/openai/v1/chat/completions";
  final String apiKey = "";

  Future<String> sendMessage(String message) async {
    final url = Uri.parse(baseUrl);

    final body = {
      "model": "llama-3.3-70b-versatile",
      "messages": [
        {
          "role": "system",
          "content": '''You are Vibe Coder, an AI coding assistant. 
Your job is to generate complete, working project code based on user requests. 
Always return code as separate files inside markdown code blocks, using this format:

Rules:
- Must return full code file with code in file and title as file name, with folder path like:
  
  explanation: I'm creating a tic tac toe game in flutter

  [
  fileName: tictactoe_game_controller.dart
  filePath: /lib/controller
  code: your_provide_code_in_multiple_line
  ]

  [
  fileName: tictactoe_game_view.dart
  filePath: /lib/views
  code: your_provide_code_in_multiple_line
  ]

  (this is your response example)

- You may return multiple files by using multiple code blocks.
- Short explanation will be added top of the codes
- If user asks for an update, return the updated file(s) in the same format. do not remove any code, return full code with updated.
- Always ensure indentation and formatting is correct in the generated code.

''',
        },
        {"role": "user", "content": message},
      ],
    };

    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $apiKey",
      },
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data["choices"][0]["message"]["content"] ?? "No response";
    } else {
      throw Exception(
        "Failed with status ${response.statusCode}: ${response.body}",
      );
    }
  }
}
