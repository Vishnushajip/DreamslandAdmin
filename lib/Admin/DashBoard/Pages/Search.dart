
import 'package:dladmin/Admin/DashBoard/Pages/Fetch_location.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

class Search extends ConsumerWidget {
  const Search({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isMobile = screenWidth < 600;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Stack(
        children: [
          Container(
            width: isMobile
                ? MediaQuery.of(context).size.width
                : screenWidth * 0.5,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  spreadRadius: 1,
                  blurRadius: 2,
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.only(left: 50.0),
              child: TextField(
                enabled: false,
                cursorColor: Colors.black,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 10.0,
                    horizontal: 12.0,
                  ),
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  border: InputBorder.none,
                  hintText: 'Search',
                  hintStyle: GoogleFonts.poppins(
                    fontSize: isMobile ? 9 : 14,
                    color: Colors.grey,
                  ),
                  suffixIcon: Icon(
                    CupertinoIcons.search_circle_fill,
                    color: const Color.fromARGB(255, 17, 70, 114),
                    size: 35,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: 5,
            top: 0,
            bottom: 0,
            child: IconButton(
              onPressed: () {
                showDialog(
                  context: context,
                  barrierDismissible: true,
                  builder: (context) => const PropertiesPage(),
                );
              },
              icon: const Icon(
                Icons.location_on_outlined,
                color: Color.fromARGB(255, 17, 70, 114),
                size: 25,
              ),
            ),
          )
        ],
      ),
    );
  }
}
