import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;

class ImageCacheService {
  static final ImageCacheService instance = ImageCacheService._init();
  ImageCacheService._init();

  Future<String> getCachedImagePath(String mealId) async {
    // Simply use the meal ID as filename
    final fileName = '$mealId.jpg';
    final directory = await getCacheDirectory();
    return path.join(directory.path, fileName);
  }

  Future<String?> cacheImage(String mealId, String imageUrl) async {
    try {
      final cachedPath = await getCachedImagePath(mealId);
      final file = File(cachedPath);

      // If file already exists, return its path
      if (await file.exists()) {
        return cachedPath;
      }

      // Download and save the image
      final response = await http.get(Uri.parse(imageUrl));
      if (response.statusCode == 200) {
        await file.writeAsBytes(response.bodyBytes);
        return cachedPath;
      }
      return null;
    } catch (e) {
      print('Error caching image: $e');
      return null;
    }
  }

  Future<Directory> getCacheDirectory() async {
    final directory = await getApplicationDocumentsDirectory();
    final cacheDir = Directory('${directory.path}/cached_images');
    if (!await cacheDir.exists()) {
      await cacheDir.create(recursive: true);
    }
    return cacheDir;
  }

  Future<void> clearCache() async {
    final directory = await getCacheDirectory();
    if (await directory.exists()) {
      await directory.delete(recursive: true);
    }
  }

  Future<void> removeImage(String mealId) async {
    final imagePath = await getCachedImagePath(mealId);
    final file = File(imagePath);
    if (await file.exists()) {
      await file.delete();
    }
  }
}