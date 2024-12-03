import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart' as sql;

class SQLHelper {
  static Future<void> createTables(sql.Database database) async {
    await database.execute("""
      CREATE TABLE items(
        id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        cliente TEXT,
        direccionOrigen TEXT,
        direccionDestino TEXT,
        precio REAL,
        fechaEntrega TEXT,
        imagenPath TEXT,
        tipo TEXT,
        createdAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
      )
    """);
  }

  static Future<sql.Database> db() async {
    return sql.openDatabase(
      'dbtech.db',
      version: 2, // Cambiar la versión de la base de datos
      onCreate: (sql.Database database, int version) async {
        await createTables(database);
      },
      onUpgrade: (sql.Database database, int oldVersion, int newVersion) async {
        if (oldVersion < newVersion) {
          // Agrega las nuevas columnas si es necesario
          await database.execute("ALTER TABLE items ADD COLUMN precio REAL");
          await database
              .execute("ALTER TABLE items ADD COLUMN fechaEntrega TEXT");
          await database
              .execute("ALTER TABLE items ADD COLUMN imagenPath TEXT");
        }
      },
    );
  }

  static Future<int> createItem(
      String cliente,
      String direccionOrigen,
      String direccionDestino,
      double precio,
      DateTime fechaEntrega,
      String? imagenPath,
      String tipo) async {
    // Agregar tipo
    final db = await SQLHelper.db();

    final data = {
      'cliente': cliente,
      'direccionOrigen': direccionOrigen,
      'direccionDestino': direccionDestino,
      'precio': precio,
      'fechaEntrega': fechaEntrega.toIso8601String(),
      'imagenPath': imagenPath,
      'tipo': tipo
    };
    final id = await db.insert('items', data,
        conflictAlgorithm: sql.ConflictAlgorithm.replace);
    return id;
  }

  static Future<List<Map<String, dynamic>>> getItems() async {
    final db = await SQLHelper.db();
    return db.query('items', orderBy: "id");
  }

  static Future<int> updateItem(
      int id,
      String cliente,
      String direccionOrigen,
      String direccionDestino,
      double precio,
      DateTime fechaEntrega,
      String? imagenPath,
      String tipo) async {
    // Agregar tipo
    final db = await SQLHelper.db();

    final data = {
      'cliente': cliente,
      'direccionOrigen': direccionOrigen,
      'direccionDestino': direccionDestino,
      'precio': precio,
      'fechaEntrega': fechaEntrega.toIso8601String(),
      'imagenPath': imagenPath,
      'tipo': tipo,
      'createdAt': DateTime.now().toString()
    };

    final result =
        await db.update('items', data, where: "id = ?", whereArgs: [id]);
    return result;
  }

  static Future<void> deleteItem(int id) async {
    final db = await SQLHelper.db();
    try {
      await db.delete("items", where: "id = ?", whereArgs: [id]);
    } catch (err) {
      debugPrint("Something went wrong when deleting an item: $err");
    }
  }

  static Future<void> deleteDatabase() async {
    final path = await sql.getDatabasesPath();
    final dbPath = '$path/dbtech.db'; // Nombre de tu base de datos
    try {
      await sql.deleteDatabase(dbPath);
      print("Base de datos eliminada: $dbPath");
    } catch (e) {
      print("Error al eliminar la base de datos: $e");
    }
  }
}
