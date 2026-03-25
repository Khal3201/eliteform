import 'package:flutter/material.dart';
import 'package:eliteform/widgets/users_list.dart';
import '../services/auth_service.dart';
import 'login_page.dart';
import 'admin_pedidos_page.dart';

class AdminPage extends StatelessWidget {
  const AdminPage({super.key});

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
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Panel de Administrador'),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () => _logout(context),
            ),
          ],
          bottom: const TabBar(
            indicatorColor: Colors.orangeAccent,
            labelColor: Colors.orangeAccent,
            unselectedLabelColor: Colors.white54,
            tabs: [
              Tab(
                icon: Icon(Icons.people_outline),
                text: 'Usuarios',
              ),
              Tab(
                icon: Icon(Icons.receipt_long_outlined),
                text: 'Pedidos',
              ),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            UsersList(),
            AdminPedidosPage(),
          ],
        ),
      ),
    );
  }
}
