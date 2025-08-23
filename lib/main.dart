import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/login_screen.dart';
import 'screens/todo_screen.dart';
import 'services/firebase_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Initialize Firebase with options
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyAZSiE65B-JNF-Pv_F4iBR2DtUeah00sMc",
        appId: "1:764405283826:android:b6c11ca059f269bdcec96b",
        messagingSenderId: "764405283826",
        projectId: "764405283826",
      ),
    );
    runApp(MyApp());
  } catch (e) {
    print('Firebase initialization error: $e');
    // Fallback: try to initialize without explicit options
    try {
      await Firebase.initializeApp();
      runApp(MyApp());
    } catch (e) {
      print('Fallback initialization failed: $e');
      runApp(FirebaseErrorApp(error: e.toString()));
    }
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<FirebaseService>(create: (_) => FirebaseService()),
        StreamProvider<User?>(
          create: (context) => context.read<FirebaseService>().authStateChanges,
          initialData: null,
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Firebase Todo App',
        theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
        home: AuthenticationWrapper(),
      ),
    );
  }
}

class AuthenticationWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final firebaseUser = context.watch<User?>();

    if (firebaseUser != null) {
      return TodoScreen();
    }
    return LoginScreen();
  }
}

// Error widget for Firebase initialization failures
class FirebaseErrorApp extends StatelessWidget {
  final String error;

  const FirebaseErrorApp({Key? key, required this.error}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.red[50],
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 20),
                const Text(
                  'Firebase Configuration Error',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                Text(
                  'Error: $error',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Please check:\n'
                  '1. google-services.json file is in android/app/\n'
                  '2. android/app/build.gradle has com.google.gms:google-services plugin\n'
                  '3. android/app/build.gradle applies com.google.gms.google-services plugin\n'
                  '4. All required Firebase dependencies are in pubspec.yaml',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: () {
                    // Try to restart the app
                    runApp(MyApp());
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
