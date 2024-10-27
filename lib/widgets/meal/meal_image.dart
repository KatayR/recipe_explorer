import 'dart:io';
import 'package:flutter/material.dart';
import '../../services/image_cache.dart';
import '../loading/loading_view.dart';

class MealImage extends StatefulWidget {
  final String mealId;
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;

  const MealImage({
    super.key,
    required this.mealId,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
  });

  @override
  State<MealImage> createState() => _MealImageState();
}

class _MealImageState extends State<MealImage> {
  String? _cachedPath;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  Future<void> _loadImage() async {
    try {
      // Checking if image is already cached
      final existingPath =
          await ImageCacheService.instance.getCachedImagePath(widget.mealId);
      final file = File(existingPath);

      if (await file.exists()) {
        if (mounted) {
          setState(() {
            _cachedPath = existingPath;
            _isLoading = false;
          });
          return;
        }
      }

      // If not cached, downloading and caching it
      final cachedPath = await ImageCacheService.instance.cacheImage(
        widget.mealId,
        widget.imageUrl,
      );

      if (mounted) {
        setState(() {
          _cachedPath = cachedPath;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return SizedBox(
        width: widget.width,
        height: widget.height,
        child: const LoadingView(),
      );
    }

    if (_cachedPath != null) {
      return Image.file(
        File(_cachedPath!),
        width: widget.width,
        height: widget.height,
        fit: widget.fit,
        errorBuilder: (context, error, stackTrace) => _buildErrorWidget(),
      );
    }

    return Image.network(
      widget.imageUrl,
      width: widget.width,
      height: widget.height,
      fit: widget.fit,
      errorBuilder: (context, error, stackTrace) => _buildErrorWidget(),
    );
  }

  Widget _buildErrorWidget() {
    return Container(
      width: widget.width,
      height: widget.height,
      color: Colors.grey[300],
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error, color: Colors.red),
          SizedBox(height: 8),
          Text('Failed to load image'),
        ],
      ),
    );
  }
}
