import 'package:flutter/material.dart';
import 'package:pexadont/pages/beranda/datawarga.dart';
import 'package:pexadont/pages/beranda/fasilitas.dart';
import 'package:pexadont/pages/beranda/kas.dart';
import 'package:pexadont/pages/beranda/kegiatan.dart';
import 'package:pexadont/pages/beranda/pengaduan.dart';
import 'package:pexadont/pages/beranda/pengurus.dart';
import 'package:pexadont/pages/beranda/pesan_pengaduan.dart';
import 'package:pexadont/pages/beranda/kegiatan_bulanan.dart';
import 'package:pexadont/widget/custom_category_container.dart';
import 'package:pexadont/widget/custom_category_container_tablet.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<HomePage> {
  String? nama;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      nama = prefs.getString('nama');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              height: 150,
              decoration: BoxDecoration(
                color: Color(0xff30C083),
                borderRadius:
                    BorderRadius.only(bottomLeft: Radius.circular(40)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    SizedBox(
                      height: 50,
                    ),
                    Container(
                        child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Hallo,..',
                              style: TextStyle(
                                fontSize: 32,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              nama ?? "Loading...",
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          ],
                        ),
                        InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => PesanPengaduanPage()),
                            );
                          },
                          child: Icon(
                            Icons.email,
                            color: Colors.white,
                            size: 50,
                          ),
                        ),
                      ],
                    )),
                  ],
                ),
              ),
            ),
            SizedBox(
              height: 50,
            ),
            LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth > 600) {
                  return Column(
                    children: [
                      SizedBox(
                        height: 50,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => DataWargaPage()),
                              );
                            },
                            child: Container(
                              width: 200,
                              height: 200,
                              decoration: BoxDecoration(
                                color: const Color(0xff30C083),
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black26,
                                    blurRadius: 10,
                                    offset: Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: CustomCategoryContainerTablet(
                                  icon: Icons.group,
                                  text: 'Data Warga',
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 200,
                          ),
                          InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => PengurusPage()),
                              );
                            },
                            child: Container(
                              width: 200,
                              height: 200,
                              decoration: BoxDecoration(
                                color: const Color(0xff30C083),
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black26,
                                    blurRadius: 10,
                                    offset: Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 20),
                                child: Center(
                                  child: CustomCategoryContainerTablet(
                                    icon: Icons.feedback,
                                    text: 'Pengaduan',
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 100,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => KasPage()),
                              );
                            },
                            child: Container(
                              width: 200,
                              height: 200,
                              decoration: BoxDecoration(
                                color: const Color(0xff30C083),
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black26,
                                    blurRadius: 10,
                                    offset: Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: CustomCategoryContainerTablet(
                                  icon: Icons.account_balance_wallet,
                                  text: 'Uang KAS',
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 200,
                          ),
                          InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => KegiatanPage()),
                              );
                            },
                            child: Container(
                              width: 200,
                              height: 200,
                              decoration: BoxDecoration(
                                color: const Color(0xff30C083),
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black26,
                                    blurRadius: 10,
                                    offset: Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 20),
                                child: Center(
                                  child: CustomCategoryContainerTablet(
                                    icon: Icons.event,
                                    text: 'Kegiatan',
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 100,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => PengurusPage()),
                              );
                            },
                            child: Container(
                              width: 200,
                              height: 200,
                              decoration: BoxDecoration(
                                color: const Color(0xff30C083),
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black26,
                                    blurRadius: 10,
                                    offset: Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: CustomCategoryContainerTablet(
                                  icon: Icons.person,
                                  text: 'Pengurus',
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 200,
                          ),
                          InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => FasilitasPage()),
                              );
                            },
                            child: Container(
                              width: 200,
                              height: 200,
                              decoration: BoxDecoration(
                                color: const Color(0xff30C083),
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black26,
                                    blurRadius: 10,
                                    offset: Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 20),
                                child: Center(
                                  child: CustomCategoryContainerTablet(
                                    icon: Icons.home,
                                    text: 'Fasilitas',
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 50,
                      ),
                    ],
                  );
                } else {
                  return Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                CustomCategoryContainer(
                                  icon: Icons.group,
                                  text: 'Data Warga',
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              DataWargaPage()),
                                    );
                                  },
                                ),
                                SizedBox(height: 20),
                                CustomCategoryContainer(
                                  icon: Icons.feedback,
                                  text: 'Pengaduan',
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              PengaduanPage()),
                                    );
                                  },
                                ),
                                SizedBox(height: 20),
                                CustomCategoryContainer(
                                  icon: Icons.account_balance_wallet,
                                  text: 'Uang KAS',
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => KasPage()),
                                    );
                                  },
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 50,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                CustomCategoryContainer(
                                  icon: Icons.event,
                                  text: 'Kegiatan',
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => KegiatanPage()),
                                    );
                                  },
                                ),
                                SizedBox(height: 20),
                                CustomCategoryContainer(
                                  icon: Icons.person,
                                  text: 'Pengurus',
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => PengurusPage()),
                                    );
                                  },
                                ),
                                SizedBox(height: 20),
                                CustomCategoryContainer(
                                  icon: Icons.home,
                                  text: 'Fasilitas',
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              FasilitasPage()),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                }
              },
            ),
            SizedBox(
              height: 50,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Kegiatan Bulan Ini',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.all(
                        Radius.circular(20),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                          child: Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(width: 1, color: Colors.grey),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  spreadRadius: 1,
                                  blurRadius: 5,
                                  offset: Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(height: 20),
                                  Text(
                                    'Januari',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 20),
                                  Text(
                                    '10 Januari => Gotong Royong',
                                    style: TextStyle(
                                      fontSize: 14,
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                  Text(
                                    '15 Januari => Sholawatan',
                                    style: TextStyle(
                                      fontSize: 14,
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                  Text(
                                    '28 Januari => Pembagian Bansos',
                                    style: TextStyle(
                                      fontSize: 14,
                                    ),
                                  ),
                                  SizedBox(height: 20)
                                ],
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => KegiatanBulananPage()),
                              );
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: const Color(0xff30C083),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(15),
                                child: const Text(
                                  'Lihat Selengkapnya',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 16,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 30,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
