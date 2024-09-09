import 'package:flutter/material.dart';
import 'package:immo24calculator/calculations/annuität.dart';
import 'package:immo24calculator/widgets/bottom_navigation.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => Mortgage(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hypothekenrechner',
      theme: ThemeData.light().copyWith(
        colorScheme: ColorScheme.light(
          primary: Colors.amber,
          secondary: Colors.brown[600]!,
          background: Colors.amber[50]!,
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.amber[300],
          foregroundColor: Colors.brown[800],
          elevation: 0,
        ),
        scaffoldBackgroundColor: Colors.amber[50],
        textTheme: TextTheme(
          displayLarge: TextStyle(color: Colors.brown[900]),
          displayMedium: TextStyle(color: Colors.brown[800]),
          displaySmall: TextStyle(color: Colors.brown[800]),
          headlineMedium: TextStyle(color: Colors.brown[700]),
          headlineSmall: TextStyle(color: Colors.brown[700]),
          titleLarge: TextStyle(color: Colors.brown[700]),
          bodyLarge: TextStyle(color: Colors.brown[800]),
          bodyMedium: TextStyle(color: Colors.brown[700]),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.amber[400],
            foregroundColor: Colors.brown[800],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.brown[800],
            side: BorderSide(color: Colors.amber[400]!),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: Colors.amber[300]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: Colors.amber[600]!, width: 2),
          ),
          filled: true,
          fillColor: Colors.white,
        ),
        cardTheme: CardTheme(
          color: Colors.white,
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
      ),
      home: BottomNavigation(),
    );
  }
}
