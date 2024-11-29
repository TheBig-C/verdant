import 'package:flutter_bloc/flutter_bloc.dart';
import 'auth_event.dart';
import 'auth_state.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  AuthBloc() : super(AuthInitial()) {
    on<LoginEvent>((event, emit) async {
      emit(AuthLoading());
      try {
        final userCredential = await _auth.signInWithEmailAndPassword(
          email: event.email,
          password: event.password,
        );

        if (userCredential.user != null) {
          emit(AuthSuccess());
        }
      } catch (e) {
        emit(AuthFailure('Error al iniciar sesión. Verifica tus credenciales.')
            .copyWith(message: 'Detalles: ${e.toString()}')); // Uso de copyWith
      }
    });

    on<SignUpEvent>((event, emit) async {
      emit(AuthLoading());
      try {
        final userCredential = await _auth.createUserWithEmailAndPassword(
          email: event.email,
          password: event.password,
        );

        final user = userCredential.user;

        if (user != null) {
          String? profileImageUrl;

          // Subir imagen de perfil si está presente
          if (event.profileImage is File) {
            final ref = _storage
                .ref()
                .child('profile_images')
                .child('${user.uid}.jpg');
            await ref.putFile(event.profileImage as File);
            profileImageUrl = await ref.getDownloadURL();
          }

          // Guardar datos del usuario en Firestore
          await _firestore.collection('users').doc(user.uid).set({
            'uid': user.uid,
            'email': event.email,
            'name': event.name,
            'profileImage': profileImageUrl,
          });

          emit(AuthSuccess());
        }
      } catch (e) {
        emit(AuthFailure('Error al registrar usuario.')
            .copyWith(message: 'Detalles: ${e.toString()}')); // Uso de copyWith
      }
    });
  }
}
