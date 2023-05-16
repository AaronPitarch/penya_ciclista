import 'package:flutter/material.dart';
import 'package:penya_ciclista/models/noticias_model.dart';

class DetalleNoticiaPage extends StatelessWidget {
  final Noticia noticia;

  const DetalleNoticiaPage({super.key, required this.noticia});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(noticia.titulo),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.network(noticia.imagen),
              const SizedBox(height: 16.0),
              Text(noticia.titulo, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8.0),
              Text(noticia.fecha.toString(), style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 16.0),
              Text(noticia.descripcion, style: const TextStyle(fontSize: 18),
              ),
            ],
          ),
        ),
      )
    );
  }
}