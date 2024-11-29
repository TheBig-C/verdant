import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:verdant/Pages/Plants/PlantDeailsPage.dart';
import 'package:verdant/Pages/widgets/drawer_menu.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:verdant/Tema/AppColors.dart';

import 'package:verdant/Pages/home_page.dart';
import 'package:verdant/Pages/CalendarPage.dart';

class AllPlantsPage extends StatefulWidget {
  const AllPlantsPage({super.key});

  @override
  _AllPlantsPageState createState() => _AllPlantsPageState();
}

class _AllPlantsPageState extends State<AllPlantsPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  int _selectedIndex = 2; 
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
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.darkGreen,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center, // Esto centra el contenido en el AppBar
          children: [
            Image.asset('assets/images/LogoSecundario.png',height: 50,),
          ],
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Row(
              children: [
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
              //buildPlantDetails(_selectedPlant!),
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
              MaterialPageRoute(builder: (context) => HomePage()),
            );
          }
          if (index == 1) { 
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => CalendarPage()),
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

}