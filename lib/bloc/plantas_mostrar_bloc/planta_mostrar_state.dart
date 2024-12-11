import 'package:equatable/equatable.dart';

abstract class AllPlantsState extends Equatable {
  @override
  List<Object?> get props => [];
}

class AllPlantsInitialState extends AllPlantsState {}

class AllPlantsLoadingState extends AllPlantsState {}

class AllPlantsLoadedState extends AllPlantsState {
  final List<Map<String, dynamic>> plants;

  AllPlantsLoadedState(this.plants);

  @override
  List<Object?> get props => [plants];
}

class AllPlantsErrorState extends AllPlantsState {
  final String message;

  AllPlantsErrorState(this.message);

  @override
  List<Object?> get props => [message];
}
