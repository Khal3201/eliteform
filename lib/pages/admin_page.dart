import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../widgets/users_list.dart';
import 'login_page.dart';
import 'admin_pedidos_page.dart';
import 'admin_contenido_page.dart';
import 'gym_monitor_page.dart'; // ← NUEVO

class AdminPage extends StatelessWidget {
  const AdminPage({super.key});

  Future<void> _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    if (context.mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5, // ← ahora 5 tabs (agregamos Monitor)
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
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            indicatorColor: Colors.orangeAccent,
            labelColor: Colors.orangeAccent,
            unselectedLabelColor: Colors.white54,
            tabs: [
              Tab(icon: Icon(Icons.people_outline), text: 'Usuarios'),
              Tab(icon: Icon(Icons.receipt_long_outlined), text: 'Pedidos'),
              Tab(icon: Icon(Icons.fitness_center_outlined), text: 'Rutinas'),
              Tab(icon: Icon(Icons.restaurant_outlined), text: 'Dietas'),
              Tab(icon: Icon(Icons.monitor_heart_outlined), text: 'Monitor'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            UsersList(),
            AdminPedidosPage(),
            AdminRutinasPage(),
            AdminDietasPage(),
            GymMonitorPage(),
          ],
        ),
      ),
    );
  }
}
