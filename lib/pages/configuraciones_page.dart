import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ConfiguracionesPage extends StatefulWidget {
  const ConfiguracionesPage({super.key});

  @override
  State<ConfiguracionesPage> createState() => _ConfiguracionesPageState();
}

class _ConfiguracionesPageState extends State<ConfiguracionesPage> {

  TextEditingController _nameController = TextEditingController();
  String _imageURL = '';

  @override
  void initState() {
    super.initState();
    getUserData(); // Se obtiene los datos del usuario con la sesion iniciada
  }

  void getUserData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // Obtén el nombre del usuario
      _nameController.text = user.displayName ?? '';

      // Obtén la URL de la imagen del usuario desde Firestore
      DocumentSnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore.instance
        .collection('usuarios')
        .doc(user.uid)
        .get();

      if (snapshot.exists) {
        Map<String, dynamic> data = snapshot.data()!;
        setState(() {
          _imageURL = data['imageURL'] ?? '';
        });
      }
    }
  }

  void updateUserName() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        String newName = _nameController.text;
        await user.updateDisplayName(newName);

        // Actualiza el nombre del usuario en Firestore
        await FirebaseFirestore.instance.collection('usuarios').doc(user.uid).update({
          'nombre': newName,
        });

        print('Nombre actualizado exitosamente');
      } catch (e) {
        print('Error al actualizar el nombre: $e');
      }
    }
  }

  void updateUserImage() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      String userId = user.uid;
      Reference storageRef = FirebaseStorage.instance.ref().child('user_images/$userId.jpg');

      try {
        // Selecciona una imagen de la galería
        final picker = ImagePicker();
        PickedFile? pickedFile = await picker.getImage(source: ImageSource.gallery);

        if (pickedFile != null) {
          File imageFile = File(pickedFile.path);

          // Sube la imagen al almacenamiento de Firebase Storage
          UploadTask uploadTask = storageRef.putFile(imageFile);
          TaskSnapshot snapshot = await uploadTask;

          // Obtén la URL de descarga de la imagen
          String downloadURL = await snapshot.ref.getDownloadURL();

          // Guarda la URL de la imagen en la base de datos del usuario
          await FirebaseFirestore.instance.collection('usuarios').doc(userId).update({
            'imageURL': downloadURL,
          });

          print('Imagen de perfil actualizada exitosamente');
        }
      } catch (e) {
        print('Error al actualizar la imagen de perfil: $e');
      }
    }
  }

  void updateUserPassword() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        // Aquí debes implementar la lógica para solicitar y verificar la contraseña actual
        // antes de permitir la actualización de la contraseña
        // ...

        // Actualiza la contraseña
        await user.updatePassword('NuevaContraseña');

        print('Contraseña actualizada exitosamente');
      } catch (e) {
        print('Error al actualizar la contraseña: $e');
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Perfil de usuario'),
      ),

      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Nombre:',
                style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
              ),
              TextField(
                controller: _nameController,
              ),
              SizedBox(height: 16.0),
              Text(
                'Imagen de perfil:',
                style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
              ),
              _imageURL.isNotEmpty
                  ? Image.network(
                      _imageURL,
                      height: 100.0,
                    )
                  : Container(),
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: updateUserName,
                child: Text('Actualizar nombre'),
              ),
              ElevatedButton(
                onPressed: updateUserImage,
                child: Text('Actualizar imagen de perfil'),
              ),
              ElevatedButton(
                onPressed: updateUserPassword,
                child: Text('Actualizar contraseña'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}