import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:verdant/Pages/Plants/PlantDeailsPage.dart';
import 'package:verdant/Pages/widgets/drawer_menu.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  late String _userId;

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
        backgroundColor: const Color(0xFF4CAF50),
        title: const Text('Verdant'),
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
            SizedBox(
              height: 150,
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

                  return ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: plants.length,
                    itemBuilder: (context, index) {
                      final plant = plants[index];
                      return buildCarouselItem(plant);
                    },
                  );
                },
              ),
            ),
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
        backgroundColor: const Color(0xFF4CAF50),
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.eco), label: ''),
        ],
      ),
    );
  }

  Widget buildCarouselItem(QueryDocumentSnapshot plant) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PlantDetailsPage(plant: plant),
          ),
        );
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
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PlantDetailsPage(plant: plant),
          ),
        );
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
