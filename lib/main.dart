import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/mock_server_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
  options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MockServerApp());
}

class MockServerApp extends StatelessWidget {
  const MockServerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Colors.orange,
        hintColor: Colors.orangeAccent,
        textTheme: const TextTheme(
          bodyMedium: TextStyle(fontSize: 14,color: Colors.white),
        ),
          inputDecorationTheme: const InputDecorationTheme(
          labelStyle: TextStyle(color: Colors.orangeAccent),
          hintStyle: TextStyle(color: Colors.orangeAccent),
            border: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.orange),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.orangeAccent),
            ),
      )
      ),
      home: MockServerScreen(),
    );
  }
}