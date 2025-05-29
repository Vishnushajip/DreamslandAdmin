import 'package:dladmin/Services/Cache.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';

class WatermarkedImageWidget extends StatelessWidget {
  final String imageUrl;
  final String verified;
  final double height;

  static const String phoneNumber = "+91 62380 61066";
  static const String website = "www.dreamslandrealty.com";

  const WatermarkedImageWidget({
    super.key,
    required this.imageUrl,
    required this.verified,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(5),
      child: Stack(
        children: [
          CachedNetworkImage(
            cacheManager: CustomCacheManager(),
            placeholder: (_, __) => Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Container(color: Colors.white),
            ),
            errorWidget: (_, __, ___) => Container(
              color: Colors.grey[200],
              child: const Center(child: Icon(Icons.broken_image)),
            ),
            imageUrl: imageUrl,
            width: double.infinity,
            height: height,
            fit: BoxFit.fill,
          ),
          Positioned(
            top: 10,
            left: 10,
            child: Row(
              children: [
                Icon(
                  CupertinoIcons.phone,
                  color: Colors.white.withOpacity(0.6),
                  size: 16,
                ),
                Text(
                  phoneNumber,
                  style: GoogleFonts.nunito(
                    fontWeight: FontWeight.bold,
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            right: 10,
            top: 120,
            child: Transform.rotate(
              angle: -0.0,
              child: Text(
                website,
                style: GoogleFonts.nunito(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                ),
              ),
            ),
          ),
          if (verified == "Verified by Admin")
            Align(
                alignment: Alignment.topRight,
                child: Container(
                  margin: const EdgeInsets.all(8),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.blue.shade100),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.verified, size: 16, color: Colors.blue),
                      SizedBox(width: 4),
                      Text("DL Verified", style: TextStyle(fontSize: 12)),
                    ],
                  ),
                )),
        ],
      ),
    );
  }
}
