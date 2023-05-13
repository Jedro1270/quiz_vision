import 'package:dart_openai/openai.dart';
import 'package:flutter/material.dart';
import 'package:quiz_vision/screens/home_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future main() async {
  await dotenv.load(fileName: ".env");
  OpenAI.apiKey = dotenv.env['OPEN_AI_API_KEY']!;
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomeScreen(),
    );
  }
}
