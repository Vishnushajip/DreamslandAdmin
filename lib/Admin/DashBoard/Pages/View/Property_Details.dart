import 'package:dladmin/Services/Enlarge_Prop.dart';
import 'package:dladmin/Services/Fetch_docs.dart';
import 'package:dladmin/Services/Water_Mark.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

final currentImageIndexProvider = StateProvider<int>((ref) => 0);
final pageControllerProvider = Provider<PageController>((ref) {
  return PageController();
});

class PropertyDetailPage extends ConsumerWidget {
  final AgentProperty property;

  const PropertyDetailPage({super.key, required this.property});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentImageIndex = ref.watch(currentImageIndexProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: Text("Uploaded ${property.agent}"),
      ),
      backgroundColor: Colors.white,

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [_buildMobileLayout(context, ref, currentImageIndex)],
        ),
      ),
    );
  }

  Widget _buildMobileLayout(
    BuildContext context,
    WidgetRef ref,
    int currentImageIndex,
  ) {
    final pageController = ref.watch(pageControllerProvider);
    final currentIndex = ref.watch(currentImageIndexProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          property.name,
          style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Icon(Icons.location_on_outlined),
            Text(
              property.location,
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade400,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              height: 300,
              child: PageView.builder(
                controller: pageController,
                itemCount: property.images.length,
                onPageChanged:
                    (index) =>
                        ref.read(currentImageIndexProvider.notifier).state =
                            index,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) =>
                                  ImageViewerPage(imageUrls: property.images),
                        ),
                      );
                    },
                    child: WatermarkedImageWidget(
                      verified: property.verified,
                      imageUrl: property.images[index],
                      height: MediaQuery.of(context).size.height,
                    ),
                  );
                },
              ),
            ),
            Positioned(
              left: 10,
              child: _arrowButton(Icons.arrow_back_ios, () {
                if (currentIndex > 0) {
                  ref.read(currentImageIndexProvider.notifier).state =
                      currentIndex - 1;
                  pageController.previousPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                }
              }),
            ),
            Positioned(
              right: 10,
              child: _arrowButton(Icons.arrow_forward_ios, () {
                if (currentIndex < property.images.length - 1) {
                  ref.read(currentImageIndexProvider.notifier).state =
                      currentIndex + 1;
                  pageController.nextPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                }
              }),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [_priceAndContact(context)],
        ),
        const SizedBox(height: 16),
        _buildPropertyDetails(context),
      ],
    );
  }

  Widget _arrowButton(IconData icon, VoidCallback onTap) {
    return CircleAvatar(
      backgroundColor: Colors.black.withOpacity(0.6),
      child: IconButton(
        icon: Icon(icon, color: Colors.white, size: 16),
        onPressed: onTap,
      ),
    );
  }

  Widget _priceAndContact(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          formatIndianCurrency(property.price),
          style: GoogleFonts.poppins(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.blue.shade800,
          ),
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  Widget _buildPropertyDetails(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width <= 800;

    return Material(
      elevation: 3,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LabelValueRow(
              leftLabel: "ID Number",
              leftValue: property.propertyId,
              rightLabel: (property.sqft == "0") ? "Location" : "Sqft",
              rightValue:
                  (property.sqft == "0") ? property.location : property.sqft,
            ),
            SizedBox(height: isMobile ? 10 : 20),
            LabelValueRow(
              leftLabel: "Price",
              leftValue: formatIndianCurrency(property.price),
              rightLabel: "Listed On",
              rightValue: DateFormat(
                'dd-MM-yyyy',
              ).format(DateTime.fromMillisecondsSinceEpoch(property.listedOn)),
            ),
            SizedBox(height: isMobile ? 10 : 20),
            LabelValueRow(
              leftLabel: "Area",
              leftValue: "${property.plotArea} ${property.unit}",
              rightLabel: "Price options",
              rightValue: property.pricingOptions,
            ),
            SizedBox(height: isMobile ? 10 : 20),
            LabelValueRow(
              leftLabel:
                  (property.bhk == 0) ? "Pricingoptions" : "Configuration",
              leftValue:
                  (property.bhk == 0)
                      ? property.pricingOptions
                      : "${property.bhk} BHK",
              rightLabel: "Status",
              rightValue: property.status,
              rightValueColor:
                  property.status.toLowerCase() == 'sold'
                      ? Colors.red
                      : Colors.green,
            ),
            SizedBox(height: isMobile ? 10 : 20),
            LabelValueRow(
              leftLabel: "Property Type",
              leftValue: property.type,
              rightLabel: "Property Subtype",
              rightValue: property.subtype,
            ),
            const SizedBox(height: 20),
            Text(
              "Property Description",
              style: GoogleFonts.nunito(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              property.propertyDescription,
              style: GoogleFonts.nunito(fontSize: 14, color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }

  String formatIndianCurrency(num price) {
    if (price >= 10000000) {
      return 'INR ${(price / 10000000).toStringAsFixed(2)} Cr';
    } else if (price >= 100000) {
      return 'INR ${(price / 100000).toStringAsFixed(2)} Lakh';
    } else {
      return 'INR ${price.toStringAsFixed(0)}';
    }
  }
}

class LabelValueRow extends StatelessWidget {
  final String leftLabel;
  final String leftValue;
  final String rightLabel;
  final String rightValue;
  final TextStyle? labelStyle;
  final TextStyle? valueStyle;
  final Color? leftValueColor;
  final Color? rightValueColor;
  final double? mobileLabelSize;
  final double? desktopLabelSize;
  final double? mobileValueSize;
  final double? desktopValueSize;
  final FontWeight? labelWeight;
  final FontWeight? valueWeight;

  const LabelValueRow({
    super.key,
    required this.leftLabel,
    required this.leftValue,
    required this.rightLabel,
    required this.rightValue,
    this.labelStyle,
    this.valueStyle,
    this.leftValueColor,
    this.rightValueColor,
    this.mobileLabelSize = 12,
    this.desktopLabelSize = 14,
    this.mobileValueSize = 14,
    this.desktopValueSize = 16,
    this.labelWeight = FontWeight.w500,
    this.valueWeight = FontWeight.w600,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width <= 800;

    final defaultLabelStyle = GoogleFonts.poppins(
      fontSize: isMobile ? mobileLabelSize : desktopLabelSize,
      fontWeight: labelWeight,
      color: Colors.grey[600],
    );

    final defaultValueStyle = GoogleFonts.poppins(
      fontSize: isMobile ? mobileValueSize : desktopValueSize,
      fontWeight: valueWeight,
      color: Colors.black,
    );

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(leftLabel, style: labelStyle ?? defaultLabelStyle),
              const SizedBox(height: 4),
              Text(
                leftValue,
                style: (valueStyle ?? defaultValueStyle).copyWith(
                  color:
                      leftValueColor ??
                      valueStyle?.color ??
                      defaultValueStyle.color,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(rightLabel, style: labelStyle ?? defaultLabelStyle),
              const SizedBox(height: 4),
              Text(
                rightValue,
                style: (valueStyle ?? defaultValueStyle).copyWith(
                  color:
                      rightValueColor ??
                      valueStyle?.color ??
                      defaultValueStyle.color,
                ),
                textAlign: TextAlign.end,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
