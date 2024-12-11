import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:verdant/bloc/Inicio_secion_bloc/auth_bloc.dart';
import 'package:verdant/bloc/Inicio_secion_bloc/auth_event.dart';
import 'package:verdant/bloc/Inicio_secion_bloc/auth_state.dart';

class LoginView extends StatelessWidget {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AuthBloc(),
      child: Scaffold(
        appBar: AppBar(title: const Text('Iniciar Sesión')),
        body: BlocConsumer<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthLoading) {
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (_) => const Center(
                  child: CircularProgressIndicator(),
                ),
              );
            } else if (state is AuthSuccess) {
              Navigator.pop(context); // Cerrar diálogo
              Navigator.pushReplacementNamed(context, '/home');
            } else if (state is AuthFailure) {
              Navigator.pop(context); // Cerrar diálogo
              ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBar(content: Text(state.message)));
            }
          },
          builder: (context, state) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  TextField(
                    controller: emailController,
                    decoration: const InputDecoration(labelText: 'Email'),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: passwordController,
                    decoration: const InputDecoration(labelText: 'Password'),
                    obscureText: true,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      final email = emailController.text;
                      final password = passwordController.text;

                        BlocProvider.of<AuthBloc>(context).add(
                          LoginEvent(email, password),
                        );
                      
                    },
                    child: const Text('Iniciar Sesión'),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
