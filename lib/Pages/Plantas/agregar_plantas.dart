import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:io';

import 'package:verdant/bloc/plantas_bloc/planta_bloc.dart';
import 'package:verdant/bloc/plantas_bloc/planta_event.dart';
import 'package:verdant/bloc/plantas_bloc/planta_state.dart';


class AddPlantPage extends StatelessWidget {
  final _nameController = TextEditingController();
  final _obtainedDateController = TextEditingController();
  final _additionalInfoController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => PlantBloc(
        ImagePicker(),
        FirebaseFirestore.instance,
        FirebaseAuth.instance,
      ),
      child: Scaffold(
        appBar: AppBar(title: const Text('Add Plant')),
        body: BlocConsumer<PlantBloc, PlantState>(
          listener: (context, state) {
            if (state is PlantSavedState) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Plant saved successfully")),
              );
              Navigator.pop(context);
            } else if (state is PlantErrorState) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Error: ${state.message}")),
              );
            }
          },
          builder: (context, state) {
            final bloc = context.read<PlantBloc>();
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () => bloc.add(PickImageEvent()),
                      child: Container(
                        height: 150,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: state is PlantImagePickedState
                            ? Image.file(state.image, fit: BoxFit.cover)
                            : const Icon(Icons.add_photo_alternate, size: 50),
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
                        onPressed: state is PlantLoadingState
                            ? null
                            : () {
                                bloc.add(SavePlantEvent(
                                  name: _nameController.text,
                                  obtainedDate: _obtainedDateController.text,
                                  additionalInfo: _additionalInfoController.text,
                                  image: (state as PlantImagePickedState).image,
                                ));
                              },
                        child: state is PlantLoadingState
                            ? const CircularProgressIndicator()
                            : const Text('Save Plant'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}


