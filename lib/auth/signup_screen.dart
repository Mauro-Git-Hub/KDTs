import 'dart:developer';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_login/auth/auth_service.dart';
import 'package:flutter_application_login/auth/login_screen.dart';
import 'package:flutter_application_login/home_screen.dart';
import 'package:flutter_application_login/widgets/button.dart';
import 'package:flutter_application_login/widgets/textfield.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _auth = AuthService();

  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _name.dispose();
    _email.dispose();
    _password.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF5CB6F9),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25),
        child: Column(
          children: [
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
            const Text("Regístrate",
                style: TextStyle(fontSize: 40, fontWeight: FontWeight.w500)),
            const SizedBox(
              height: 50,
            ),
            CustomTextField(
              hint: "Enter Name",
              label: "Name",
              controller: _name,
            ),
            const SizedBox(height: 20),
            CustomTextField(
              hint: "Enter Email",
              label: "Email",
              controller: _email,
            ),
            const SizedBox(height: 20),
            CustomTextField(
              hint: "Enter Password",
              label: "Password",
              isPassword: true,
              controller: _password,
            ),
            const SizedBox(height: 30),
            CustomButton(
              label: "Regístrate",
              onPressed: _signup,
            ),
            const SizedBox(height: 15),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Text("Already have an account? "),
              InkWell(
                onTap: () => goToLogin(context),
                child: const Text("Login", style: TextStyle(color: Colors.red)),
              )
            ]),
            const Spacer()
          ],
        ),
      ),
    );
  }

  goToLogin(BuildContext context) => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );

  goToHome(BuildContext context, User user) => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen(user: user)),
      );

  _signup() async {
    try {
      // Crear usuario
      final user = await _auth.createUserWithEmailAndPassword(
        _email.text,
        _password.text,
        _name.text, // Envía el nombre del usuario
      );

      if (user != null) {
        // Actualizar el perfil del usuario con el nombre
        await user.updateProfile(displayName: _name.text);
        await user
            .reload(); // Recargar la instancia del usuario para reflejar los cambios
        final updatedUser = FirebaseAuth.instance.currentUser;

        log("User Created Successfully with Name: ${updatedUser?.displayName}");
        goToHome(context, updatedUser!);
      } else {
        log("User Creation Failed");
      }
    } catch (e) {
      log("Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error al crear la cuenta: $e")),
      );
    }
  }
}
