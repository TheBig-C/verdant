import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:verdant/Models/PlantModel.dart';
import 'package:verdant/Pages/Plants/PlantDeailsPage.dart'; // Nueva página para mostrar los detalles de la planta
import 'package:firebase_auth/firebase_auth.dart';

class AddPlantPage extends StatefulWidget {
  @override
  _AddPlantPageState createState() => _AddPlantPageState();
}

class _AddPlantPageState extends State<AddPlantPage> {
  File? _image;
  final picker = ImagePicker();
  final _nameController = TextEditingController();
  final _additionalInfoController = TextEditingController();
  final _obtainedDateController = TextEditingController();
  final firestore = FirebaseFirestore.instance;
  bool isLoading = false;
  Future<void> _pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<List<String>> _identifyPlantSpecies(File image) async {
  const String apiKey = "0EHnHYM7Wah21ueekwfCRMnUqlgbao2n0v2GZWKu6W7sqoNmXp";
  const String url = "https://plant.id/api/v3/identification";

  try {
    // Convertir la imagen a Base64
    final bytes = await image.readAsBytes();
    final imageBase64 = base64Encode(bytes);

    // Configurar la solicitud
    final response = await http.post(
      Uri.parse(url),
      headers: {
        "Api-Key": apiKey,
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "images": ["data:image/jpg;base64,$imageBase64"],
        "similar_images": true,
      }),
    );

    // Manejo del response
    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body);

      // Verificar que la respuesta contiene resultados y sugerencias
      if (data.containsKey("result") && data["result"].containsKey("classification")) {
        final suggestions = data["result"]["classification"]["suggestions"] ?? [];
        if (suggestions.isNotEmpty) {
          // Extraer los nombres de las plantas
          return List<String>.from(suggestions.map((s) => s["name"] as String));
        } else {
          print("No se encontraron sugerencias para esta imagen.");
          return [];
        }
      } else {
        print("La respuesta no contiene información válida.");
        return [];
      }
    } else {
      print("Error de API (${response.statusCode}): ${response.body}");
      return [];
    }
  } catch (e) {
    print("Excepción al identificar la planta: $e");
    return [];
  }
}


Future<void> _savePlant() async {
  if (_image == null || _nameController.text.isEmpty || _obtainedDateController.text.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Por favor completa todos los campos obligatorios.")),
    );
    return;
  }

  setState(() {
    isLoading = true;
  });

  try {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception("El usuario no está autenticado");
    }

    // Identificar planta usando la API
    final plantResponse = await _identifyPlantSpecies(_image!);

    // Subir imagen a ImgBB
    final imageUrl = await _uploadImageToImgBB();
    if (imageUrl == null) {
      throw Exception('Error al subir la imagen a ImgBB');
    }

    // Crear objeto planta
    final plant = {
      "name": _nameController.text,
      "imageUrl": imageUrl,
      "obtainedDate": _obtainedDateController.text,
      "additionalInfo": _additionalInfoController.text,
      "userId": user.uid,
      "apiData": plantResponse, // Guardamos la respuesta completa de la API
    };

    // Guardar en Firebase Firestore
    await firestore.collection('plants').add(plant);

    print('Planta guardada exitosamente');

    // Navegar a detalles de la planta
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => PlantDetailsPage(plant: plant),
      ),
    );
  } catch (e) {
    print('Error al guardar la planta: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error al guardar la planta: ${e.toString()}')),
    );
  } finally {
    setState(() {
      isLoading = false;
    });
  }
}



  Future<String?> _uploadImageToImgBB() async {
    const String apiKey = '5358274ae3240cfc3668d8b0bea63efb';
    if (_image == null) return null;

    try {
      final uri = Uri.parse('https://api.imgbb.com/1/upload?key=$apiKey');
      final request = http.MultipartRequest('POST', uri)
        ..files.add(await http.MultipartFile.fromPath('image', _image!.path));

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final responseData = jsonDecode(responseBody);
        return responseData['data']['url'];
      }
    } catch (e) {
      print('Error al subir imagen: $e');
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Plant')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 150,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: _image == null
                      ? const Icon(Icons.add_photo_alternate, size: 50)
                      : Image.file(_image!, fit: BoxFit.cover),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Plant Name'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _obtainedDateController,
                decoration: const InputDecoration(
                  labelText: 'Obtained Date',
                  hintText: 'E.g., 2023-05-10',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _additionalInfoController,
                decoration: const InputDecoration(labelText: 'Additional Info'),
              ),
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: _savePlant,
                  child: const Text('Save Plant'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
