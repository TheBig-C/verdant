import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:verdant/Pages/Plants/PlantDeailsPage.dart';
import 'package:verdant/Pages/Plants/AllPlantsPage.dart';
import 'package:verdant/Pages/widgets/drawer_menu.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:verdant/Tema/AppColors.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  late String _userId;
  QueryDocumentSnapshot? _selectedPlant;
   int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _userId = _auth.currentUser?.uid ?? "";
  }

  Stream<QuerySnapshot> _getUserPlants() {
    return _firestore.collection('plants').where('userId', isEqualTo: _userId).snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.principalGreen,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center, // Esto centra el contenido en el AppBar
          children: [
            Image.asset('assets/images/LogoPrincipal.png',height: 50,),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: const [
                Icon(Icons.whatshot, color: Colors.white),
                SizedBox(width: 5),
                Text('12', style: TextStyle(color: Colors.white)),
              ],
            ),
          ),
        ],
      ),
      drawer: const DrawerMenu(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Parte superior con detalles de la planta seleccionada
            if (_selectedPlant != null) 
              buildPlantDetails(_selectedPlant!),
            const SizedBox(height: 20),
            Text(
              DateFormat('dd MMM, yyyy').format(DateTime.now()),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Your plants this week',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: StreamBuilder<QuerySnapshot>(
                      stream: _getUserPlants(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const Center(child: CircularProgressIndicator());
                        }

                        final plants = snapshot.data!.docs;

                        if (plants.isEmpty) {
                          return const Center(
                            child: Text('No plants to display'),
                          );
                        }

                        return GridView.builder(
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                          ),
                          itemCount: plants.length,
                          itemBuilder: (context, index) {
                            final plant = plants[index];
                            return buildPlantThumbnail(plant);
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/add-plant');
        },
        backgroundColor: AppColors.principalGreen,
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex, 
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
          if (index == 0) { 
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AllPlantsPage()),
            );
          }
          if (index == 1) { 
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AllPlantsPage()),
            );
          }
          if (index == 2) { 
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AllPlantsPage()),
            );
          }
          
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.eco), label: ''),
        ],
      ),

    );
  }

  Widget buildCarouselItem(QueryDocumentSnapshot plant) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPlant = plant;
        });
      },
      child: Container(
        width: 100,
        margin: const EdgeInsets.symmetric(horizontal: 8.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.0),
          image: DecorationImage(
            image: NetworkImage(plant['imageUrl']),
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }

  Widget buildPlantThumbnail(QueryDocumentSnapshot plant) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPlant = plant;
        });
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.0),
          image: DecorationImage(
            image: NetworkImage(plant['imageUrl']),
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }

  Widget buildPlantDetails(QueryDocumentSnapshot plant) {
    final plantData = plant.data() as Map<String, dynamic>;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 12, 
            offset: Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(30),
      margin: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.topCenter, 
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16.0),
                child: Image.network(
                  plantData['imageUrl'] ?? '',
                  height: 220,
                  width: 180,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                top: -20, 
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 7),
                  decoration: BoxDecoration(
                    color: AppColors.darkGreen,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    plantData['name'] ?? 'Unnamed Plant',
                    style: const TextStyle(
                      fontSize: 16, 
                      fontWeight: FontWeight.normal,
                      color: Colors.white, 
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(width: 16), 

          Expanded( 
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Fecha de obtención: ${plantData['obtainedDate'] ?? "No registrada"}',
                  style: const TextStyle(fontSize: 13, color: Colors.grey),
                ),
                const SizedBox(height: 8),
                Text(
                  'Especie: ${plantData['species'] ?? "No disponible"}',
                  style: const TextStyle(fontSize: 13, fontStyle: FontStyle.italic),
                ),
                const SizedBox(height: 20),

                Text(
                  'Información adicional:',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 10),
                Text(
                  plantData['additionalInfo'] ?? "No disponible",
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 10),

                // Detalles de Trefle (si existen)
                if (plantData['trefleData'] != null) ...[
                  const Text(
                    'Detalles de la planta:',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  if (plantData['trefleData']['family'] != null)
                    Text('Familia: ${plantData['trefleData']['family']}',
                        style: const TextStyle(fontSize: 14)),
                  if (plantData['trefleData']['genus'] != null)
                    Text('Género: ${plantData['trefleData']['genus']}',
                        style: const TextStyle(fontSize: 14)),
                  if (plantData['trefleData']['common_name'] != null)
                    Text('Nombre común: ${plantData['trefleData']['common_name']}',
                        style: const TextStyle(fontSize: 14)),
                  if (plantData['trefleData']['edible_part'] != null)
                    Text(
                        'Partes comestibles: ${plantData['trefleData']['edible_part'].join(", ")}',
                        style: const TextStyle(fontSize: 14)),
                  const SizedBox(height: 20),
                  if (plantData['trefleData']['vegetation_type'] != null)
                    Text(
                        'Tipo de vegetación: ${plantData['trefleData']['vegetation_type']}',
                        style: const TextStyle(fontSize: 14)),
                  if (plantData['trefleData']['duration'] != null)
                    Text('Duración: ${plantData['trefleData']['duration']}',
                        style: const TextStyle(fontSize: 14)),
                ] else
                  const Text(
                    "No se encontraron detalles adicionales.",
                    style: TextStyle(fontSize: 14, color: AppColors.principalGreen),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }


}