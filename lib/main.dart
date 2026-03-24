import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'pages/login_page.dart';

void main() async {
  // Asegura que los bindings de Flutter estén listos antes de inicializar Firebase [cite: 396]
  WidgetsFlutterBinding.ensureInitialized();

  // Inicialización de Firebase usando las opciones configuradas por plataforma [cite: 396]
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
      debugShowCheckedModeBanner: false,
      title: "EliteForm",

      // Configuración centralizada del estilo visual de la aplicación [cite: 400]
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor:
            const Color(0xFF0F172A), // Fondo azul oscuro profundo [cite: 400]

        colorScheme: const ColorScheme.dark(
          primary: Colors.orangeAccent,
          secondary: Colors.orangeAccent,
          surface: Color(
              0xFF1E293B), // Color para tarjetas y contenedores [cite: 401]
        ),

        // Estilo global para la barra superior [cite: 401]
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF020617),
          foregroundColor: Colors.orangeAccent,
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.orangeAccent),
        ),

        // Configuración predeterminada para botones elevados [cite: 401]
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orangeAccent,
            foregroundColor: Colors.black,
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),

        // Estilo para los campos de texto (Inputs) [cite: 401]
        inputDecorationTheme: const InputDecorationTheme(
          filled: true,
          fillColor: Color(0xFF1E293B),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
            borderSide: BorderSide.none,
          ),
          prefixIconColor: Colors.orangeAccent,
        ),

        progressIndicatorTheme: const ProgressIndicatorThemeData(
          color: Colors.orangeAccent,
        ),
      ),

      // Punto de entrada: Pantalla de inicio de sesión [cite: 401]
      home: const LoginPage(),
    );
  }
}
