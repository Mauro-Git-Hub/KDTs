import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_login/auth/auth_service.dart';
import 'package:flutter_application_login/auth/login_screen.dart';
import 'package:flutter_application_login/home_screen.dart';
import 'package:flutter_application_login/pages/cuenta_screen.dart';
import 'package:flutter_application_login/pages/estado_screen.dart';
import 'package:flutter_application_login/pages/listado_screen.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:intl/intl.dart';

class ConfirmarScreen extends StatefulWidget {
  final String origen;
  final String destino;
  final String envio;
  final String medida;
  final String precio;
  final String maximo;
  final User user;

  const ConfirmarScreen(
      {super.key,
      required this.origen,
      required this.destino,
      required this.envio,
      required this.medida,
      required this.user,
      required this.precio,
      required this.maximo});

  @override
  State<ConfirmarScreen> createState() => _ConfirmarScreenState();
}

class _ConfirmarScreenState extends State<ConfirmarScreen> {
  String _currentAddress = "Obteniendo ubicación...";
  late DateTime? _selectedDate; // Fecha de entrega

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now(); // Fecha de entrega predeterminada
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
        title: const Text(
          'Confirmar',
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
              "Por favor, confirma tus datos",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),
            Card(
              margin: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Padding(
                padding: const EdgeInsets.all(
                    10.0), // Margen interno para el contenido
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Columna para la imagen y el texto de Origen/Destino
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Imagen
                        SizedBox(
                          width: 160,
                          height: 100,
                          child: Image.asset(
                            'lib/images/box.png',
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(
                            height: 10), // Espaciado entre imagen y texto
                        // Texto de Origen y Destino
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            RichText(
                              text: TextSpan(
                                style: const TextStyle(
                                    fontSize: 16, color: Colors.black),
                                children: [
                                  const TextSpan(
                                    text: 'Origen: ',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  TextSpan(text: '${widget.origen}\n'),
                                  const TextSpan(
                                    text: 'Destino: ',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  TextSpan(text: widget.destino),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(
                        width:
                            0), // Espaciado entre columna de imagen/texto y el resto
                    // Columna para el resto del contenido
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          style: const TextStyle(
                              fontSize: 14, color: Colors.black),
                          children: [
                            const TextSpan(
                              text: 'Envio\n',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            TextSpan(text: '${widget.envio} -\n'),
                            TextSpan(
                                text: widget.medida == "No aplica"
                                    ? "Máximo No aplica\n"
                                    : 'Máximo ${widget.maximo}\nMedida: ${widget.medida}\n'),
                            TextSpan(text: 'Precio: \$ ${widget.precio}'),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Selector de fecha
            Column(
              children: [
                const Text(
                  'Por favor, Seleccione una fecha de entrega',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(
                    height: 10), // Espacio entre el título y el botón
                TextButton(
                  onPressed: () async {
                    DateTime? selectedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2100),
                    );

                    if (selectedDate != null) {
                      setState(() {
                        _selectedDate = selectedDate;
                      });
                      print('La fecha seleccionada es: $_selectedDate');
                    }
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.white, // Color de fondo blanco
                  ),
                  child: Text(
                    _selectedDate != null
                        ? 'Fecha de entrega: ${DateFormat('dd-MM-yyyy').format(_selectedDate!)}' // Formato dd-MM-yyyy
                        : 'Seleccionar fecha de entrega',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            // Boton Confirmar envio
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16.0), // Separación a izquierda y derecha
              child: SizedBox(
                width: double
                    .infinity, // Ocupa todo el ancho disponible dentro del Padding
                child: ElevatedButton(
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
                        builder: (context) => ListadoScreen(
                          user: widget.user,
                          cliente: '${widget.user.displayName}',
                          tipo: widget.envio,
                          direccionOrigen: widget.origen,
                          direccionDestino: widget.destino,
                          precio: double.parse(widget.precio),
                          fechaEntrega: _selectedDate != null
                              ? DateFormat('yyyy-MM-dd').format(_selectedDate!)
                              : 'Fecha no seleccionada',
                          imagenPath: 'lib/images/box.png',
                        ),
                      ),
                    );
                  },
                  child: const Text(
                    "Confirmar envío",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
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
