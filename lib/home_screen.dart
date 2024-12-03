import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_login/auth/auth_service.dart';
import 'package:flutter_application_login/auth/login_screen.dart';
import 'package:flutter_application_login/pages/cotiza_screen.dart';
import 'package:flutter_application_login/pages/cuenta_screen.dart';
import 'package:flutter_application_login/pages/estado_screen.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class HomeScreen extends StatefulWidget {
  final User user;

  const HomeScreen({super.key, required this.user});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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
      backgroundColor: const Color.fromRGBO(85, 166, 227, 0.965),
      appBar: AppBar(
        automaticallyImplyLeading: false, // Elimina la flecha hacia atrás
        title: const Text(
          'Inicio',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontFamily: 'Manrope',
            fontSize: 35,
          ),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const CircleAvatar(
              backgroundImage: AssetImage(
                'lib/images/user_icon_h.png', // Reemplaza con tu imagen
              ),
            ),
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'user',
                child: ListTile(
                  leading: const Icon(Icons.person),
                  title: Text(
                    widget.user.displayName ?? "Usuario", // Nombre del usuario
                  ),
                ),
              ),
              const PopupMenuDivider(), // Línea separadora
              const PopupMenuItem<String>(
                value: 'logout',
                child: ListTile(
                  leading: Icon(Icons.logout),
                  title: Text('Cerrar sesión'),
                ),
              ),
            ],
            onSelected: (value) {
              if (value == 'logout') {
                // Lógica para cerrar sesión
                auth.signout();
                goToLogin(context);
                // AuthService().logout(); // Tu método de logout
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              }
            },
          ),
        ],

        backgroundColor: const Color(0xFF9DD3FB),
        toolbarHeight: 150,
        // Campos de texto en la barra de navegación con la ubicación actual.
        centerTitle: false,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60.0), // Adjusted height
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Container(
              margin:
                  const EdgeInsets.only(bottom: 45.0), // Adjust bottom spacing
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
      body: Align(
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "¿Qué deseas realizar?",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        const Color.fromARGB(246, 97, 182, 247), // Fondo
                    padding: const EdgeInsets.symmetric(
                        vertical: 20, horizontal: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide.none, // Sin contorno
                    ),
                    // elevation: 5, // Sombra del botón
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => CotizaScreen(
                                selectedService: "Servicio 1",
                                user: widget.user,
                              )),
                    );
                  },
                  child: const Column(
                    children: [
                      Icon(
                        Icons.inventory,
                        size: 50,
                        color:
                            Color.fromRGBO(46, 90, 123, 1), // Color del ícono
                      ),
                      SizedBox(height: 10),
                      Text(
                        "Enviar un paquete",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.black, // Color del texto
                        ),
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        const Color.fromARGB(246, 97, 182, 247), // Fondo
                    padding: const EdgeInsets.symmetric(
                        vertical: 20, horizontal: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide.none, // Sin contorno
                    ),
                    // elevation: 5, // Sombra del botón
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => CotizaScreen(
                                selectedService: "Servicio 2",
                                user: widget.user,
                              )),
                    );
                    // Acción para "Hacer un trámite"
                    print("Hacer un trámite");
                  },
                  child: const Column(
                    children: [
                      Icon(
                        Icons.email,
                        size: 50,
                        color:
                            Color.fromRGBO(46, 90, 123, 1), // Color del ícono
                      ),
                      SizedBox(height: 10),
                      Text(
                        "Hacer un trámite",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.black, // Color del texto
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),

      // Barra de navegación inferior
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
        currentIndex: 0,
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
