import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class KegiatanBulananPage extends StatefulWidget {
  @override
  State<KegiatanBulananPage> createState() => _KegiatanBulananPageState();
}

class _KegiatanBulananPageState extends State<KegiatanBulananPage> {
  String? selectedYear;
  List<dynamic> rkbData = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _getRkb();
  }

  void _getRkb() async {
    var tahun = selectedYear ?? DateTime.now().year;

    try {
      final response = await http.get(
        Uri.parse('https://pexadont.agsa.site/api/rkb?tahun=${tahun}'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        setState(() {
          rkbData = responseData['data'];
          isLoading = false;
        });
      } else {
        showSnackbar('Gagal memuat kegiatan bulanan');
      }
    } catch (e) {
      showSnackbar('Terjadi kesalahan: $e');
    }
  }

  void showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  String formatTgl(String tgl) {
    final tanggal = DateFormat("yyyy-MM-dd").parse(tgl);
    final bulans = [
      "Januari",
      "Februari",
      "Maret",
      "April",
      "Mei",
      "Juni",
      "Juli",
      "Agustus",
      "September",
      "Oktober",
      "November",
      "Desember"
    ];
    return DateFormat("dd").format(tanggal) +
        " " +
        bulans[int.parse(DateFormat("MM").format(tanggal)) - 1];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xff30C083),
        title: Text(
          'Kegiatan Tahun Ini',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: Color(0xff30C083),
              ),
            )
          : SingleChildScrollView(
              child: LayoutBuilder(builder: (context, constraints) {
                if (constraints.maxWidth > 600) {
                  return Column();
                } else {
                  return Column(
                    children: [
                      SizedBox(
                        height: 30,
                      ),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: rkbData.length,
                        itemBuilder: (context, index) {
                          final rkbBulan = rkbData[index]['bulan'];
                          final rkbKegiatan = rkbData[index]['data'];
                          return Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20),
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 20),
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border:
                                    Border.all(width: 1, color: Colors.grey),
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
                                      rkbBulan,
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: 20),
                                    rkbKegiatan.length > 0
                                        ? Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              for (var item in rkbKegiatan)
                                                Container(
                                                  margin: const EdgeInsets.only(
                                                      bottom: 5),
                                                  child: Text(
                                                    formatTgl(item['tgl']) +
                                                        " => " +
                                                        item['keterangan'],
                                                    style: const TextStyle(
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                ),
                                              const SizedBox(height: 20)
                                            ],
                                          )
                                        : Container(
                                            margin: const EdgeInsets.only(
                                                bottom: 20),
                                            child: const Text(
                                              'Tidak ada kegiatan di bulan ini.',
                                              style: TextStyle(
                                                fontSize: 14,
                                              ),
                                            ),
                                          ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      SizedBox(
                        height: 30,
                      ),
                    ],
                  );
                }
              }),
            ),
    );
  }
}
