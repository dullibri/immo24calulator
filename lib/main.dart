import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:immo24calculator/calculations/annuität.dart';
import 'package:immo24calculator/widgets/bottom_navigation.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'firebase_options.dart';
import 'auth_service.dart';
import 'login_page.dart';
import 'firestore_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  if (kDebugMode) {
    try {
      FirebaseFirestore.instance.useFirestoreEmulator('localhost', 8080);
      await FirebaseAuth.instance.useAuthEmulator('localhost', 9099);
      print('Emulators are connected');

      // Anmeldung für den Emulator
      await signInToEmulator();
    } catch (e) {
      print('Failed to connect to emulators or sign in: $e');
    }
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => Mortgage()),
        ChangeNotifierProvider(create: (_) => AuthService()),
        Provider<FirestoreService>(create: (_) => FirestoreService()),
      ],
      child: MyApp(),
    ),
  );
}

Future<void> signInToEmulator() async {
  try {
    // Anonyme Anmeldung für den Emulator
    UserCredential userCredential =
        await FirebaseAuth.instance.signInAnonymously();

    print(
        'Signed in to emulator successfully with UID: ${userCredential.user?.uid}');
  } catch (e) {
    print('Failed to sign in to emulator: $e');
  }
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
      home: AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);
    return StreamBuilder<User?>(
      stream: authService.user,
      builder: (_, AsyncSnapshot<User?> snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          final User? user = snapshot.data;
          return user == null ? LoginPage() : BottomNavigation();
        }
        return Scaffold(body: Center(child: CircularProgressIndicator()));
      },
    );
  }
}
