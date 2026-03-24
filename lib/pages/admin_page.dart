import 'package:flutter/material.dart';
import 'package:eliteform/widgets/users_list.dart';
import '../services/auth_service.dart';
import 'login_page.dart';

class AdminPage extends StatelessWidget {
  const AdminPage({super.key});

  // Usamos el servicio de autenticación centralizado
  Future<void> _logout(BuildContext context) async {
    final authService = AuthService();
    await authService.logout();

    if (context.mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Panel de Administrador"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _logout(context),
          ),
        ],
      ),
      // Sin 'const' y con el nombre exacto de la clase
      body: UsersList(),
    );
  }
}
