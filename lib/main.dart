import 'package:verdant/Pages/Plants/AddPlantPage.dart';
import 'package:verdant/Pages/main_layout.dart';
import 'package:verdant/firebase_options.dart';
import 'package:verdant/pages/Auth/login.dart';
import 'package:verdant/pages/Auth/signup.dart';
import 'package:verdant/pages/home_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:verdant/Tema/AppColors.dart';
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Verdant',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.light, // Cambia a Brightness.dark para tema oscuro
        primarySwatch: Colors.green, // Cambia a tu color preferido
        scaffoldBackgroundColor: Colors.white, // Asegura un fondo claro
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.black), // Texto predeterminado negro
          bodyMedium: TextStyle(color: Colors.black),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.principalGreen, // Color de fondo del AppBar
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      // Determinar la pantalla inicial
      home: const AuthWrapper(),
      routes: {
        '/login': (context) => LoginView(),
        '/signup': (context) => SignUpPage(),
        '/home': (context) => MainLayout(),
        '/add-plant': (context) => AddPlantPage(),
      },
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    // Verificar si hay un usuario autenticado
    final user = FirebaseAuth.instance.currentUser;

    // Si el usuario está autenticado, redirigir a MainLayout; de lo contrario, a LoginView
    if (user != null) {
      return const MainLayout(); // Usamos MainLayout para la estructura principal
    } else {
      return LoginView();
    }
  }
}
