import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:verdant/Pages/Plants/PlantDeailsPage.dart';
import 'package:verdant/Tema/AppColors.dart';
import 'package:verdant/bloc/plantas_mostrar_bloc/planta_mostrar_bloc.dart';
import 'package:verdant/bloc/plantas_mostrar_bloc/planta_mostrar_event.dart';
import 'package:verdant/bloc/plantas_mostrar_bloc/planta_mostrar_state.dart';

class AllPlantsPage extends StatelessWidget {
  const AllPlantsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AllPlantsBloc(
        FirebaseFirestore.instance,
        FirebaseAuth.instance,
      )..add(FetchPlantsEvent()),
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text(
                DateFormat('dd MMM, yyyy').format(DateTime.now()),
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: BlocBuilder<AllPlantsBloc, AllPlantsState>(
                  builder: (context, state) {
                    if (state is AllPlantsLoadingState) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (state is AllPlantsLoadedState) {
                      final plants = state.plants;
                      if (plants.isEmpty) {
                        return const Center(child: Text('No plants to display'));
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
                          return buildPlantThumbnail(context, plant);
                        },
                      );
                    } else if (state is AllPlantsErrorState) {
                      return Center(child: Text('Error: ${state.message}'));
                    }
                    return const SizedBox();
                  },
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
      ),
    );
  }

  Widget buildPlantThumbnail(BuildContext context, Map<String, dynamic> plant) {
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
            image: NetworkImage(plant['imageUrl'] ?? ''),
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}
