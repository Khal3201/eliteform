import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'login_page.dart';

class PerfilPage extends StatefulWidget {
  const PerfilPage({super.key});

  @override
  State<PerfilPage> createState() => _PerfilPageState();
}

class _PerfilPageState extends State<PerfilPage> {
  final nombreController = TextEditingController();
  final telefonoController = TextEditingController();
  final emailController = TextEditingController();

  bool editando = false;
  bool loading = true;

  Future cargarDatos() async {
    final user = FirebaseAuth.instance.currentUser;

    final doc = await FirebaseFirestore.instance
        .collection("usuarios")
        .doc(user!.uid)
        .get();

    nombreController.text = doc["nombre"];
    telefonoController.text = doc["telefono"];
    emailController.text = user.email ?? "";
    setState(() {
      loading = false;
    });
  }

  Future actualizarPerfil() async {
    if (telefonoController.text.length != 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("El teléfono debe tener exactamente 10 dígitos")),
      );
      return; // Detiene la ejecución
    }
    // -----------------------

    final user = FirebaseAuth.instance.currentUser;

    await FirebaseFirestore.instance
        .collection("usuarios")
        .doc(user!.uid)
        .update({
      "nombre": nombreController.text.trim(),
      "telefono": telefonoController.text.trim(),
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Perfil actualizado")),
    );
  }

  Future eliminarCuenta() async {
    final user = FirebaseAuth.instance.currentUser;

    bool confirmar = await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Eliminar cuenta"),
            content: const Text(
                "Esta acción eliminará tu cuenta permanentemente. ¿Continuar?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text("Cancelar"),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text(
                  "Eliminar",
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
        ) ??
        false;

    if (!confirmar) return;

    try {
      await FirebaseFirestore.instance
          .collection("usuarios")
          .doc(user!.uid)
          .delete();

      await user.delete();

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No se pudo eliminar la cuenta")),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    cargarDatos();
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }

    final user = FirebaseAuth.instance.currentUser;

    return Padding(
      padding: const EdgeInsets.all(20),
      child: SingleChildScrollView(
        child: Column(
          children: [
            const Icon(
              Icons.person,
              size: 100,
              color: Colors.orangeAccent,
            ),
            const SizedBox(height: 20),
            if (!editando) ...[
              ListTile(
                leading: const Icon(Icons.badge),
                title: const Text("Nombre"),
                subtitle: Text(nombreController.text),
              ),
              const SizedBox(height: 10),
              ListTile(
                leading: const Icon(Icons.phone),
                title: const Text("Teléfono"),
                subtitle: Text(telefonoController.text),
              ),
              const SizedBox(height: 10),
              ListTile(
                leading: const Icon(Icons.email),
                title: const Text("Correo"),
                subtitle: Text(user!.email ?? ""),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      editando = true;
                    });
                  },
                  child: const Text("Editar perfil"),
                ),
              ),
              const SizedBox(height: 15),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: eliminarCuenta,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text("Eliminar cuenta"),
                ),
              ),
            ],
            if (editando) ...[
              TextField(
                controller: nombreController,
                decoration: const InputDecoration(
                  labelText: "Nombre",
                  prefixIcon: Icon(Icons.badge),
                ),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: telefonoController,
                keyboardType: TextInputType.number,
                maxLength: 10,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(
                  labelText: "Teléfono",
                  prefixIcon: Icon(Icons.phone),
                  counterText:
                      "", // Esto oculta el contador "0/10" para no alterar diseño
                ),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: emailController,
                enabled: false, // Mantiene el campo bloqueado
                decoration: const InputDecoration(
                  labelText: "Correo electrónico",
                  prefixIcon: Icon(Icons.email),
                ),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    await actualizarPerfil();

                    setState(() {
                      editando = false;
                    });
                  },
                  child: const Text("Guardar cambios"),
                ),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    editando = false;
                  });
                },
                child: const Text("Cancelar"),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
