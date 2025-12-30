import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'utils/app_theme.dart';
import 'screens/title_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const ProviderScope(
      child: BeatChatApp(),
    ),
  );
}

class BeatChatApp extends StatelessWidget {
  const BeatChatApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Beat Chat',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      home: const TitleScreen(),
    );
  }
}
