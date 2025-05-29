import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';
import 'package:cached_network_image/cached_network_image.dart';

final propertiesProvider =
    FutureProvider<List<Map<String, dynamic>>>((ref) async {
  try {
    final snapshot = await FirebaseFirestore.instance
        .collection('property_location')
        .orderBy('location')
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      return {
        'location': data['location'] ?? 'Unknown',
        'imageUrl': data['imageurl'] ?? '',
        'propertyId': doc.id,
      };
    }).toList();
  } catch (e) {
    print("Error fetching properties: $e");
    return [];
  }
});

class PropertiesPage extends ConsumerWidget {
  const PropertiesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isMobile = MediaQuery.of(context).size.width < 800;
    final propertiesAsync = ref.watch(propertiesProvider);

    return Dialog(
      insetPadding: const EdgeInsets.all(20),
      child: Container(
        width: isMobile
            ? MediaQuery.of(context).size.width * 0.9
            : MediaQuery.of(context).size.width * 0.7,
        height: MediaQuery.of(context).size.height * 0.6,
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: propertiesAsync.when(
          loading: () => const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(
                  strokeAlign: 1,
                  semanticsLabel: 'Loading Locations',
                  color: Color.fromARGB(255, 17, 70, 114),
                  strokeWidth: 10,
                ),
                SizedBox(height: 16),
                Text(
                  'Loading Locations...',
                  style: TextStyle(
                    color: Color.fromARGB(255, 17, 70, 114),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          error: (error, stack) => Center(
            child: Text('Error loading properties: $error'),
          ),
          data: (properties) => LayoutBuilder(
            builder: (context, constraints) {
              return GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: isMobile ? 3 : 6,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 3 / 2,
                ),
                itemCount: properties.length,
                itemBuilder: (context, index) {
                  final property = properties[index];
                  final location = property['location'] ?? 'Unknown';
                  final imageUrl = property['imageUrl'] ?? '';

                  return _buildPropertyTile(imageUrl, location);
                },
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildPropertyTile(String imageUrl, String location) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(5),
      child: Stack(
        children: [
          Container(
            height: 100,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              color: Colors.grey[200],
            ),
            child: CachedNetworkImage(
              imageUrl: imageUrl,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
              placeholder: (context, url) => Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!,
                child: Container(
                  width: double.infinity,
                  height: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    color: Colors.grey[300],
                  ),
                ),
              ),
              errorWidget: (context, url, error) => Container(
                decoration: BoxDecoration(
                  color: Colors.grey,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.error,
                  color: Colors.red,
                  size: 40,
                ),
              ),
            ),
          ),
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                location,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.nunito(
                  color: Colors.white,
                  fontSize: location.length > 15 ? 10 : 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
