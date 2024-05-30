import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import './pages/login_page.dart';
import './pages/registration_page.dart';
import './pages/home_page.dart';
import './services/navigation_service.dart';
import './providers/auth_provider.dart'; // Import your AuthProvider here

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await initializeFirebase();

  runApp(MyApp());
}

Future<void> initializeFirebase() async {
  try {
    // Replace this with your actual Firebase project configuration
    await Firebase.initializeApp(
      options: FirebaseOptions(
        apiKey: "AIzaSyAHtDLInqXk9_2ZV1tlFpjf10DBVoOcGs0",
        appId: "1:494433995490:android:868fbc9dc8928b9da5ecbb",
        messagingSenderId: "494433995490",
        projectId: "chatify-18f39",
      ),
    );
  } catch (e) {
    print("Error initializing Firebase: $e");
    // Handle Firebase initialization error
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()), // Provide your AuthProvider
      ],
      child: MaterialApp(
        title: 'Chatify',
        navigatorKey: NavigationService.instance.navigatorKey,
        theme: _buildTheme(),
        initialRoute: "login",
        routes: {
          "login": (_) => LoginPage(),
          "register": (_) => RegistrationPage(),
          "home": (_) => HomePage(),
        },
      ),
    );
  }

  ThemeData _buildTheme() {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: Color.fromRGBO(42, 117, 188, 1),
      hintColor: Color.fromRGBO(42, 117, 188, 1),
      backgroundColor: Color.fromRGBO(28, 27, 27, 1),
    );
  }
}
