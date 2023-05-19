import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';

import 'package:penya_ciclista/drawer/drawer_content.dart';
import 'package:penya_ciclista/models/noticias_model.dart';
import 'package:penya_ciclista/pages/detalleNoticia_page.dart';
import 'package:penya_ciclista/services/noticias_service.dart';

// Importaciones de firebase
import 'package:firebase_auth/firebase_auth.dart';

class HomePage extends StatelessWidget {
  HomePage({super.key});

  final NoticiasService noticiasService = NoticiasService();

  @override
  Widget build(BuildContext context) {

    final user = FirebaseAuth.instance.currentUser;
    final imageUrl = user?.photoURL;

    return Scaffold(
      drawer: DrawerContent(),
      appBar: AppBar(
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: CircleAvatar(
              backgroundImage: imageUrl != null ? NetworkImage(imageUrl) : null,
            ),
          ),
        ],
      ),

      body: FutureBuilder<List<Noticia>>(
        future: NoticiasService.getNoticias(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    // Navegar a la pantalla de la noticia completa y pasar los detalles de la noticia
                    Navigator.push(context, MaterialPageRoute(
                      builder: (context) => DetalleNoticiaPage(noticia: snapshot.data![index]),
                      ),
                    );
                  },
                  child: Card(
                    child: Column(
                      children: [
                        Image.network(snapshot.data![index].imagen),
                        ListTile(title: Text(snapshot.data![index].titulo)),
                      ],
                    ),
                  ),
                );
              },
            );
          } else if (snapshot.hasError) {
            return const Center(
              child: Text('Error al obtener las noticias'),
            );
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }
}