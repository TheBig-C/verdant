abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthSuccess extends AuthState {}

class AuthFailure extends AuthState {
  final String message;

  AuthFailure(this.message);

  // Implementación de copyWith
  AuthFailure copyWith({
    String? message,
  }) {
    return AuthFailure(
      message ?? this.message,
    );
  }
}
