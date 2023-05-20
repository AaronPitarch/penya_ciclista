import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:penya_ciclista/pages/home_page.dart';
import 'package:penya_ciclista/pages/login_page.dart';
import 'package:penya_ciclista/pages/register_page.dart';

// Importaciones firebase
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
  );

  // Configuración de Firestore
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true, // Opcional, activa la persistencia offline
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginPage(),
        '/register':(context) => const RegisterPage(),

        '/home':(context) => HomePage(),
      },
      home: const LoginPage(),
    );
  }
}