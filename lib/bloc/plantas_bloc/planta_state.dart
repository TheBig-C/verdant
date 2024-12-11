import 'dart:io';

abstract class PlantState {}

class PlantInitialState extends PlantState {}

class PlantLoadingState extends PlantState {}

class PlantImagePickedState extends PlantState {
  final File image;

  PlantImagePickedState(this.image);
}

class PlantSavedState extends PlantState {}

class PlantErrorState extends PlantState {
  final String message;

  PlantErrorState(this.message);
}

class AllPlantsLoadedState extends PlantState {
  final List<Map<String, dynamic>> plants;

  AllPlantsLoadedState(this.plants);
}
