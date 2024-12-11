import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:verdant/bloc/plantas_bloc/planta_event.dart';
import 'package:verdant/bloc/plantas_bloc/planta_state.dart';


class PlantBloc extends Bloc<PlantEvent, PlantState> {
  final ImagePicker picker;
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;

  PlantBloc(this.picker, this.firestore, this.auth) : super(PlantInitialState()) {
    on<PickImageEvent>(_onPickImage);
    on<SavePlantEvent>(_onSavePlant);
    on<FetchAllPlantsEvent>(_onFetchAllPlants);
  }

  Future<void> _onPickImage(PickImageEvent event, Emitter<PlantState> emit) async {
    try {
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        emit(PlantImagePickedState(File(pickedFile.path)));
      }
    } catch (e) {
      emit(PlantErrorState("Error picking image: $e"));
    }
  }

  Future<void> _onSavePlant(SavePlantEvent event, Emitter<PlantState> emit) async {
    emit(PlantLoadingState());
    try {
      final user = auth.currentUser;
      if (user == null) throw Exception("User not authenticated");

      final imageUrl = await _uploadImage(event.image);
      if (imageUrl == null) throw Exception("Error uploading image");

      final plant = {
        "name": event.name,
        "imageUrl": imageUrl,
        "obtainedDate": event.obtainedDate,
        "additionalInfo": event.additionalInfo,
        "userId": user.uid,
      };

      await firestore.collection('plants').add(plant);
      emit(PlantSavedState());
    } catch (e) {
      emit(PlantErrorState(e.toString()));
    }
  }

  Future<void> _onFetchAllPlants(FetchAllPlantsEvent event, Emitter<PlantState> emit) async {
    emit(PlantLoadingState());
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
      emit(PlantErrorState(e.toString()));
    }
  }

  Future<String?> _uploadImage(File image) async {
    const apiKey = '5358274ae3240cfc3668d8b0bea63efb';
    try {
      final uri = Uri.parse('https://api.imgbb.com/1/upload?key=$apiKey');
      final request = http.MultipartRequest('POST', uri)
        ..files.add(await http.MultipartFile.fromPath('image', image.path));

      final response = await request.send();
      if (response.statusCode == 200) {
        final responseBody = await response.stream.bytesToString();
        final data = jsonDecode(responseBody);
        return data['data']['url'];
      }
    } catch (e) {
      return null;
    }
    return null;
  }
}

class ImagePicker {
  pickImage({required source}) {}
}

class ImageSource {
  static var gallery;
}
