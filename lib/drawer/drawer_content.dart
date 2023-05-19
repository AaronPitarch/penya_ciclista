import 'package:flutter/material.dart';

import 'package:penya_ciclista/drawer/drawer_item.dart';
import 'package:penya_ciclista/models/user_model.dart';
import 'package:penya_ciclista/pages/configuraciones_page.dart';
import 'package:penya_ciclista/pages/galeria_page.dart';
import 'package:penya_ciclista/pages/login_page.dart';
import 'package:penya_ciclista/pages/rutas_page.dart';
import 'package:penya_ciclista/pages/usuarios_page.dart';

// Importaciones de Firebase
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DrawerContent extends StatefulWidget {
  DrawerContent({Key? key}) : super(key: key);

  @override
  State<DrawerContent> createState() => _DrawerContentState();
}

class _DrawerContentState extends State<DrawerContent> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String name = '';
  String email = '';
  String imageUrl = '';

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  void loadUserData() async {
    final user = _auth.currentUser;

    if (user != null) {
      name = user.displayName ?? '';
      email = user.email ?? '';

      final doc = await _firestore.collection('usuarios').doc(user.uid).get(); // Espera a que se obtenga el documento

      if (doc.exists) {
        setState(() {
          imageUrl = doc.data()?['image'] ?? '';
          name = doc.data()?['name'] ?? '';
        });
      }

      setState(() {}); // Actualiza el estado después de obtener los datos
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Material(
        color: Colors.black,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24.0, 80, 24, 0),
          child: Column(
            children: [
              headerWidget(),
              const SizedBox(height: 40,),

              const Divider(thickness: 1, height: 10, color: Colors.grey),

              const SizedBox(height: 40,),
              DrawerItem(
                name: 'Usuarios',
                icon: Icons.people,
                onPressed: () => onItemPressed(context, index: 0),
              ),

              const SizedBox(height: 30,),
              DrawerItem(
                name: 'Rutas',
                icon: Icons.directions_bike,
                onPressed: () => onItemPressed(context, index: 1),
              ),

              const SizedBox(height: 30,),
              DrawerItem(
                name: 'Galeria',
                icon: Icons.collections,
                onPressed: () => onItemPressed(context, index: 2),
              ),

              const SizedBox(height: 30,),
              DrawerItem(
                name: 'Noticias',
                icon: Icons.notifications,
                onPressed: () => onItemPressed(context, index: 3),
              ),

              const SizedBox(height: 30,),
              const Divider(thickness: 1, height: 10, color: Colors.grey,),

              const SizedBox(height: 30,),
              DrawerItem(
                name: 'Configuraciones',
                icon: Icons.settings,
                onPressed: () => onItemPressed(context, index: 4),
              ),

              const SizedBox(height: 30,),
              DrawerItem(
                name: 'Cerrar sesion',
                icon: Icons.logout,
                onPressed: () => onItemPressed(context, index: 5),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void onItemPressed(BuildContext context, {required int index}) {
    Navigator.pop(context);

    switch(index) {
      case 0:
        Navigator.push(context, MaterialPageRoute(builder: (context) => const UsuariosPage()));
        break;
      case 1:
        Navigator.push(context, MaterialPageRoute(builder: ((context) => const RutasPage())));
        break;
      case 2:
        Navigator.push(context, MaterialPageRoute(builder: ((context) => const GaleriaPage())));
        break;
      case 4:
        Navigator.push(context, MaterialPageRoute(builder: ((context) => const ConfiguracionesPage())));
        break;
      case 5:
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Cerrar sesión'),
              content: const Text('¿Estás seguro de que deseas cerrar sesión?'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); 
                    _auth.signOut(); // Cerrar sesión
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginPage())); // Volver a la página de inicio de sesión
                  },  
                  child: const Text('Sí'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); 
                  },
                  child: const Text('Cancelar'),
                ),
              ],
            );
          },
        );
        break;
      }
    }

  Widget headerWidget() {
    return Row(
      children: [
        CircleAvatar(
          radius: 40,
          backgroundImage: imageUrl.isNotEmpty ? NetworkImage(imageUrl) : null,
        ),

        const SizedBox(width: 20),

        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(name, style: const TextStyle(fontSize: 14, color: Colors.white)),

            const SizedBox(height: 10),

            Text(email, style: const TextStyle(fontSize: 14, color: Colors.white)),
          ],
        ),
      ],
    );
  }
}