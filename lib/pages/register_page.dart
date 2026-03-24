import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // [cite: 1] Necesario para FilteringTextInputFormatter
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'home_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final nombreController = TextEditingController();
  final telefonoController = TextEditingController();

  Future registerUser() async {
    // [cite: 2] VALIDACIÓN LÓGICA: Verifica que tenga exactamente 10 dígitos antes de llamar a Firebase
    if (telefonoController.text.length != 10) {
      showError("El teléfono debe tener exactamente 10 dígitos");
      return;
    }

    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      await FirebaseFirestore.instance
          .collection("usuarios")
          .doc(userCredential.user!.uid)
          .set({
        "id_usuario": userCredential.user!.uid,
        "nombre": nombreController.text.trim(),
        "correo": emailController.text.trim(),
        "telefono": telefonoController.text.trim(),
        "fecha_registro": FieldValue.serverTimestamp(),
      });

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
      }
    } on FirebaseAuthException catch (e) {
      showError(e.message);
    }
  }

  void showError(String? message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Error"),
        content: Text(message ?? "Ocurrió un error"),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Registro"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          // [cite: 3] Recomendado para evitar errores de overflow con el teclado
          child: Column(
            children: [
              TextField(
                controller: nombreController,
                decoration: const InputDecoration(labelText: "Nombre"),
              ),
              const SizedBox(height: 10),

              // [cite: 4] CAMBIOS EN EL CAMPO DE TELÉFONO
              TextField(
                controller: telefonoController,
                decoration: const InputDecoration(
                  labelText: "Teléfono",
                  hintText: "Ej: 1234567890",
                  counterText: "", // Oculta el contador visual si lo deseas
                ),
                keyboardType: TextInputType
                    .number, // [cite: 5] Muestra el teclado numérico
                maxLength: 10, // [cite: 6] Limita la escritura a 10 caracteres
                inputFormatters: [
                  FilteringTextInputFormatter
                      .digitsOnly, // [cite: 7] Bloquea letras y símbolos
                ],
              ),

              const SizedBox(height: 10),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(labelText: "Email"),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: passwordController,
                decoration: const InputDecoration(labelText: "Contraseña"),
                obscureText: true,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: registerUser,
                child: const Text("Registrarse"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
