import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'navigation/app_router.dart';
import 'data/user_database.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  UserDatabase.init();
  runApp(const KhidmatAiApp());
}


class KhidmatAiApp extends StatelessWidget {
  const KhidmatAiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Khidmat AI',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: appRouter,
    );
  }
}
