import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:themeparkapp/core/environment_providers.dart';

/// Adaptive image that selects a lower-quality URL or placeholder when
/// `mediaQualityProvider` indicates low quality.
class AdaptiveNetworkImage extends ConsumerWidget {
  const AdaptiveNetworkImage({
    super.key,
    required this.highResUrl,
    required this.lowResUrl,
    this.width,
    this.height,
    this.fit,
  });

  final String highResUrl;
  final String lowResUrl;
  final double? width;
  final double? height;
  final BoxFit? fit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quality = ref.watch(mediaQualityProvider);
    final url = quality == MediaQuality.low ? lowResUrl : highResUrl;

    // If urls are empty, fall back to an icon placeholder.
    if (url.isEmpty) {
      return SizedBox(
        width: width,
        height: height,
        child: Icon(Icons.image_not_supported, size: (width ?? height ?? 48) / 2),
      );
    }

    return Image.network(
      url,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (_, __, ___) => const Icon(Icons.broken_image),
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return SizedBox(
          width: width,
          height: height,
          child: const Center(child: CircularProgressIndicator()),
        );
      },
    );
  }
}
