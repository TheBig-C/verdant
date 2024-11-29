import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:verdant/Pages/widgets/drawer_menu.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:verdant/Tema/AppColors.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  late String _userId;
  QueryDocumentSnapshot? _selectedPlant;

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
    return Padding(
      
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          if (_selectedPlant != null) buildPlantDetails(_selectedPlant!),
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
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(30),
      margin: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
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
                const Text(
                  'Información adicional:',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 10),
                Text(
                  plantData['additionalInfo'] ?? "No disponible",
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
