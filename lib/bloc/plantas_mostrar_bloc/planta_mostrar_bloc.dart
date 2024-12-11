import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:verdant/bloc/plantas_mostrar_bloc/planta_mostrar_event.dart';
import 'package:verdant/bloc/plantas_mostrar_bloc/planta_mostrar_state.dart';


class AllPlantsBloc extends Bloc<AllPlantsEvent, AllPlantsState> {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;

  AllPlantsBloc(this.firestore, this.auth) : super(AllPlantsInitialState()) {
    on<FetchPlantsEvent>(_onFetchPlants);
  }

  Future<void> _onFetchPlants(FetchPlantsEvent event, Emitter<AllPlantsState> emit) async {
    emit(AllPlantsLoadingState());
    try {
      final user = auth.currentUser;
      if (user == null) throw Exception("User not authenticated");

      final snapshot = await firestore
          .collection('plants')
          .where('userId', isEqualTo: user.uid)
          .get();

      final plants = snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();

      emit(AllPlantsLoadedState(plants));
    } catch (e) {
      emit(AllPlantsErrorState(e.toString()));
    }
  }
}
