import 'package:brokecheck/about.dart';
import 'package:brokecheck/app_themes.dart';
import 'package:brokecheck/delete_account.dart';
import 'package:brokecheck/deposit.dart';
import 'package:brokecheck/firebase_options.dart';
import 'package:brokecheck/homepage.dart';
import 'package:brokecheck/security.dart';
import 'package:brokecheck/withdraw.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:brokecheck/settings.dart';
import 'package:provider/provider.dart';
import 'get_started.dart';
import 'theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppThemes.lightTheme,
      darkTheme: AppThemes.darkTheme,
      themeMode: themeProvider.themeMode,
      home: Homepage(),
      routes: {
        '/homepage': (context) => Homepage(),
        '/settings': (context) => SettingsScreen(),
        '/getstarted': (context) => GetStartedPage(),
        '/withdraw': (context) {
          final args = ModalRoute.of(context)?.settings.arguments
              as Map<String, dynamic>?;
          return Withdraw(cashbookData: args);
        },
        '/deposit': (context) {
          final args = ModalRoute.of(context)?.settings.arguments
              as Map<String, dynamic>?;
          return Deposit(cashbookData: args);
        },
        '/about': (context) => AboutPage(),
        '/security': (context) => SecuritySettingsPage(),
        '/delete_account': (context) => DeleteAccountPage(),
      },
    );
  }
}
