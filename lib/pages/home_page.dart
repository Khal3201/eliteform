import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_page.dart';
import 'perfil_page.dart';
import 'rutina_page.dart';
import 'dieta_page.dart';
import 'ejercicios_page.dart';
import 'eventos_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    RutinaPage(),
    DietaPage(),
    EjerciciosPage(),
    EventosPage(),
    PerfilPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future logout() async {
    await FirebaseAuth.instance.signOut();

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("EliteForm"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: logout,
          )
        ],
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFF020617),
        selectedItemColor: Colors.orangeAccent,
        unselectedItemColor: Colors.white54,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.fitness_center),
            label: "Rutina",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.restaurant),
            label: "Dieta",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.sports_gymnastics),
            label: "Ejercicios",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.event),
            label: "Eventos",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "Perfil",
          ),
        ],
      ),
    );
  }
}
