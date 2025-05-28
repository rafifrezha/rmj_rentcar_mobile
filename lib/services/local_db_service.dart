import 'package:sqflite/sqflite.dart' as sqflite;
import 'package:path/path.dart';

class LocalDbService {
  static sqflite.Database? _database;

  static Future<sqflite.Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  static Future<sqflite.Database> _initDB() async {
    String path = join(await sqflite.getDatabasesPath(), 'rentcar.db');
    return await sqflite.openDatabase(path, version: 1, onCreate: _createDB);
  }

  static Future<void> _createDB(sqflite.Database db, int version) async {
    await db.execute('''
      CREATE TABLE cars(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        image_url TEXT NOT NULL,
        price_per_day INTEGER NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE rentals(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        car_id INTEGER NOT NULL,
        start_date TEXT NOT NULL,
        end_date TEXT NOT NULL,
        total_price INTEGER NOT NULL,
        status TEXT NOT NULL
      )
    ''');
  }

  // Car CRUD
  static Future<int> insertCar(Map<String, dynamic> car) async {
    final db = await database;
    return await db.insert('cars', car);
  }

  static Future<List<Map<String, dynamic>>> getCars() async {
    final db = await database;
    final result = await db.query('cars');
    return result;
  }

  static Future<int> updateCar(Map<String, dynamic> car) async {
    final db = await database;
    return await db.update(
      'cars',
      car,
      where: 'id = ?',
      whereArgs: [car['id']],
    );
  }

  static Future<int> deleteCar(int id) async {
    final db = await database;
    return await db.delete('cars', where: 'id = ?', whereArgs: [id]);
  }

  // Rental CRUD
  static Future<int> insertRental(Map<String, dynamic> rental) async {
    final db = await database;
    return await db.insert('rentals', rental);
  }

  static Future<List<Map<String, dynamic>>> getRentals({int? userId}) async {
    final db = await database;
    final result = userId != null
        ? await db.query('rentals', where: 'user_id = ?', whereArgs: [userId])
        : await db.query('rentals');
    return result;
  }

  static Future<int> updateRental(Map<String, dynamic> rental) async {
    final db = await database;
    return await db.update(
      'rentals',
      rental,
      where: 'id = ?',
      whereArgs: [rental['id']],
    );
  }

  static Future<int> deleteRental(int id) async {
    final db = await database;
    return await db.delete('rentals', where: 'id = ?', whereArgs: [id]);
  }
}
