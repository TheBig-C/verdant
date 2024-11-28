import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class PlantDetailsPage extends StatefulWidget {
  final dynamic plant;

  const PlantDetailsPage({Key? key, required this.plant}) : super(key: key);

  @override
  _PlantDetailsPageState createState() => _PlantDetailsPageState();
}

class _PlantDetailsPageState extends State<PlantDetailsPage> {
  Map<String, dynamic>? trefleData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchTrefleData(widget.plant.data()['name']); // Usamos el nombre de la planta
  }

  // Llamada a la API de Trefle
  Future<void> fetchTrefleData(String plantName) async {
    const String apiKey = "ZK4U75wLpdwDDmqOPC3mP9sxhc1d6wMggD46IprrLTg"; // Reemplaza con tu API Key
    final String url = "https://trefle.io/api/v1/plants/search?token=$apiKey&q=$plantName";

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['data'] != null && data['data'].isNotEmpty) {
          setState(() {
            trefleData = data['data'][0]; // Tomamos la primera coincidencia
            isLoading = false;
          });
        } else {
          setState(() {
            isLoading = false; // No se encontraron resultados
          });
        }
      } else {
        throw Exception("Error al obtener datos de Trefle");
      }
    } catch (e) {
      print(e);
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final plantData = widget.plant.data();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalles de la Planta'),
        backgroundColor: const Color(0xFF4CAF50),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Imagen destacada
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      plantData['imageUrl'],
                      height: 250,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Información básica
                  Text(
                    plantData['name'] ?? "Nombre desconocido",
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  
                  const SizedBox(height: 10),
                  Text(
                    'Fecha de obtención: ${plantData['obtainedDate'] ?? "No registrada"}',
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 20),

                  // Información adicional
                  Text(
                    'Información adicional:',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    plantData['additionalInfo'] ?? "No disponible",
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Especie: ${plantData['species'][0]}' ?? "No disponible",
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 20),

                  // Detalles de Trefle (si existen)
                  if (trefleData != null) ...[
                    const Text(
                      'Detalles de la planta:',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    if (trefleData?['family'] != null)
                      Text('Familia: ${trefleData!['family']}', style: const TextStyle(fontSize: 16)),
                    if (trefleData?['genus'] != null)
                      Text('Género: ${trefleData!['genus']}', style: const TextStyle(fontSize: 16)),
                    if (trefleData?['common_name'] != null)
                      Text('Nombre común: ${trefleData!['common_name']}', style: const TextStyle(fontSize: 16)),
                    if (trefleData?['edible_part'] != null)
                      Text('Partes comestibles: ${trefleData!['edible_part'].join(", ")}',
                          style: const TextStyle(fontSize: 16)),
                    const SizedBox(height: 20),
                    if (trefleData?['vegetation_type'] != null)
                      Text('Tipo de vegetación: ${trefleData!['vegetation_type']}',
                          style: const TextStyle(fontSize: 16)),
                    if (trefleData?['duration'] != null)
                      Text('Duración: ${trefleData!['duration']}',
                          style: const TextStyle(fontSize: 16)),
                  ] else
                    const Text(
                      "No se encontraron detalles adicionales.",
                      style: TextStyle(fontSize: 16, color: Colors.redAccent),
                    ),
                ],
              ),
            ),
    );
  }
}
