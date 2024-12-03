import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_login/auth/auth_service.dart';
import 'package:flutter_application_login/auth/login_screen.dart';
import 'package:flutter_application_login/home_screen.dart';
import 'package:flutter_application_login/pages/cuenta_screen.dart';
import 'package:flutter_application_login/sql_helper.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:intl/intl.dart';

class EstadoScreen extends StatefulWidget {
  final User user;

  const EstadoScreen({super.key, required this.user});

  @override
  State<EstadoScreen> createState() => _EstadoScreenState();
}

class _EstadoScreenState extends State<EstadoScreen> {
  String _currentAddress = "Obteniendo ubicación...";
  List<Map<String, dynamic>> _journals = [];
  bool _isLoading = true;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _clienteController = TextEditingController();
  final TextEditingController _direccionOrigenController =
      TextEditingController();
  final TextEditingController _direccionDestinoController =
      TextEditingController();
  final TextEditingController _precioController = TextEditingController();
  final TextEditingController _fechaEntregaController = TextEditingController();
  final TextEditingController _imagenPathController = TextEditingController();
  final TextEditingController _tipoController = TextEditingController();

  void _refreshJournals() async {
    final data = await SQLHelper.getItems();
    setState(() {
      _journals = data;
      _isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _getCurrentLocation(); // Obtener la ubicación actual
    _refreshJournals(); // Refresca la lista de registros
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime initialDate = DateTime.now();
    if (_fechaEntregaController.text.isNotEmpty) {
      DateTime? parsedDate = DateTime.tryParse(_fechaEntregaController.text);
      if (parsedDate != null) {
        initialDate = parsedDate;
      }
    }

    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null) {
      setState(() {
        _fechaEntregaController.text =
            pickedDate.toIso8601String().split('T').first;
      });
    }
  }

  void _showForm(int? id) async {
    if (id != null) {
      final existingItem =
          _journals.firstWhere((element) => element['id'] == id);
      _clienteController.text = existingItem['cliente'];
      _direccionOrigenController.text = existingItem['direccionOrigen'];
      _direccionDestinoController.text = existingItem['direccionDestino'];
      _precioController.text = existingItem['precio'].toString();
      _fechaEntregaController.text = existingItem['fechaEntrega'];
      _imagenPathController.text = existingItem['imagenPath'] ?? '';
      _tipoController.text = existingItem['tipo'] ?? '';
    } else {
      _clienteController.clear();
      _direccionOrigenController.clear();
      _direccionDestinoController.clear();
      _precioController.clear();
      _fechaEntregaController.clear();
      _imagenPathController.clear();
      _tipoController.clear();
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.lightBlue[100], // Cambia el color de fondo
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20), // Bordes redondeados
          ),
          title: Text(
            id == null ? 'Nuevo Registro' : 'Actualizar Registro',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: _clienteController,
                    readOnly: true, // Establecer el campo como no editable
                    decoration: const InputDecoration(hintText: 'Cliente'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'El campo Cliente no puede estar vacío';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _direccionOrigenController,
                    decoration:
                        const InputDecoration(hintText: 'Dirección Origen'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'El campo Dirección Origen no puede estar vacío';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _direccionDestinoController,
                    decoration:
                        const InputDecoration(hintText: 'Dirección Destino'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'El campo Dirección Destino no puede estar vacío';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _precioController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(hintText: 'Precio'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'El campo Precio no puede estar vacío';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Ingrese un valor numérico válido';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _fechaEntregaController,
                    readOnly: true,
                    decoration: const InputDecoration(
                        hintText: 'Fecha de Entrega (DD-MM-YYYY)'),
                    onTap: () => _selectDate(context),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'El campo Fecha de Entrega no puede estar vacío';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _imagenPathController,
                    decoration:
                        const InputDecoration(hintText: 'Path de Imagen'),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  if (id == null) {
                    await _addItem(
                      _clienteController.text,
                      _direccionOrigenController.text,
                      _direccionDestinoController.text,
                      double.tryParse(_precioController.text) ?? 0,
                      _fechaEntregaController.text,
                      _imagenPathController.text,
                      _tipoController.text,
                    );
                  } else {
                    await _updateItem(id);
                  }
                  _clienteController.clear();
                  _direccionOrigenController.clear();
                  _direccionDestinoController.clear();
                  _precioController.clear();
                  _fechaEntregaController.clear();
                  _imagenPathController.clear();
                  _tipoController.clear();
                  // ignore: use_build_context_synchronously
                  Navigator.of(context).pop();
                }
              },
              child: Text(id == null ? 'Guardar' : 'Actualizar'),
            )
          ],
        );
      },
    );
  }

  Future<void> _addItem(
    String cliente,
    String direccionOrigen,
    String direccionDestino,
    double precio,
    String fechaEntrega,
    String imagenPath,
    String tipo,
  ) async {
    DateTime parsedDate = DateTime.tryParse(fechaEntrega) ?? DateTime.now();
    await SQLHelper.createItem(
      cliente,
      direccionOrigen,
      direccionDestino,
      precio,
      parsedDate,
      imagenPath,
      widget.user.uid,
    );
    _refreshJournals();
  }

  Future<void> _updateItem(int id) async {
    double precio = double.tryParse(_precioController.text) ?? 0;
    DateTime fechaEntrega =
        DateTime.tryParse(_fechaEntregaController.text) ?? DateTime.now();
    await SQLHelper.updateItem(
      id,
      _clienteController.text,
      _direccionOrigenController.text,
      _direccionDestinoController.text,
      precio,
      fechaEntrega,
      _imagenPathController.text,
      _tipoController.text,
    );
    _refreshJournals();
  }

  void _deleteItem(int id) async {
    await SQLHelper.deleteItem(id);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Eliminó con éxito el registro!'),
    ));
    _refreshJournals();
  }

  String _formatFecha(String? fecha) {
    if (fecha == null || fecha.isEmpty) {
      return 'No especificada';
    }
    try {
      DateTime parsedDate = DateTime.parse(fecha);
      return DateFormat('dd-MM-yyyy').format(parsedDate);
    } catch (e) {
      return 'Formato inválido';
    }
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
    // Filtrar los elementos del cliente seleccionado
    final filteredJournals = _journals
        .where((item) => item['cliente'] == widget.user.displayName)
        .toList();

    return Scaffold(
      backgroundColor: const Color.fromRGBO(85, 166, 227, 0.965),
      appBar: AppBar(
        automaticallyImplyLeading: false, // Elimina la flecha hacia atrás
        title: const Text(
          'Gestión de Registros',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontFamily: 'Manrope',
            fontSize: 34,
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
              // margin: const EdgeInsets.symmetric(horizontal: 0.0),
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: filteredJournals.length,
              itemBuilder: (context, index) => Card(
                margin: const EdgeInsets.all(15),
                color: const Color.fromARGB(255, 162, 230, 254),
                child: Column(
                  children: [
                    if (filteredJournals[index]['imagenPath'] != null)
                      Padding(
                        padding:
                            const EdgeInsets.only(top: 10.0), // Margen superior
                        child: ClipRRect(
                          borderRadius:
                              BorderRadius.circular(15.0), // Bordes redondeados
                          child: Image.asset(
                            filteredJournals[index]['tipo'] ==
                                        'Paquete Pequeño' ||
                                    filteredJournals[index]['tipo'] ==
                                        'Paquete Mediano' ||
                                    filteredJournals[index]['tipo'] ==
                                        'Paquete Grande'
                                ? 'lib/images/box.png'
                                : 'lib/images/tramite.jpg', // Cambiar a filteredJournals[index]['imagenPath'] si usas rutas dinámicas
                            height: 100, // Altura de la imagen
                            width: 100, // Ancho de la imagen
                            fit: BoxFit.cover, // Ajuste de la imagen
                          ),
                        ),
                      ),
                    ListTile(
                      title: RichText(
                        text: TextSpan(
                          style: DefaultTextStyle.of(context).style,
                          children: [
                            const TextSpan(
                              text: 'Cliente: ',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            TextSpan(
                                text: '${filteredJournals[index]['cliente']}'),
                          ],
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          RichText(
                            text: TextSpan(
                              style: DefaultTextStyle.of(context).style,
                              children: [
                                const TextSpan(
                                  text: 'Tipo: ',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                TextSpan(
                                    text: '${filteredJournals[index]['tipo']}'),
                              ],
                            ),
                          ),
                          RichText(
                            text: TextSpan(
                              style: DefaultTextStyle.of(context).style,
                              children: [
                                const TextSpan(
                                  text: 'Origen: ',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                TextSpan(
                                  text:
                                      '${filteredJournals[index]['direccionOrigen'] ?? 'No especificado'}',
                                ),
                              ],
                            ),
                          ),
                          RichText(
                            text: TextSpan(
                              style: DefaultTextStyle.of(context).style,
                              children: [
                                const TextSpan(
                                  text: 'Destino: ',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                TextSpan(
                                  text:
                                      '${filteredJournals[index]['direccionDestino'] ?? 'No especificado'}',
                                ),
                              ],
                            ),
                          ),
                          RichText(
                            text: TextSpan(
                              style: DefaultTextStyle.of(context).style,
                              children: [
                                const TextSpan(
                                  text: 'Precio: ',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                TextSpan(
                                  text:
                                      '\$${filteredJournals[index]['precio'] ?? 0.0}',
                                ),
                              ],
                            ),
                          ),
                          RichText(
                            text: TextSpan(
                              style: DefaultTextStyle.of(context).style,
                              children: [
                                const TextSpan(
                                  text: 'Fecha Entrega: ',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                TextSpan(
                                  text: _formatFecha(
                                      filteredJournals[index]['fechaEntrega']),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      trailing: SizedBox(
                        width: 110,
                        child: Row(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                    color: Colors.yellow, width: 2.0),
                                borderRadius: BorderRadius.circular(
                                    8.0), // Esquinas redondeadas
                              ),
                              child: IconButton(
                                icon: const Icon(Icons.edit,
                                    color: Colors.yellow),
                                iconSize: 30.0,
                                onPressed: () =>
                                    _showForm(filteredJournals[index]['id']),
                              ),
                            ),
                            const SizedBox(width: 5), // Espaciado entre botones
                            Container(
                              decoration: BoxDecoration(
                                border:
                                    Border.all(color: Colors.red, width: 2.0),
                                borderRadius: BorderRadius.circular(
                                    8.0), // Esquinas redondeadas
                              ),
                              child: IconButton(
                                icon:
                                    const Icon(Icons.delete, color: Colors.red),
                                iconSize: 30.0,
                                onPressed: () =>
                                    _deleteItem(filteredJournals[index]['id']),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
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
        currentIndex: 1,
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
