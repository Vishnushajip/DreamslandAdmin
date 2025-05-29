import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final currentImageIndexProvider = StateProvider<int>((ref) => 0);

class ImageViewerPage extends ConsumerWidget {
  final List<String> imageUrls;

  const ImageViewerPage({super.key, required this.imageUrls});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(currentImageIndexProvider);
    final isFirst = currentIndex == 0;
    final isLast = currentIndex == imageUrls.length - 1;
    final isMobile = MediaQuery.of(context).size.width < 800;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned.fill(
              child: Center(
                child: Image.network(
                  imageUrls[currentIndex],
                  fit: isMobile ? BoxFit.contain : BoxFit.fill,
                  width: double.infinity,
                  height: double.infinity,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Colors.blue,
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) => const Center(
                    child: Icon(Icons.broken_image, color: Colors.red, size: 50),
                  ),
                ),
              ),
            ),
            if (!isFirst)
              Positioned(
                left: 16,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                  onPressed: () {
                    ref.read(currentImageIndexProvider.notifier).state--;
                  },
                ),
              ),

            if (!isLast)
              Positioned(
                right: 16,
                child: IconButton(
                  icon: const Icon(Icons.arrow_forward_ios, color: Colors.white),
                  onPressed: () {
                    ref.read(currentImageIndexProvider.notifier).state++;
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
