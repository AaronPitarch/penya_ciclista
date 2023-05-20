import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:penya_ciclista/pages/home_page.dart';
import 'package:penya_ciclista/services/usuarios_service.dart';

// Importaciones Firebase
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;


class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _imagePath;

  Future<void> _registerUser() async {
    try {
      if (_formKey.currentState!.validate()) {
          // Accede al servicio de autenticación de Firebase
          FirebaseAuth _auth = FirebaseAuth.instance;

          // Crea un nuevo usuario con correo y contraseña
          final UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
          );

          // Guarda nombre, puntos en la base de datos
          final user = userCredential.user;
          if (user != null) {
            await FirebaseFirestore.instance.collection('usuarios').doc(user.uid).set({
              'nombre': _nameController.text.trim(),
              'puntos': 0,
            });

            // Si se seleccionó una imagen, sube la imagen a Firebase Storage
            if (_imagePath != null) {
              String imagePath = await ImageUploadService.uploadImageToStorage(_imagePath!, user.uid);
              await FirebaseFirestore.instance.collection('usuarios').doc(user.uid).update({
                'imagen': imagePath,
              });
            }
          }

          _emailController.clear();
          _passwordController.clear();

          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomePage()));

        } else {
          // Muestra un SnackBar persistente con un botón de acción
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Por favor, completa todos los campos'),
              action: SnackBarAction(
                label: 'Cerrar',
                onPressed: () {
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                },
              ),
            ),
          );
        }
      } catch (e) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Error'),
              content: Text(e.toString()),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      }
    }
/*
    Future<String> _uploadImageToStorage(String imagePath, String userId) async {
      try {
        File imageFile = File(imagePath);
      String fileName = 'user_images/$userId.jpg';

      firebase_storage.Reference storageRef = firebase_storage.FirebaseStorage.instance.ref().child(fileName);
    firebase_storage.UploadTask uploadTask = storageRef.putFile(imageFile);
    firebase_storage.TaskSnapshot snapshot = await uploadTask;
    String downloadURL = await snapshot.ref.getDownloadURL();

    return downloadURL;

      } catch (e) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Error'),
              content: Text(e.toString()),
              actions: [
                TextButton(
                  onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }*/

  // Abrir la galeria o la camara para foto de usuario
  Future<void> _selectImage() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Seleccionar imagen'),
          content: SingleChildScrollView(
            child: ListBody(
              children: [
                GestureDetector(
                  child: const Text('Hacer una foto'),
                  onTap: () async {
                    final picker = ImagePicker();
                    final pickedFile = await picker.pickImage(
                      source: ImageSource.camera,
                    );
                    if (pickedFile != null) {
                      setState(() {
                        _imagePath = pickedFile.path;
                      });
                      Navigator.pop(context);
                    }
                  },
                ),

                const SizedBox(height: 16.0),

                GestureDetector(
                  child: const Text('Seleccionar de la galería'),
                  onTap: () async {
                    final picker = ImagePicker();
                    final pickedFile = await picker.pickImage(
                      source: ImageSource.gallery,
                    );
                    if (pickedFile != null) {
                      setState(() {
                        _imagePath = pickedFile.path;
                      });
                      Navigator.pop(context);
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registro'),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Form(
            key: _formKey,
            child: SingleChildScrollView( // Agregar SingleChildScrollView aquí
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Nombre y apellido'),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Por favor, ingresa tu nombre';
                      }
                      return null;
                    },
                  ),
        
                  const SizedBox(height: 16.0),
        
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(labelText: 'Correo electrónico'),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Por favor, ingresa tu correo electrónico';
                      }
                      return null;
                    },
                  ),
        
                  const SizedBox(height: 16.0),
        
                  TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(labelText: 'Contraseña'),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Por favor, ingresa tu contraseña';
                      }
                      return null;
                    },
                  ),
        
                  const SizedBox(height: 16.0),
        
                  ElevatedButton(
                    onPressed: () async {
                      await _selectImage();
                    },
                    child: const Text('Seleccionar imagen'),
                  ),
        
                  if (_imagePath != null)
                    Container(
                      margin: const EdgeInsets.only(top: 16.0),
                      child: Image.file(
                        File(_imagePath!),
                        fit: BoxFit.cover,
                        width: 200.0,
                        height: 200.0,
                      ),
                    ),
        
                  const SizedBox(height: 32.0),
        
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        FocusScope.of(context).unfocus();
                        _registerUser();
                      }
                    },
                    child: const Text('Registrarse'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}