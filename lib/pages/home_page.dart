import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_page.dart';
import 'perfil_page.dart';
import 'rutina_page.dart';
import 'dieta_page.dart';
import 'ejercicios_page.dart';
import 'planes_page.dart';
import 'inicio_page.dart'; // ← NUEVO: pantalla de inicio
import 'qr_acceso_page.dart'; // ← NUEVO: QR de entrada/salida

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  // ORDEN: Inicio · Rutina · Dieta · Ejercicios · QR Acceso · Planes · Perfil
  final List<Widget> _pages = const [
    InicioPage(), // 0 - Página principal con contador y eventos
    RutinaPage(), // 1 - Rutinas
    DietaPage(), // 2 - Dietas
    EjerciciosPage(), // 3 - Ejercicios
    QrAccesoPage(), // 4 - QR de acceso al gym
    PlanesPage(), // 5 - Planes de membresía
    PerfilPage(), // 6 - Perfil del usuario
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();
    if (mounted) {
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
        title: const Text('EliteForm'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: logout,
          ),
        ],
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFF020617),
        selectedItemColor: Colors.orangeAccent,
        unselectedItemColor: Colors.white38,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed, // necesario para 7 ítems
        selectedFontSize: 10,
        unselectedFontSize: 10,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.fitness_center_outlined),
            activeIcon: Icon(Icons.fitness_center),
            label: 'Rutina',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.restaurant_outlined),
            activeIcon: Icon(Icons.restaurant),
            label: 'Dieta',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.sports_gymnastics_outlined),
            activeIcon: Icon(Icons.sports_gymnastics),
            label: 'Ejercicios',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.qr_code_outlined),
            activeIcon: Icon(Icons.qr_code),
            label: 'Acceso',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.card_membership_outlined),
            activeIcon: Icon(Icons.card_membership),
            label: 'Planes',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}
