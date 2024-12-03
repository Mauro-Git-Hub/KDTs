import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_login/auth/auth_service.dart';
import 'package:flutter_application_login/auth/login_screen.dart';
import 'package:flutter_application_login/home_screen.dart';
import 'package:flutter_application_login/pages/cuenta_screen.dart';
import 'package:flutter_application_login/pages/estado_screen.dart';
import 'package:flutter_application_login/pages/precio_screen.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class CotizaScreen extends StatefulWidget {
  final String selectedService;
  final User user;

  const CotizaScreen(
      {super.key, required this.selectedService, required this.user});

  @override
  State<CotizaScreen> createState() => _CotizaScreenState();
}

class _CotizaScreenState extends State<CotizaScreen> {
  late TextEditingController _origenController;
  late TextEditingController _destinoController;
  late String? _selectedService = "Paquetería";
  String _selectedMedida = "Pequeño"; // Medida por defecto
  String _selectedTramite = "Bancario"; // Tramite por defecto
  String _currentAddress = "Obteniendo ubicación...";
  List<String> tramiteOptions = [
    "Bancario",
    "Mensajería",
    "Salud",
    "Personal",
    "Laboral"
  ]; // Opciones de tramite

  @override
  void initState() {
    super.initState();
    _origenController = TextEditingController(text: "Bvard 13 Nº 605");
    _destinoController = TextEditingController(text: "Mitre Nº 957");
    _selectedService = widget.selectedService;
    _getCurrentLocation();
  }

  @override
  void dispose() {
    _origenController.dispose();
    _destinoController.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

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

    Position position = await Geolocator.getCurrentPosition(
      // ignore: deprecated_member_use
      desiredAccuracy: LocationAccuracy.high,
      // ignore: deprecated_member_use
      forceAndroidLocationManager: true,
    );

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
      print("Error al convertir coordenadas: $e");
    }
  }

  String getMedidasPorTamano(String tamano) {
    switch (tamano.toLowerCase()) {
      case "pequeño":
        return "30x20x15 cm";
      case "mediano":
        return "50x40x30 cm";
      case "grande":
        return "70x60x50 cm";
      default:
        return "Tamaño desconocido";
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = AuthService();
    List<String> medidaOptions = _selectedService == "Hacer un trámite"
        ? ["Bancario", "Mensajería", "Salud", "Personal", "Laboral"]
        : ["Pequeño", "Mediano", "Grande"];

    return Scaffold(
      backgroundColor: const Color.fromRGBO(85, 166, 227, 0.965),
      appBar: AppBar(
        title: const Text(
          'Cotiza',
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
                'lib/images/user_icon_h.png',
              ),
            ),
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'user',
                child: ListTile(
                  leading: const Icon(Icons.person),
                  title: Text(
                    widget.user.displayName ?? "Usuario",
                  ),
                ),
              ),
              const PopupMenuDivider(),
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
                auth.signout();
                goToLogin(context);
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Cotizá tu envio",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            TextField(
              decoration: InputDecoration(
                labelText: "Origen",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                filled: true,
                fillColor: const Color.fromARGB(255, 226, 221, 221),
                prefixIcon: const Icon(
                  Icons.location_on,
                  color: Color.fromARGB(255, 93, 95, 95),
                ),
              ),
              controller: _origenController,
            ),
            const SizedBox(height: 20),
            TextField(
              decoration: InputDecoration(
                labelText: "Destino",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                filled: true,
                fillColor: const Color.fromARGB(255, 226, 221, 221),
                prefixIcon: const Icon(
                  Icons.location_on,
                  color: Color.fromARGB(255, 93, 95, 95),
                ),
              ),
              controller: _destinoController,
            ),
            const SizedBox(height: 20),
            DropdownButtonFormField<String>(
              value: _selectedService,
              decoration: InputDecoration(
                labelText: "Selecciona un servicio",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                filled: true,
                fillColor: const Color.fromARGB(255, 226, 221, 221),
              ),
              items: const [
                DropdownMenuItem(
                    value: "Servicio 1", child: Text("Paquetería")),
                DropdownMenuItem(value: "Servicio 2", child: Text("Trámite")),
                DropdownMenuItem(value: "Servicio 3", child: Text("Otro")),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedService = value!;
                  if (_selectedService == "Servicio 1") {
                    _selectedMedida =
                        medidaOptions.first; // Resetear a la primera medida
                  } else {
                    _selectedTramite = tramiteOptions
                        .first; // Resetear a la primera opción de trámite
                  }
                });
              },
            ),
            const SizedBox(height: 20),
            // Segundo Dropdown para "Selecciona una medida" o "Selecciona un trámite"
            DropdownButtonFormField<String>(
              value: _selectedService == "Servicio 1"
                  ? _selectedMedida
                  : _selectedTramite,
              decoration: InputDecoration(
                labelText: _selectedService == "Servicio 1"
                    ? "Selecciona una medida"
                    : "Selecciona un tipo de trámite",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                filled: true,
                fillColor: const Color.fromARGB(255, 226, 221, 221),
              ),
              items: _selectedService == "Servicio 1"
                  ? medidaOptions
                      .map((option) =>
                          DropdownMenuItem(value: option, child: Text(option)))
                      .toList()
                  : tramiteOptions
                      .map((option) =>
                          DropdownMenuItem(value: option, child: Text(option)))
                      .toList(),
              onChanged: (value) {
                setState(() {
                  if (_selectedService == "Servicio 1") {
                    _selectedMedida = value!;
                  } else {
                    _selectedTramite = value!;
                  }
                });
              },
              dropdownColor: const Color.fromARGB(255, 226, 221, 221),
              isExpanded: true,
            ),
            const SizedBox(height: 60),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(246, 50, 98, 135),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => PrecioScreen(
                            user: widget.user,
                            origen: _origenController.text,
                            destino: _destinoController.text,
                            envio: _selectedService == "Servicio 1"
                                ? "Paquete $_selectedMedida"
                                : "Trámite $_selectedTramite",
                            medida: _selectedService == "Servicio 1"
                                ? getMedidasPorTamano(_selectedMedida)
                                : "No aplica",
                          )),
                );
              },
              child: const Text(
                "Siguiente",
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
            ),
          ],
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
