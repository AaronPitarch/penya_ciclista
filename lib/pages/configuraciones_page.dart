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
  TextEditingController _passwordController = TextEditingController();
  String _imageURL = '';

  String defaultName = 'Usuario';
  String defaultImageUrl = 'URL de la imagen predeterminada';


  @override
  void initState() {
    super.initState();
    _nameController.text = defaultName;
    _passwordController.text = ''; // Obtén la contraseña actual del usuario y establece su valor en el controlador de texto
    getUserData();
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
          _imageURL = data['imagen'] ?? defaultImageUrl; // Establece la URL predeterminada si la URL de la imagen está vacía
        });
      }
    }
  }

  void updateProfile() async {
  User? user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    try {
      String newName = _nameController.text;
      String newPassword = _passwordController.text;

      if (newName.isNotEmpty) {
        await user.updateDisplayName(newName);
        await FirebaseFirestore.instance.collection('usuarios').doc(user.uid).update({
          'nombre': newName,
        });
      }

      if (newPassword.isNotEmpty) {
        await user.updatePassword(newPassword);
      }

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Datos actualizados'),
            content: Text('Se han actualizado los datos del perfil correctamente.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('Aceptar'),
              ),
            ],
          );
        },
      );
    } catch (e) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text('Hubo un error al actualizar los datos del perfil.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('Aceptar'),
              ),
            ],
          );
        },
      );
    }
  }
}
/*
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

        //print('Nombre actualizado exitosamente');
      } catch (e) {
        //print('Error al actualizar el nombre: $e');
      }
    }
  }*/

  void updateUserImage() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      final picker = ImagePicker();
      PickedFile? pickedFile = await picker.getImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        File imageFile = File(pickedFile.path);
        String userId = user.uid;
        Reference storageRef = FirebaseStorage.instance.ref().child('user_images/$userId.jpg');

        UploadTask uploadTask = storageRef.putFile(imageFile);
        TaskSnapshot snapshot = await uploadTask;

        String downloadURL = await snapshot.ref.getDownloadURL();

        await FirebaseFirestore.instance.collection('usuarios').doc(userId).update({
          'imagen': downloadURL,
        });

        setState(() {
          _imageURL = downloadURL;
        });

        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Imagen actualizada'),
              content: Text('Se ha actualizado la imagen de perfil correctamente.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('Aceptar'),
                ),
              ],
            );
          },
        );
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
              'Contraseña:',
              style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
            ),
            TextField(
              controller: _passwordController,
              obscureText: true,
            ),
            SizedBox(height: 16.0),
            Row(
              children: [
                Text(
                  'Imagen de perfil:',
                  style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                ),
                SizedBox(width: 8.0),
                ElevatedButton(
                  onPressed: updateUserImage,
                  child: Text('Actualizar imagen'),
                ),
              ],
            ),
            SizedBox(height: 8.0),
            Align(
              alignment: Alignment.center,
              child: Container(
                width: 200.0,
                height: 200.0,
                child: _imageURL.isNotEmpty ? Image.network(_imageURL, fit: BoxFit.cover) : Container(),
              ),
            ),

            SizedBox(height: 16.0),

            Align(
              alignment: Alignment.bottomCenter,
              child: ElevatedButton(
                onPressed: updateProfile,
                child: Text('Actualizar perfil'),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
}