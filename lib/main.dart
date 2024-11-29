import 'package:verdant/Pages/Plants/AddPlantPage.dart';
import 'package:verdant/firebase_options.dart';
import 'package:verdant/pages/Auth/login.dart';
import 'package:verdant/pages/Auth/signup.dart';
import 'package:verdant/pages/home_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

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
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      // Determinar la pantalla inicial
      home: const AuthWrapper(),
      routes: {
        '/login': (context) =>  LoginView(),
        '/signup': (context) =>  SignUpPage(),
        '/home': (context) =>  HomePage(),
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

    // Si el usuario está autenticado, redirigir a HomePage; de lo contrario, a LoginView
    if (user != null) {
      return  HomePage();
    } else {
      return  LoginView();
    }
  }
}
