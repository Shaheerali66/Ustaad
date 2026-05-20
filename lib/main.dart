import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'navigation/app_router.dart';
import 'data/platform_storage.dart';
import 'data/user_database.dart';
import 'data/bookings_repository.dart';
import 'data/document_database.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Set Auth Persistence to LOCAL
  await FirebaseAuth.instance.setPersistence(Persistence.LOCAL);

  await PlatformStorage.init();
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
