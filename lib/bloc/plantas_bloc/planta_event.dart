import 'package:equatable/equatable.dart';
import 'dart:io';

abstract class PlantEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class PickImageEvent extends PlantEvent {}

class SavePlantEvent extends PlantEvent {
  final String name;
  final String obtainedDate;
  final String additionalInfo;
  final File image;

  SavePlantEvent({
    required this.name,
    required this.obtainedDate,
    required this.additionalInfo,
    required this.image,
  });

  @override
  List<Object?> get props => [name, obtainedDate, additionalInfo, image];
}

class FetchAllPlantsEvent extends PlantEvent {}
