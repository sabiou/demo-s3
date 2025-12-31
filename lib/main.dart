import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Fichier généré par `flutterfire configure`.
import 'firebase_options.dart';
import 'features/todo/todo_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Prépare les plugins Flutter.
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform, // Charge la config Firebase.
  );
  runApp(const ProviderScope(child: TodoApp())); // Active Riverpod et lance l'app.
}

class TodoApp extends StatelessWidget {
  const TodoApp({super.key});

  @override
  Widget build(BuildContext context) {
    // App simple avec un thème vert et un seul écran.
    return MaterialApp(
      title: 'Firebase TODO Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: const TodoScreen(),
    );
  }
}
