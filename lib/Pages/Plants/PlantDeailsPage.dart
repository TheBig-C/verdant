import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PlantDetailsPage extends StatefulWidget {
  final Map<String, dynamic> plant;

  const PlantDetailsPage({required this.plant});

  @override
  _PlantDetailsPageState createState() => _PlantDetailsPageState();
}

class _PlantDetailsPageState extends State<PlantDetailsPage> {
  final String _apiKey = "8cd6995d-a404-4f2c-bbb0-0eec439d82d3";
  final String _apiUrl = "https://api.sambanova.ai/v1/chat/completions";
  String _generatedDescription = "Cargando información sobre la planta...";

  @override
  void initState() {
    super.initState();
    _generatePlantDescription();
  }

Map<String, dynamic>? _getMostProbablePlant(List<dynamic> apiData) {
  if (apiData.isEmpty) return null;

  // Mapear la lista de datos en mapas de tipo `Map<String, dynamic>`
  final suggestions = apiData.map<Map<String, dynamic>>((item) {
    if (item is Map) {
      return item.map<String, dynamic>(
          (key, value) => MapEntry(key.toString(), value));
    }
    return {};
  }).toList();

  // Ordenar por probabilidad
  suggestions.sort((a, b) => (b['probability'] ?? 0.0).compareTo(a['probability'] ?? 0.0));

  return suggestions.isNotEmpty ? suggestions.first : null;
}

Future<void> _generatePlantDescription() async {
  final apiData = widget.plant['apiData'] ?? {};
  final mostProbablePlant = _getMostProbablePlant(apiData);

  if (mostProbablePlant == null) {
    setState(() {
      _generatedDescription = "No se pudo generar información sobre la planta.";
    });
    return;
  }

  try {
    final response = await http.post(
      Uri.parse(_apiUrl),
      headers: {
        'Authorization': 'Bearer $_apiKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        "model": "Meta-Llama-3.1-8B-Instruct",
        "messages": [
          {
            "role": "system",
            "content": _generateContextPrompt(mostProbablePlant),
          }
        ],
        "temperature": 0.7,
        "top_p": 0.9,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final description = data['choices'][0]['message']['content'];

      setState(() {
        _generatedDescription = description;
      });
    } else {
      throw Exception("Error al obtener la descripción de la planta.");
    }
  } catch (e) {
    setState(() {
      _generatedDescription = "Error al generar la descripción: $e";
    });
  }
}


  String _generateContextPrompt(Map<String, dynamic> plantData) {
    final name = plantData['name'] ?? "Desconocido";
    final probability = (plantData['probability'] ?? 0.0) * 100;
    final similarImages = plantData['similar_images'] ?? [];

    return """
Eres un bot especializado en proporcionar información sobre plantas. Basándote en los datos disponibles, escribe una descripción general sobre esta planta:
- Nombre científico: $name
- Probabilidad de identificación: ${probability.toStringAsFixed(2)}%
- Imágenes similares disponibles: ${similarImages.isNotEmpty ? "Sí" : "No"}

Describe de manera general dónde se descubrió esta planta, su importancia botánica y usos comunes si es aplicable.
""";
  }


  @override
  Widget build(BuildContext context) {
    final apiData = widget.plant['apiData'] ?? {};
    final mostProbablePlant = _getMostProbablePlant(apiData);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.plant['name'] ?? "Detalles de la Planta"),
        backgroundColor: const Color(0xFF4CAF50),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.plant['imageUrl'] != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  widget.plant['imageUrl'],
                  height: 300,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            const SizedBox(height: 20),

            Text(
              widget.plant['name'] ?? "Nombre desconocido",
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            Text(
              'Fecha de obtención: ${widget.plant['obtainedDate'] ?? "No registrada"}',
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 20),

            const Text(
              'Descripción general:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              _generatedDescription,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),

            const Text(
              'Clasificación detallada:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            if (mostProbablePlant != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    mostProbablePlant['name'] ?? "Especie desconocida",
                    style: const TextStyle(
                      fontSize: 16,
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  if (mostProbablePlant['similar_images'] != null)
                    SizedBox(
                      height: 200,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: mostProbablePlant['similar_images'].length,
                        itemBuilder: (context, index) {
                          final image = mostProbablePlant['similar_images'][index];
                          return Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.network(
                                image['url'] ?? '',
                                width: 150,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return const Icon(Icons.broken_image);
                                },
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                ],
              )
            else
              const Text(
                "No se encontraron datos detallados.",
                style: TextStyle(fontSize: 16, color: Colors.redAccent),
              ),
          ],
        ),
      ),
    );
  }
}
