import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UsersList extends StatelessWidget {
  const UsersList({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection("usuarios").snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(
            child: Text("Error cargando usuarios"),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text("No hay usuarios registrados"),
          );
        }

        final users = snapshot.data!.docs;

        return ListView.builder(
          itemCount: users.length,
          itemBuilder: (context, index) {
            var user = users[index];

            return Card(
              color: const Color(0xFF1E293B),
              margin: const EdgeInsets.all(10),
              child: ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Colors.transparent,
                  child: Icon(Icons.person, color: Colors.black),
                ),
                title: Text(
                  user["correo"],
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(user["id_usuario"]),
              ),
            );
          },
        );
      },
    );
  }
}
