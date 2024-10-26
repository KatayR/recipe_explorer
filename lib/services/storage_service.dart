import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as pathHelper;
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import '../models/meal_model.dart';

class StorageService {
  static final StorageService instance = StorageService._init();
  static Database? _database;

  StorageService._init();

  /// Initialize database connection
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('recipes.db');
    return _database!;
  }

  /// Initialize the database, creating tables if needed
  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = pathHelper.join(dbPath, filePath);
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  /// Create database tables
  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE favorites(
        id TEXT PRIMARY KEY,
        mealData TEXT NOT NULL
      )
    ''');
  }

  // FAVORITES METHODS

  /// Add a meal to favorites
  /// Returns true if successful
  Future<bool> addToFavorites(Meal meal) async {
    try {
      final db = await database;

      // First cache the image
      await cacheImage(meal.idMeal, meal.strMealThumb);

      // Then save meal data
      await db.insert(
        'favorites',
        {
          'id': meal.idMeal,
          'mealData': jsonEncode(meal.toJson()),
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      return true;
    } catch (e) {
      print('Error adding to favorites: $e');
      return false;
    }
  }

  /// Remove a meal from favorites
  /// Returns true if successful
  Future<bool> removeFromFavorites(String mealId) async {
    try {
      final db = await database;
      await db.delete(
        'favorites',
        where: 'id = ?',
        whereArgs: [mealId],
      );
      await removeImage(mealId);
      return true;
    } catch (e) {
      print('Error removing from favorites: $e');
      return false;
    }
  }

  /// Check if a meal is in favorites
  Future<bool> isFavorite(String mealId) async {
    try {
      final db = await database;
      final result = await db.query(
        'favorites',
        where: 'id = ?',
        whereArgs: [mealId],
      );
      return result.isNotEmpty;
    } catch (e) {
      print('Error checking favorite status: $e');
      return false;
    }
  }

  /// Get all favorite meals
  Future<List<Meal>> getAllFavorites() async {
    try {
      final db = await database;
      final results = await db.query('favorites');
      return results
          .map((row) => Meal.fromJson(jsonDecode(row['mealData'] as String)))
          .toList();
    } catch (e) {
      print('Error getting favorites: $e');
      return [];
    }
  }

  /// Get a specific favorite meal by ID
  Future<Meal?> getFavoriteMeal(String mealId) async {
    try {
      final db = await database;
      final results = await db.query(
        'favorites',
        where: 'id = ?',
        whereArgs: [mealId],
      );
      if (results.isNotEmpty) {
        return Meal.fromJson(jsonDecode(results.first['mealData'] as String));
      }
      return null;
    } catch (e) {
      print('Error getting favorite meal: $e');
      return null;
    }
  }

  // IMAGE CACHING METHODS

  /// Get the path where cached images are stored
  Future<Directory> _getImageCacheDirectory() async {
    final directory = await getApplicationDocumentsDirectory();
    final cacheDir = Directory('${directory.path}/cached_images');
    if (!await cacheDir.exists()) {
      await cacheDir.create(recursive: true);
    }
    return cacheDir;
  }

  /// Get the path for a cached image
  Future<String> getImagePath(String mealId) async {
    final cacheDir = await _getImageCacheDirectory();
    return pathHelper.join(cacheDir.path, '$mealId.jpg');
  }

  /// Cache an image
  /// Returns the path to the cached image if successful, null otherwise
  Future<String?> cacheImage(String mealId, String imageUrl) async {
    try {
      final imagePath = await getImagePath(mealId);
      final imageFile = File(imagePath);

      // If image already exists in cache, return its path
      if (await imageFile.exists()) {
        return imagePath;
      }

      // Download and save the image
      final response = await http.get(Uri.parse(imageUrl));
      if (response.statusCode == 200) {
        await imageFile.writeAsBytes(response.bodyBytes);
        return imagePath;
      }
      return null;
    } catch (e) {
      print('Error caching image: $e');
      return null;
    }
  }

  /// Remove a cached image
  Future<void> removeImage(String mealId) async {
    try {
      final imagePath = await getImagePath(mealId);
      final file = File(imagePath);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      print('Error removing image: $e');
    }
  }

  /// Clean up unused images from cache
  Future<void> cleanupUnusedImages() async {
    try {
      final db = await database;
      final favorites = await db.query('favorites');
      final usedIds = favorites.map((row) => row['id'] as String).toSet();

      final cacheDir = await _getImageCacheDirectory();
      if (await cacheDir.exists()) {
        final files = await cacheDir.list().toList();
        for (var file in files) {
          if (file is File) {
            final fileName = pathHelper.basename(file.path);
            final mealId = fileName.split('.').first;
            if (!usedIds.contains(mealId)) {
              await file.delete();
            }
          }
        }
      }
    } catch (e) {
      print('Error cleaning up images: $e');
    }
  }
}