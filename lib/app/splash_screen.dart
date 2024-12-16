import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pexadont/pages/mulai/start_page.dart';
import 'package:pexadont/pages/tampilan_awal/layout.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
    Future.delayed(Duration(seconds: 3), () {});
  }

  Future<void> _checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

    if (isLoggedIn) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LayoutPage()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => StartPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff30C083),
      body: Center(
        child: Text(
          'pexadon\'t',
          style: GoogleFonts.righteous(
            fontSize: 60,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
