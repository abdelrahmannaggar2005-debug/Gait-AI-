import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:GaitAI/getstart.dart';
import 'package:GaitAI/home/home.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => FallRiskProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) => MaterialApp(
        debugShowCheckedModeBanner: false,
        themeMode: themeProvider.isDark ? ThemeMode.dark : ThemeMode.light,
        theme: ThemeData.light(),
        darkTheme: ThemeData(
          brightness: Brightness.dark,
          scaffoldBackgroundColor: const Color(0xFF0D1525),
          cardColor: const Color(0xFF1A2540),      // ← كل kCard هيبقى يسحب منه
          colorScheme: const ColorScheme.dark(
            primary: kPrimary,
            secondary: kAccent,
            surface: Color(0xFF1A2540),            // ← بديل kCard
            onSurface: Colors.white,
          ),
        ),
        home: StreamBuilder(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            if (snapshot.hasData) return const MainShell();
            return const GetStartedPage();
          },
        ),
      ),
    );
  }
}