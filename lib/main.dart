import 'package:flutter/material.dart';
import 'package:viper/chat_view.dart';
import 'package:viper/controller.dart'; 

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: MaterialApp(
        title: 'Viper',
        debugShowCheckedModeBanner: false,
        home: ChatScreen(),
      ),
    );
  }
}
