import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'navigation/app_router.dart';
import 'data/user_database.dart';
import 'data/bookings_repository.dart';
import 'data/document_database.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  UserDatabase.init();
  BookingsRepository.init();
  DocumentDatabase.syncFromCloudWithInfo();
  runApp(const USTAADAiApp());
}


class USTAADAiApp extends StatelessWidget {
  const USTAADAiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'USTAAD',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: appRouter,
    );
  }
}
