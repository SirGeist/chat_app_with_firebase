import 'package:flutter/material.dart';
import 'package:chat_app_with_firebase/screens/auth.dart';
import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';

void main() {

  WidgetsFlutterBinding.ensureInitialized;
  await Firebase.initalizeApp(
    options: DefaultFirebaseOptions.currentPlatform;
  );
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FlutterChat',
      theme: ThemeData().copyWith(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
            seedColor: const Color.fromARGB(255, 63, 17, 177)),
      ),
      home: const AuthScreen(),
    );
  }
}