import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_page.dart';
import 'perfil_page.dart';
import 'rutina_page.dart';
import 'dieta_page.dart';
import 'ejercicios_page.dart';
import 'planes_page.dart';
import 'inicio_page.dart';
import 'qr_acceso_page.dart';
import 'aviso_privacidad_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    InicioPage(),
    RutinaPage(),
    DietaPage(),
    EjerciciosPage(),
    QrAccesoPage(),
    PlanesPage(),
    PerfilPage(),
  ];

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  // LOGOUT SEGURO:
  // 1. FirebaseAuth.signOut() invalida el token JWT en el servidor de Firebase.
  // 2. Navigator.pushReplacement() limpia el stack de navegación completo,
  //    impidiendo que el usuario regrese a pantallas protegidas con el botón atrás.
  // 3. El check 'mounted' evita errores si el widget ya fue destruido.
  Future<void> logout() async {
    // Confirmación antes de cerrar sesión
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title:
            const Text('Cerrar sesión', style: TextStyle(color: Colors.white)),
        content: const Text(
          '¿Estás seguro de que quieres cerrar tu sesión?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child:
                const Text('Cancelar', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Cerrar sesión'),
          ),
        ],
      ),
    );

    if (confirmar != true) return;

    // Invalidar sesión en Firebase (servidor)
    await FirebaseAuth.instance.signOut();

    if (mounted) {
      // Limpiar el stack completo y redirigir a Login
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
          // Menú de opciones (tres puntos)
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            color: const Color(0xFF1E293B),
            onSelected: (value) {
              switch (value) {
                case 'privacidad':
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const AvisoPrivacidadPage()),
                  );
                  break;
                case 'logout':
                  logout();
                  break;
              }
            },
            itemBuilder: (context) => [
              // Opción: Aviso de Privacidad — acceso permanente
              const PopupMenuItem<String>(
                value: 'privacidad',
                child: Row(
                  children: [
                    Icon(Icons.privacy_tip_outlined,
                        color: Colors.orangeAccent, size: 18),
                    SizedBox(width: 10),
                    Text('Aviso de Privacidad',
                        style: TextStyle(color: Colors.white)),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              // Opción: Cerrar sesión
              const PopupMenuItem<String>(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, color: Colors.redAccent, size: 18),
                    SizedBox(width: 10),
                    Text('Cerrar sesión',
                        style: TextStyle(color: Colors.redAccent)),
                  ],
                ),
              ),
            ],
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
        type: BottomNavigationBarType.fixed,
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
