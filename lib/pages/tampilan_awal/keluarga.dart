import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pexadont/pages/keluarga/konfirmasi_anggota.dart';
import 'package:pexadont/pages/keluarga/tambah_anggota.dart';
import 'package:http/http.dart' as http;
import 'package:pexadont/pages/lokasi_maps.dart';
import 'package:shared_preferences/shared_preferences.dart';

class KeluargaPage extends StatefulWidget {
  @override
  State<KeluargaPage> createState() => _KeluargaPageState();
}

class _KeluargaPageState extends State<KeluargaPage> {
  Map<String, dynamic>? keluargaData;
  List<dynamic> filteredList = [];
  List<dynamic> wargaList = [];
  bool isSearching = false;
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchKeluargaData();
    fetchWargaData();
  }

  Future<void> fetchKeluargaData() async {
    final prefs = await SharedPreferences.getInstance();
    final no_kk = prefs.getString('no_kk');

    final response = await http
        .get(Uri.parse('https://pexadont.agsa.site/api/keluarga?no_kk=$no_kk'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      setState(() {
        keluargaData = data['data'][0];
      });
    } else {
      throw Exception('Failed to load data');
    }
  }

  Future<void> fetchWargaData() async {
    final prefs = await SharedPreferences.getInstance();
    final no_kk = prefs.getString('no_kk');

    final response = await http.get(
      Uri.parse('https://pexadont.agsa.site/api/warga'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      List<dynamic> filteredList = data['data']
          .where((item) => item['status'] == "1" && item['no_kk'] == no_kk)
          .toList();

      setState(() {
        filteredList.sort((a, b) {
          // Get status values
          String statusA = a['status_keluarga']?.toString().toLowerCase() ?? '';
          String statusB = b['status_keluarga']?.toString().toLowerCase() ?? '';

          // Define priority
          int priorityA = statusA.contains('kepala')
              ? 0
              : statusA.contains('istri')
                  ? 1
                  : 2;
          int priorityB = statusB.contains('kepala')
              ? 0
              : statusB.contains('istri')
                  ? 1
                  : 2;

          return priorityA.compareTo(priorityB);
        });

        setState(() {
          wargaList = filteredList;
        });
      });
    } else {
      throw Exception('Failed to load data');
    }
  }

  String formatDate(String date) {
    if (date.isEmpty) return 'Unknown Date';
    try {
      final DateTime parsedDate = DateTime.parse(date);
      return DateFormat('dd MMMM yyyy').format(parsedDate);
    } catch (e) {
      return 'Invalid Date';
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Color(0xff30C083),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 20, top: 50),
            child: Align(
              alignment: Alignment.topLeft,
              child: Text(
                'Keluarga',
                style: TextStyle(
                    fontSize: 24,
                    color: Colors.white,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Container(
                width: screenSize.width,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
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
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(top: 30, bottom: 30),
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
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.home,
                                      color: Color(0xff30C083), size: 30),
                                  SizedBox(width: 10),
                                  Text(
                                    'Alamat Keluarga',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 20),
                              IntrinsicHeight(
                                child: Row(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    Expanded(
                                      flex: 3,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Nomor Keluarga : ${keluargaData?['no_kk'] ?? "-"}',
                                          ),
                                          Text(
                                            'Nomor Rumah : ${keluargaData?['no_rumah'] ?? "-"}',
                                          ),
                                          Text(
                                            keluargaData?['alamat'] ?? "-",
                                          ),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: GestureDetector(
                                        onTap: () {
                                          double lat = double.tryParse(
                                                  keluargaData?['latitude'] ??
                                                      '0') ??
                                              0;
                                          double lng = double.tryParse(
                                                  keluargaData?['longitude'] ??
                                                      '0') ??
                                              0;

                                          if (lat == 0 || lng == 0) {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                  content: Text(
                                                      'Lokasi tidak tersedia')),
                                            );
                                            return;
                                          }

                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  LokasiMapPage(
                                                latitude: lat,
                                                longitude: lng,
                                              ),
                                            ),
                                          );
                                        },
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.location_on,
                                              size: 30,
                                              color: Color(0xff30C083),
                                            ),
                                            Text(
                                              'Lihat Peta',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 14,
                                                  color: Color(0xff30C083)),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        TambahAnggotaKeluargaPage()),
                              );
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: const Color(0xff30C083),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(15),
                                child: Row(
                                  children: [
                                    Icon(Icons.add, color: Colors.white),
                                    SizedBox(width: 5),
                                    Text(
                                      'Anggota',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w900,
                                        fontSize: 18,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        KonfirmasiAnggotaPage()),
                              );
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: const Color(0xff30C083),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(15),
                                child: Text(
                                  'Konfirmasi',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 18,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      Center(
                        child: Text(
                          'Total Anggota Keluarga : ${wargaList.length} orang',
                        ),
                      ),
                      SizedBox(height: 20),
                      Expanded(
                        child: wargaList.isEmpty
                            ? Center(child: Text('Data tidak ditemukan.'))
                            : ListView.builder(
                                padding: EdgeInsets.zero,
                                itemCount: wargaList.length,
                                itemBuilder: (context, index) {
                                  final warga = wargaList[index];
                                  return Container(
                                    margin: EdgeInsets.only(bottom: 20),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      border: Border.all(
                                          width: 1, color: Colors.grey),
                                      borderRadius: BorderRadius.circular(20),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.withOpacity(0.5),
                                          spreadRadius: 1,
                                          blurRadius: 5,
                                          offset: Offset(0, 3),
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: <Widget>[
                                        SizedBox(height: 20),
                                        Text(
                                          warga['status_keluarga'] ??
                                              'Unknown Name',
                                          style: TextStyle(
                                            fontSize: 22,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        (warga['foto'] == null ||
                                                warga['foto'].isEmpty)
                                            ? SizedBox(height: 10)
                                            : Padding(
                                                padding:
                                                    const EdgeInsets.all(20),
                                                child: ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(20),
                                                  child: Image.network(
                                                    'https://pexadont.agsa.site/uploads/warga/${warga['foto']}',
                                                    fit: BoxFit.cover,
                                                    width: double.infinity,
                                                    errorBuilder: (context,
                                                            error,
                                                            stackTrace) =>
                                                        SizedBox(),
                                                  ),
                                                ),
                                              ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 20),
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: <Widget>[
                                              Text(
                                                warga['nama'] ?? 'Unknown Name',
                                                style: TextStyle(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              SizedBox(height: 5),
                                              Text(
                                                'Nik : ${warga['nik']}',
                                              ),
                                              SizedBox(height: 2),
                                              Text(
                                                'Jenis Kelamin : ${warga['jenis_kelamin']}',
                                              ),
                                              SizedBox(height: 2),
                                              Text(
                                                'Tempat Lahir : ${warga['tempat_lahir']}',
                                              ),
                                              SizedBox(height: 2),
                                              Text(
                                                'Tanggal Lahir : ${formatDate(warga['tgl_lahir'])}',
                                              ),
                                              SizedBox(height: 2),
                                              Text(
                                                'Agama : ${warga['agama']}',
                                              ),
                                              SizedBox(height: 2),
                                              Text(
                                                'Status Menikah : ${warga['status_nikah']}',
                                              ),
                                              SizedBox(height: 2),
                                              Text(
                                                'Nama Ayah : ${warga['nama_ayah']}',
                                              ),
                                              SizedBox(height: 2),
                                              Text(
                                                'Nama Ibu : ${warga['nama_ibu']}',
                                              ),
                                              SizedBox(
                                                height: 20,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
