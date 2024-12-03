import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_login/auth/auth_service.dart';
import 'package:flutter_application_login/auth/login_screen.dart';
import 'package:flutter_application_login/home_screen.dart';
import 'package:flutter_application_login/pages/estado_screen.dart';
import 'package:flutter_application_login/widgets/button.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

class CuentaScreen extends StatefulWidget {
  final User user;

  const CuentaScreen({super.key, required this.user});

  @override
  State<CuentaScreen> createState() => _CuentaScreenState();
}

class _CuentaScreenState extends State<CuentaScreen> {
  String _currentAddress = "Obteniendo ubicación...";

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Verifica si el servicio de ubicación está habilitado
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() {
        _currentAddress = "Servicio de ubicación deshabilitado";
      });
      return;
    } else {
      setState(() {
        _currentAddress = "Obteniendo ubicación...";
      });
    }

    // Solicita permisos de ubicación
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() {
          _currentAddress = "Permiso de ubicación denegado";
        });
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() {
        _currentAddress =
            "Permiso de ubicación denegado permanentemente. Habilítalo en la configuración.";
      });
      return;
    }

    // Obtén la posición actual
    Position position = await Geolocator.getCurrentPosition(
      // ignore: deprecated_member_use
      desiredAccuracy: LocationAccuracy.high,
      // ignore: deprecated_member_use
      forceAndroidLocationManager:
          true, // Forzar el uso del administrador de ubicación
    );

    // Imprimir las coordenadas
    // print("Latitud: ${position.latitude}, Longitud: ${position.longitude}");

    try {
      List<Placemark> placemarks =
          await placemarkFromCoordinates(position.latitude, position.longitude);

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        // print("Placemark seleccionado: ${place.toJson()}");

        setState(() {
          _currentAddress =
              "${place.street}, ${place.locality}, ${place.administrativeArea}, ${place.country}";
        });
      } else {
        setState(() {
          _currentAddress = "No se encontraron datos de dirección.";
        });
      }
    } catch (e) {
      setState(() {
        _currentAddress = "No se pudo obtener la dirección";
      });
      print("Error al convertir coordenadas: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = AuthService();
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Cuenta',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontFamily: 'Manrope',
            fontSize: 35,
          ),
        ),
        actions: [
          IconButton(
            icon: CircleAvatar(
              backgroundImage: widget.user.photoURL != null
                  ? NetworkImage(widget.user.photoURL!)
                  : const AssetImage('lib/images/user_icon_h.png')
                      as ImageProvider,
            ),
            onPressed: () {},
          ),
        ],
        backgroundColor: const Color(0xFF9DD3FB),
        toolbarHeight: 150,
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60.0),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Container(
              margin: const EdgeInsets.only(bottom: 45.0),
              child: TextField(
                decoration: InputDecoration(
                  hintText: _currentAddress,
                  prefixIcon: const Icon(Icons.location_on),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(
                      vertical: 0.0, horizontal: 20.0),
                ),
              ),
            ),
          ),
        ),
      ),
      body: Container(
        color: const Color.fromRGBO(85, 166, 227, 0.965), // Color celeste
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: widget.user.photoURL != null
                      ? NetworkImage(widget.user.photoURL!)
                      : const AssetImage('lib/images/user_icon_h.png')
                          as ImageProvider,
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: Text(
                  widget.user.displayName ?? "Nombre de usuario no disponible",
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Center(
                child: Text(
                  widget.user.email ?? "Correo no disponible",
                  style: const TextStyle(
                      fontSize: 16, color: Color.fromARGB(255, 72, 71, 71)),
                ),
              ),
              const SizedBox(height: 40),
              Center(
                child: CustomButton(
                  label: "Desconectar",
                  onPressed: () async {
                    await auth.signout();
                    goToLogin(context);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.check_circle),
            label: 'Estado',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.verified_user),
            label: 'Cuenta',
          ),
        ],
        currentIndex: 2,
        backgroundColor: const Color(0xFF122432),
        selectedItemColor: Colors.amber[800],
        unselectedItemColor: const Color(0xFF878D96),
        onTap: (index) {
          if (index == 0) {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => HomeScreen(user: widget.user)),
            );
          } else if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => EstadoScreen(user: widget.user)),
            );
          } else if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => CuentaScreen(user: widget.user)),
            );
          }
        },
      ),
    );
  }

  goToLogin(BuildContext context) => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
}
