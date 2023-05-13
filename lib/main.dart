import 'package:dart_openai/openai.dart';
import 'package:flutter/material.dart';
import 'package:quiz_vision/screens/home_screen.dart';

import 'env/env.dart';

void main() {
  OpenAI.apiKey = Env.apiKey;
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
