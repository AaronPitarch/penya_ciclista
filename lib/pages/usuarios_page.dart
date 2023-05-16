import 'package:flutter/material.dart';
import 'package:penya_ciclista/models/user_model.dart';
import 'package:penya_ciclista/services/usuarios_service.dart';

class UsuariosPage extends StatelessWidget {
  const UsuariosPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Usuarios'),
        centerTitle: true,
        //backgroundColor: Colors.black,
      ),

      body: FutureBuilder<List<Usuario>>(
        future: UsuariosService.todosUsuarios(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasData) {
              List<Usuario> usuarios = snapshot.data!;
              return ListView.builder(
                itemCount: usuarios.length,
                itemBuilder: (context, index) {

                  Widget icono;
                    if (index == 0) {
                      icono = const Icon(Icons.emoji_events, color: Colors.yellow);
                    } else if (index == 1) {
                      icono = const Icon(Icons.emoji_events, color: Colors.grey);
                    } else if (index == 2) {
                      icono = const Icon(Icons.emoji_events, color: Colors.brown);
                    } else {
                      icono = const SizedBox(width: 24); // Espacio en blanco si no está en el top 3
                    }

                  return Card(
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundImage: NetworkImage(usuarios[index].imagen),
                      ),
                      title: Text(usuarios[index].nombre),
                      subtitle: Text('Puntos: ${usuarios[index].puntos}'),
                      trailing: icono,
                    ),
                  );
                },
              );
            } else if (snapshot.hasError) {
              return const Center(
                child: Text('Error al obtener usuarios'),
              );
            }
          }

          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }
}