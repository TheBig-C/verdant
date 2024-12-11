import 'dart:io';

abstract class AuthEvent {}

class LoginEvent extends AuthEvent {
  final String email;
  final String password;

  LoginEvent(this.email, this.password);
}

class SignUpEvent extends AuthEvent {
  final String name;
  final String email;
  final String password;
  final File? profileImage;

  SignUpEvent(this.name, this.email, this.password, this.profileImage);
}
