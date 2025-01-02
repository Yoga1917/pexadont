import 'package:flutter/material.dart';
import 'package:pexadont/pages/mulai/login.dart';
import 'package:pexadont/pages/pengaturan/edit_profil.dart';
import 'package:pexadont/pages/pengaturan/ganti_sandi.dart';
import 'package:pexadont/pages/pengaturan/kebijakan_privasi.dart';
import 'package:pexadont/pages/pengaturan/pusat_bantuan.dart';
import 'package:pexadont/pages/pengaturan/syarat.dart';
import 'package:pexadont/pages/pengaturan/tentang_aplikasi.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PengaturanPage extends StatefulWidget {
  @override
  _MyPengaturanPageState createState() => _MyPengaturanPageState();
}

class _MyPengaturanPageState extends State<PengaturanPage> {
  bool _showProfilePicture = false;
  String? nama;
  String? nik;

  @override 
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      nama = prefs.getString('nama');
      nik = prefs.getString('nik');
    });
  }

  Future<void> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Hapus semua data yang disimpan
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Color(0xff30C083),
      body: Stack(
        children: <Widget>[
          SingleChildScrollView(
            child: Center(
              child: Column(
                children: [
                  SizedBox(
                    height: 80,
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _showProfilePicture = !_showProfilePicture;
                      });
                    },
                    child: Icon(
                      Icons.person_pin,
                      size: 150,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    nama ?? "Load Nama...",
                    style: TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                        fontWeight: FontWeight.bold),
                  ),
                  Text(
                    nik ?? "Load NIK...",
                    style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.bold),
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  Container(
                    width: screenSize.width,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(50),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          spreadRadius: 2,
                          blurRadius: 10,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        SizedBox(
                          height: 20,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Pengaturan',
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        ListTile(
                          leading: Icon(Icons.person, color: Colors.black),
                          title: Text(
                            'Edit Profile',
                            style: TextStyle(
                              color: Colors.black,
                            ),
                          ),
                          trailing: Icon(
                            Icons.arrow_forward_ios,
                            color: Colors.black,
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => EditProfilPage()),
                            );
                          },
                        ),
                        Divider(),
                        ListTile(
                          leading: Icon(Icons.lock, color: Colors.black),
                          title: Text(
                            'Ganti Password',
                            style: TextStyle(
                              color: Colors.black,
                            ),
                          ),
                          trailing: Icon(
                            Icons.arrow_forward_ios,
                            color: Colors.black,
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => GantiSandiPage()),
                            );
                          },
                        ),
                        Divider(),
                        ListTile(
                          leading: Icon(Icons.help, color: Colors.black),
                          title: Text(
                            'Pusat Bantuan',
                            style: TextStyle(
                              color: Colors.black,
                            ),
                          ),
                          trailing: Icon(
                            Icons.arrow_forward_ios,
                            color: Colors.black,
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => PusatBantuanPage()),
                            );
                          },
                        ),
                        Divider(),
                        ListTile(
                          leading: Icon(Icons.warning, color: Colors.black),
                          title: Text(
                            'Syarat',
                            style: TextStyle(
                              color: Colors.black,
                            ),
                          ),
                          trailing: Icon(
                            Icons.arrow_forward_ios,
                            color: Colors.black,
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => SyaratPage()),
                            );
                          },
                        ),
                        Divider(),
                        ListTile(
                          leading: Icon(Icons.privacy_tip, color: Colors.black),
                          title: Text(
                            'Kebijakan Privasi',
                            style: TextStyle(
                              color: Colors.black,
                            ),
                          ),
                          trailing: Icon(
                            Icons.arrow_forward_ios,
                            color: Colors.black,
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => KebijakanPrivasiPage()),
                            );
                          },
                        ),
                        Divider(),
                        ListTile(
                          leading: Icon(Icons.info, color: Colors.black),
                          title: Text(
                            'Tentang Aplikasi',
                            style: TextStyle(
                              color: Colors.black,
                            ),
                          ),
                          trailing: Icon(
                            Icons.arrow_forward_ios,
                            color: Colors.black,
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => TentangAplikasiPage()),
                            );
                          },
                        ),
                        SizedBox(
                          height: 30,
                        ),
                        Container(
                          margin: EdgeInsets.symmetric(horizontal: 20),
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xff30C083),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Text("Konfirmasi Keluar"),
                                    content:
                                        Text("Apakah Anda yakin ingin keluar?"),
                                    actions: <Widget>[
                                      TextButton(
                                        child: Text(
                                          "Batal",
                                          style: TextStyle(
                                            color: Color(0xff30C083),
                                          ),
                                        ),
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                      ),
                                      TextButton(
                                        child: Text(
                                          "Keluar",
                                          style: TextStyle(
                                            color: Color(0xff30C083),
                                          ),
                                        ),
                                        onPressed: () {
                                          logout();
                                        },
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                            child: Text(
                              'Keluar',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
