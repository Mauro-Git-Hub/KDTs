import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_login/auth/auth_service.dart';
import 'package:flutter_application_login/auth/signup_screen.dart';
import 'package:flutter_application_login/home_screen.dart';
import 'package:flutter_application_login/widgets/button.dart';

// Pantalla de inicio de sesión.
class IniciaSesion extends StatefulWidget {
  const IniciaSesion({super.key});

  @override
  State<IniciaSesion> createState() => _IniciaSesionState();
}

class _IniciaSesionState extends State<IniciaSesion> {
  final AuthService _auth = AuthService();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF5CB6F9), // Color de fondo
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25),
        child: Column(
          children: <Widget>[
            const SizedBox(height: 50),
            // Logo de la aplicación
            Image.asset(
              'lib/images/logo_2.png',
              height: 120,
            ),
            const SizedBox(height: 20),
            // Título
            const Text(
              'KDTs',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF254964),
              ),
            ),
            const SizedBox(height: 10),
            // Subtítulo
            const Text(
              'Tu envío o trámite en minutos',
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF254964),
              ),
            ),
            const SizedBox(height: 50),
            // Campo de texto para el email
            CustomTextField(
              hint: "Ingresa tu Email",
              label: "Email",
              controller: _email,
            ),
            const SizedBox(height: 20),
            // Campo de texto para la contraseña
            CustomTextField(
              hint: "Ingresa tu Password",
              label: "Password",
              controller: _password,
              obscureText: true,
            ),
            const SizedBox(height: 30),
            // Botón para iniciar sesión
            CustomButton(
              label: "Inicia sesión",
              onPressed: _iniciaSesion,
            ),
            const SizedBox(height: 15),
            // Enlace para registrarse
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("¿No tienes una cuenta? "),
                InkWell(
                  onTap: () => _goToSignup(context),
                  child: const Text(
                    "Regístrate",
                    style: TextStyle(color: Colors.red),
                  ),
                )
              ],
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }

  /// Navega a la pantalla de registro.
  void _goToSignup(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SignupScreen()),
    );
  }

  /// Navega a la pantalla principal después de iniciar sesión.
  void _goToHome(BuildContext context, User user) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HomeScreen(user: user),
      ),
    );
  }

  /// Maneja el inicio de sesión.
  Future<void> _iniciaSesion() async {
    try {
      final User? user = await _auth.loginUserWithEmailAndPassword(
        _email.text.trim(),
        _password.text.trim(),
      );

      if (user != null) {
        log("Usuario conectado: ${user.displayName}");
        // ignore: use_build_context_synchronously
        _goToHome(context, user);
      } else {
        _mostrarError("Credenciales incorrectas");
      }
    } catch (e) {
      log("Error al iniciar sesión: $e");
      _mostrarError("Ha ocurrido un error al iniciar sesión");
    }
  }

  /// Muestra un mensaje de error en un `SnackBar`.
  void _mostrarError(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensaje)),
    );
  }
}

// Clase para ocultar el campo contraseña
class CustomTextField extends StatelessWidget {
  final String hint;
  final String label;
  final TextEditingController controller;
  final bool obscureText; // Parámetro para ocultar texto

  const CustomTextField({
    super.key,
    required this.hint,
    required this.label,
    required this.controller,
    this.obscureText = false, // Valor por defecto es false
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscureText, // Usamos el parámetro para ocultar el texto
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: const OutlineInputBorder(),
      ),
    );
  }
}
