
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DrawerMenu extends StatefulWidget {
  const DrawerMenu({super.key});

  @override
  State<DrawerMenu> createState() => _DrawerMenuState();
}

class _DrawerMenuState extends State<DrawerMenu> {
  Map<String, dynamic>? userData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (userDoc.exists) {
          setState(() {
            userData = userDoc.data();
            isLoading = false;
          });
        }
      }
    } catch (e) {
      print('Error al obtener datos del usuario: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
  return Drawer(
    child: isLoading
        ? const Center(child: CircularProgressIndicator())
        : ListView(
            padding: EdgeInsets.zero,
            children: [
              UserAccountsDrawerHeader(
                accountName: Text(userData?['name'] ?? 'Nombre no disponible'),
                accountEmail: Text(userData?['email'] ?? 'Correo no disponible'),
                currentAccountPicture: CircleAvatar(
                  backgroundImage: const AssetImage('assets/images/default_profile.jpg')
                          as ImageProvider,
                  
                ),
              ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Perfil'),
            onTap: () {
              // Acción para el perfil
            },
          ),
          ListTile(
            leading: const Icon(Icons.dashboard),
            title: const Text('Dashboard'),
       /*     onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const DashboardPage()),
              );
            },*/
          ),
          
        
         
          Divider(),
          ListTile(
            leading: const Icon(Icons.exit_to_app),
            title: const Text('Cerrar Sesión'),
            onTap: () {
              FirebaseAuth.instance.signOut();
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
    );
  }
}
