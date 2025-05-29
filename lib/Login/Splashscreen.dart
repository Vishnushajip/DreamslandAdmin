import 'dart:async';
import 'package:dladmin/Landing/floating_bottom_navigation_bar.dart';
import 'package:dladmin/Login/LoginPage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
 import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    navigateAfterDelay();
  }


Future<void> navigateAfterDelay() async {
  await Future.delayed(const Duration(seconds: 2));

  final prefs = await SharedPreferences.getInstance();
  final username = prefs.getString('role');

  if (mounted) {
    if (username != null && username.isNotEmpty) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Navbar()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => AdminLoginPage()),
      );
    }
  }
}


  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    double imageWidth = screenWidth * 0.6; 
    double imageHeight = screenHeight * 0.4; 

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Image.asset(
          'assets/logodream.png',
          width: imageWidth,
          height: imageHeight,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
