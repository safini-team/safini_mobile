import 'package:flutter/material.dart';
import 'package:safini/core/di/injection.dart';
import 'package:safini/features/parent/presentation/screens/parent_main_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  configureDependencies();
  runApp(const SafinioParentApp());
}

class SafinioParentApp extends StatelessWidget {
  const SafinioParentApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Safinio Parent',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF8B46FF)),
        fontFamily: 'Inter', // Modern font
        scaffoldBackgroundColor: const Color(0xFFF8F9FF),
        useMaterial3: true,
      ),
      home: const ParentMainScreen(),
    );
  }
}