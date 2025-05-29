import 'package:cached_network_image/cached_network_image.dart';
import 'package:dladmin/Admin/DashBoard/Pages/Search.dart';
import 'package:dladmin/Services/Enlarge_Prop.dart';
import 'package:dladmin/Services/Water_Mark.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ImageIndexNotifier extends StateNotifier<int> {
  ImageIndexNotifier() : super(0);

  void changeIndex(int index) {
    state = index;
  }
}

final imageIndexProvider = StateNotifierProvider<ImageIndexNotifier, int>((
  ref,
) {
  return ImageIndexNotifier();
});

class PropertyDetailsPage extends ConsumerWidget {
  final Map<String, dynamic> propertyData;

  const PropertyDetailsPage({super.key, required this.propertyData});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isMobile = MediaQuery.of(context).size.width <= 800;
    final images = propertyData['images'] ?? [];
    final currentIndex = ref.watch(imageIndexProvider);
    final location = propertyData['location'] ?? '';
    final verified = propertyData['verified'] ?? '';
    final imageUrl =
        (images.isNotEmpty && currentIndex < images.length)
            ? images[currentIndex]
            : '';
    final List<String> image = List<String>.from(propertyData['images'] ?? []);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: true,
        surfaceTintColor: Colors.transparent,
        backgroundColor: Colors.white,
        title: Text('Property Details', style: GoogleFonts.nunito()),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: Search(),
            ),
            Padding(
              padding: const EdgeInsets.all(18.0),
              child: Column(
                children: [
                  Container(
                    width:
                        isMobile
                            ? double.infinity
                            : MediaQuery.of(context).size.width * 0.4,
                    height: MediaQuery.of(context).size.height * 0.4,
                    decoration: BoxDecoration(color: Colors.white),
                    child:
                        imageUrl.isNotEmpty
                            ? GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) =>
                                            ImageViewerPage(imageUrls: image),
                                  ),
                                );
                              },
                              child: WatermarkedImageWidget(
                                verified: verified,
                                imageUrl: imageUrl,
                                height: MediaQuery.of(context).size.height,
                              ),
                            )
                            : const Center(
                              child: Icon(
                                Icons.home,
                                size: 50,
                                color: Colors.grey,
                              ),
                            ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 12.0),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: List.generate(images.length, (index) {
                          return GestureDetector(
                            onTap: () {
                              ref
                                  .read(imageIndexProvider.notifier)
                                  .changeIndex(index);
                            },
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 5),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color:
                                      currentIndex == index
                                          ? Colors.blue
                                          : Colors.transparent,
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: CachedNetworkImage(
                                  imageUrl: images[index],
                                  width: isMobile ? 50 : 100,
                                  height: isMobile ? 40 : 80,
                                  fit: BoxFit.fill,
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                color: Colors.white,
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              propertyData['name'] ?? 'Unnamed Property',
                              style: GoogleFonts.nunito(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green[50],
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.green),
                            ),
                            child: Text(
                              propertyData['status'] ?? 'Available',
                              style: GoogleFonts.nunito(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.green[700],
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      Row(
                        children: [
                          Text(
                            formatIndianCurrency(
                              propertyData['price'] ?? 'N/A',
                            ),
                            style: GoogleFonts.nunito(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.green[700],
                            ),
                          ),
                          SizedBox(width: 8),
                        ],
                      ),
                      SizedBox(height: 16),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          if (propertyData['bhk'] != null)
                            _buildFeatureChip('${propertyData['bhk']} BHK'),
                          if (propertyData['sqft'] != null)
                            _buildFeatureChip('${propertyData['sqft']} sqft'),
                          if (propertyData['type'] != null)
                            _buildFeatureChip(propertyData['type']),
                          if (propertyData['subtype'] != null)
                            _buildFeatureChip(propertyData['subtype']),
                        ],
                      ),
                      SizedBox(height: 16),
                      _buildDetailRow(Icons.location_on, location),
                      if (propertyData['propertyId'] != null)
                        _buildDetailRow(
                          Icons.tag,
                          'ID: ${propertyData['propertyId']}',
                        ),
                      if (propertyData['Pricingoptions'] != null)
                        _buildDetailRow(
                          Icons.currency_rupee,
                          'Pricing: ${propertyData['Pricingoptions']}',
                        ),
                      if (propertyData['listedOn'] is num)
                        _buildDetailRow(
                          Icons.calendar_today,
                          'Listed On: ${DateFormat('dd MMM yyyy').format(DateTime.fromMillisecondsSinceEpoch((propertyData['listedOn'] as num).toInt()))}',
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureChip(String text) {
    return Chip(
      label: Text(text, style: GoogleFonts.nunito(fontSize: 14)),
      backgroundColor: Colors.blue[50],
      shape: StadiumBorder(side: BorderSide(color: Colors.blue[100]!)),
    );
  }

  Widget _buildDetailRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          SizedBox(width: 12),
          Expanded(child: Text(text, style: GoogleFonts.nunito(fontSize: 16))),
        ],
      ),
    );
  }
}

String formatIndianCurrency(num price) {
  if (price >= 10000000) {
    double crore = price / 10000000;
    return 'INR ${crore.toStringAsFixed(2)} Cr';
  } else if (price >= 100000) {
    double lakh = price / 100000;
    return 'INR ${lakh.toStringAsFixed(2)} Lakh';
  } else {
    return 'INR ${price.toStringAsFixed(2)}';
  }
}
