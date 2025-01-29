import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:pexadont/pages/tampilan_awal/layout.dart';

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
        List<dynamic> rkbList = responseData['data'];

        if (rkbList.isNotEmpty) {
          rkbList.forEach((bulanData) {
            List<dynamic> dataKegiatan = bulanData['data'] ?? [];

            dataKegiatan.forEach((item) {
              String tgl = item['tgl'] ?? '';

              if (tgl.isNotEmpty) {
                DateTime? date = DateTime.tryParse(tgl);
                if (date == null) {}
              }
            });
          });

          rkbList.forEach((bulanData) {
            List<dynamic> dataKegiatan = bulanData['data'] ?? [];
            dataKegiatan.sort((a, b) {
              try {
                String tglA = a['tgl'] ?? '';
                String tglB = b['tgl'] ?? '';

                if (tglA.isNotEmpty && tglB.isNotEmpty) {
                  DateTime? dateA = DateTime.tryParse(tglA);
                  DateTime? dateB = DateTime.tryParse(tglB);

                  if (dateA != null && dateB != null) {
                    return dateA.compareTo(dateB);
                  }
                }
              } catch (e) {}
              return 0;
            });
          });

          setState(() {
            rkbData = rkbList;
            isLoading = false;
          });
        } else {
          showSnackbar('Data kegiatan tidak ditemukan');
        }
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
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => LayoutPage(goToHome: true)),
            );
          },
        ),
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
                          final rkbBulan =
                              rkbData.reversed.toList()[index]['bulan'];
                          final rkbKegiatan =
                              rkbData.reversed.toList()[index]['data'];
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
                                    SizedBox(height: 10),
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
