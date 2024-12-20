import 'package:flutter/material.dart';
import 'package:pexadont/pages/tampilan_awal/beranda.dart';
import 'package:pexadont/pages/tampilan_awal/pemberitahuan.dart';
import 'package:pexadont/pages/tampilan_awal/pengaturan.dart';

class LayoutPage extends StatefulWidget {
  final bool goToPemberitahuan;
  final bool goToHome;
  final bool goToPengaturan;

  LayoutPage({
    Key? key,
    this.goToPemberitahuan = false,
    this.goToHome = false,
    this.goToPengaturan = false,
  }) : super(key: key);

  @override
  _MyLayoutPageState createState() => _MyLayoutPageState();
}

class _MyLayoutPageState extends State<LayoutPage> {
  int _currentIndex = 0;

  final List<Widget> _children = [
    HomePage(),
    PemberitahuanPage(),
    PengaturanPage(),
  ];

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void goToPemberitahuan() {
    setState(() {
      _currentIndex = 1;
    });
  }

  void goToHome() {
    setState(() {
      _currentIndex = 0;
    });
  }

  void goToPengaturan() {
    setState(() {
      _currentIndex = 2;
    });
  }

  @override
  void initState() {
    super.initState();
    if (widget.goToPemberitahuan) {
      goToPemberitahuan();
    } else if (widget.goToHome) {
      goToHome();
    } else if (widget.goToPengaturan) {
      goToPengaturan();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _children[_currentIndex],
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
          splashColor: Colors.transparent,
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: onTabTapped,
          type: BottomNavigationBarType.fixed,
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Beranda',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.notifications_active_sharp),
              label: 'Pemberitahuan',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: 'Pengaturan',
            ),
          ],
          selectedItemColor: Color(0xff30C083),
          unselectedItemColor: Colors.black,
          showUnselectedLabels: true,
          elevation: 10,
          backgroundColor: Colors.white,
        ),
      ),
    );
  }
}
