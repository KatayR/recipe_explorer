import 'dart:convert';
import 'dart:io';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_common/sqlite_api.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'image_cache.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;
  static bool _initialized = false;

  DatabaseHelper._init();

  /// Initialize FFI
  static Future<void> initializeFfi() async {
    if (!_initialized) {
      // Initialize FFI
      if (Platform.isWindows || Platform.isLinux) {
        sqfliteFfiInit();
      }
      // Set the database factory to use FFI
      databaseFactory = databaseFactoryFfi;
      _initialized = true;
    }
  }

  Future<Database> get database async {
    if (_database != null) return _database!;

    // Ensure FFI is initialized
    await initializeFfi();

    _database = await _initDB('recipes.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    // For better cross-platform support, use getApplicationDocumentsDirectory
    final Directory documentsDirectory =
        await getApplicationDocumentsDirectory();
    final String path = join(documentsDirectory.path, 'databases', filePath);

    // Ensure the directory exists
    await Directory(dirname(path)).create(recursive: true);

    return await databaseFactory.openDatabase(
      path,
      options: OpenDatabaseOptions(
        version: 1,
        onCreate: _createDB,
      ),
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE favorites(
        id TEXT PRIMARY KEY,
        mealData TEXT NOT NULL
      )
    ''');
  }

  Future<void> cleanupUnusedImages() async {
    final db = await database;
    final favorites = await db.query('favorites');
    final usedUrls = favorites
        .map((row) =>
            jsonDecode(row['mealData'] as String)['strMealThumb'] as String)
        .toSet();
    final cacheDir = await ImageCacheService.instance.getCacheDirectory();
    if (await cacheDir.exists()) {
      final files = await cacheDir.list().toList();
      for (var file in files) {
        if (file is File && !usedUrls.contains(file.path)) {
          await file.delete();
        }
      }
    }
  }

  Future<int> addFavorite(String mealId, String mealData) async {
    final db = await database;
    return await db.insert(
      'favorites',
      {
        'id': mealId,
        'mealData': mealData,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> removeFavorite(String mealId) async {
    final db = await database;
    return await db.delete(
      'favorites',
      where: 'id = ?',
      whereArgs: [mealId],
    );
  }

  Future<bool> isFavorite(String mealId) async {
    final db = await database;
    final result = await db.query(
      'favorites',
      where: 'id = ?',
      whereArgs: [mealId],
    );
    return result.isNotEmpty;
  }

  Future<List<String>> getAllFavorites() async {
    final db = await database;
    final result = await db.query('favorites');
    return result.map((row) => row['mealData'] as String).toList();
  }

  Future<String?> getFavoriteMeal(String mealId) async {
    final db = await database;
    final result = await db.query(
      'favorites',
      where: 'id = ?',
      whereArgs: [mealId],
      columns: ['mealData'],
    );
    if (result.isNotEmpty) {
      return result.first['mealData'] as String;
    }
    return null;
  }

  Future<void> close() async {
    final db = await database;
    db.close();
  }
}
