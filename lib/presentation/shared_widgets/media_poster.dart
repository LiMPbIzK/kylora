import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

/// Póster de contenido (película o serie) con placeholder.
/// Usa la proporción 2:3 típica de los carteles.
class MediaPoster extends StatelessWidget {
  const MediaPoster({super.key, this.url, this.fallbackIcon = Icons.movie});

  final String? url;
  final IconData fallbackIcon;

  @override
  Widget build(BuildContext context) {
    final String? imageUrl = url;
    if (imageUrl == null || imageUrl.isEmpty) {
      return _fallback;
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: CachedNetworkImage(
        imageUrl: imageUrl,
        fit: BoxFit.cover,
        placeholder: (context, url) => _fallback,
        errorWidget: (context, url, error) => _fallback,
      ),
    );
  }

  Widget get _fallback => Container(
    color: AppColors.surfaceVariant,
    alignment: Alignment.center,
    child: Icon(fallbackIcon, color: AppColors.primary, size: 32),
  );
}
