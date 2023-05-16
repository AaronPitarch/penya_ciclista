import 'package:flutter/material.dart';
import 'package:penya_ciclista/models/ruta_mode.dart';
import 'package:penya_ciclista/services/ruta_service.dart';


class RutasPage extends StatelessWidget {
  const RutasPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rutas'),
        centerTitle: true,
      ),

      body: Container(
        child: FutureBuilder<List<Ruta>>(
          future: RutasService.getAllRutas(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              final rutas = snapshot.data;
              return ListView.builder(
                itemCount: rutas?.length,
                itemBuilder: (context, index) {
                  final ruta = rutas![index];
                  return Card(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Fila 1
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: Text(
                                ruta.titulo,
                                style: const TextStyle(fontWeight: FontWeight.bold),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Text(
                              '${ruta.fecha.day}/${ruta.fecha.month}/${ruta.fecha.year}',
                            ),
                          ],
                        ),
                        // Fila 2
                        Row(
                          children: [
                            Text('KM: ${ruta.kilometros}'),
                            const SizedBox(width: 16),
                            Text('DESNIVELL: ${ruta.desnivel}'),
                            const SizedBox(width: 16),
                            Text('PUNTOS: ${ruta.puntos}'),
                          ],
                        ),
                        // Fila 3
                        Column(
                          children: [
                            Image.network(
                              ruta.imagen,
                              height: 200,
                              fit: BoxFit.cover,
                              errorBuilder: (BuildContext context, Object exception, StackTrace? stackTrace) {
                                return const Text('Error al cargar la imagen');
                              },
                            ),
                            const SizedBox(height: 16),
                            Text(ruta.descripcion),
                          ],
                        ),
                        // Fila 4
                        Row(
                          children: [
                            const Text('ALTERNATIU:', style: TextStyle(fontWeight: FontWeight.bold)),
                            const SizedBox(width: 16),
                            Text(ruta.alternativo),
                          ],
                        ),
                        // Fila 5
                        Text(
                          ruta.alternativo,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  );
                },
              );
            } else if (snapshot.hasError) {
              return const Center(
                child: Text('Ha ocurrido un error'),
              );
            } else {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
          },
        ),
      ),
    );
  }
}