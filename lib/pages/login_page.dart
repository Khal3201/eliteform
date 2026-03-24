import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'register_page.dart';
import 'home_page.dart';
import '../widgets/app_background.dart';
import 'admin_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final adminEmail = "admin@admin.com";
  final adminPassword = "123456";

  Future loginUser() async {
    if (emailController.text.trim() == adminEmail &&
        passwordController.text.trim() == adminPassword) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const AdminPage()),
      );
      return;
    }

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    } on FirebaseAuthException catch (e) {
      showError(e.message);
    }
  }

  void showError(String? message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Error"),
        content: Text(message ?? "Credenciales incorrectas"),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppBackground(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(25),
              child: Column(
                children: [
                  const Icon(
                    Icons.fitness_center,
                    size: 90,
                    color: Colors.orangeAccent,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Elite Form",
                    style: TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 5),
                  const Text(
                    "Entrena. Mejora. Supera.",
                    style: TextStyle(color: Colors.white54),
                  ),
                  const SizedBox(height: 40),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: [
                        TextField(
                          controller: emailController,
                          decoration: const InputDecoration(
                            labelText: "Correo",
                            prefixIcon: Icon(Icons.email),
                          ),
                        ),
                        const SizedBox(height: 15),
                        TextField(
                          controller: passwordController,
                          obscureText: true,
                          decoration: const InputDecoration(
                            labelText: "Contraseña",
                            prefixIcon: Icon(Icons.lock),
                          ),
                        ),
                        const SizedBox(height: 25),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: loginUser,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orangeAccent,
                              foregroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              "INICIAR ENTRENAMIENTO",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const RegisterPage(),
                              ),
                            );
                          },
                          child: const Text("Crear cuenta"),
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
