import 'package:equatable/equatable.dart';

abstract class AllPlantsEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class FetchPlantsEvent extends AllPlantsEvent {}
