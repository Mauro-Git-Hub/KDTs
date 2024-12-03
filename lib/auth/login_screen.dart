import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_login/auth/signup_screen.dart';
import 'package:flutter_application_login/home_screen.dart';
import 'package:flutter_application_login/pages/inicia_sesion.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // final _auth = AuthService();
  final _email = TextEditingController();
  final _password = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    _email.dispose();
    _password.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Añadir color de fondo
      backgroundColor: const Color(0xFF5CB6F9),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25),
        child: Column(
          children: <Widget>[
            // Añadir imagen en la parte superior con margen superior
            const SizedBox(height: 140),
            Image.asset(
              'lib/images/logo_2.png',
              height: 120,
            ),
            const SizedBox(height: 20),
            // Añadir título "KDTs"
            const Text(
              'KDTs',
              style: TextStyle(
                fontSize: 34,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 14, 27, 37),
              ),
            ),
            const SizedBox(height: 10),
            // Añadir subtítulo "tu envío o trámite en minutos"
            const Text(
              'Tu envío o trámite en minutos',
              style: TextStyle(
                fontSize: 20,
                color: Color(0xFF254964),
              ),
            ),
            const SizedBox(height: 140),
            // Añadir botón "Continuar con Google"
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  // Aquí puedes manejar la autenticación con Google
                  // ignore: avoid_print
                  print('Continuar con Google');
                },
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                        8), // Cambiar el valor según sea necesario
                  ),
                ),
                icon: Image.asset(
                  'lib/images/google_logo.png',
                  height: 20,
                ),
                label: const Text('Continuar con Google'),
              ),
            ),
            const SizedBox(height: 15),
            // Añadir botón "Continuar con Facebook"
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  // Aquí puedes manejar la autenticación con Facebook
                  // ignore: avoid_print
                  print('Continuar con Facebook');
                },
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                        8), // Cambiar el valor según sea necesario
                  ),
                ),
                icon: Image.asset(
                  'lib/images/facebook_logo.png',
                  height: 33,
                ),
                label: const Text('Continuar con Facebook'),
              ),
            ),
            const SizedBox(height: 15),
            // Añadir botón "Regístrate"
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const SignupScreen()),
                  );
                  // print('Regístrate');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF254964),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                        8), // Cambiar el valor según sea necesario
                  ),
                ),
                child: const Text(
                  'Regístrate',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 15),
            // Añadir botón "Inicia sesión"
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Manejo del inicio de sesión
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const IniciaSesion()),
                  );
                  // print('Inicia sesión');
                },
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                        8), // Cambiar el valor según sea necesario
                  ),
                ),
                child: const Text('Inicia sesión'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  goToSignup(BuildContext context) => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const SignupScreen()),
      );

  goToHome(BuildContext context, User user) => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen(user: user)),
      );
}
