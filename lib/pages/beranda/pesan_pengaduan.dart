import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class PesanPengaduanPage extends StatefulWidget {
  @override
  State<PesanPengaduanPage> createState() => _PesanPengaduanPageState();
}

class _PesanPengaduanPageState extends State<PesanPengaduanPage> {
  List pengaduanData = [];

  @override
  void initState() {
    super.initState();
    _fetchPengaduan();
  }

  Future<void> _fetchPengaduan() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final nik = prefs.getString('nik');

    final request = await http.get(
        Uri.parse("https://pexadont.agsa.site/api/pengaduan/warga/${nik}"));
    final dataRaw = json.decode(request.body)['data'];
    final data = dataRaw.where((item) => item['balasan'] != null).toList();

    data.sort((a, b) {
      final tglA = DateTime.parse(a['tgl']);
      final tglB = DateTime.parse(b['tgl']);
      return tglB.compareTo(tglA);
    });

    setState(() {
      pengaduanData = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xff30C083),
        title: Text(
          'Pesan Pengaduan',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: LayoutBuilder(builder: (context, constraints) {
        if (constraints.maxWidth > 600) {
          return Column();
        } else {
          return Column(
            children: [
              SizedBox(
                height: 30,
              ),
              pengaduanData.isEmpty
                  ? Center(child: Text("Belum ada data pengaduan"))
                  : Expanded(
                      child: ListView.builder(
                          itemCount: pengaduanData.length,
                          itemBuilder: (context, index) {
                            final pengaduan = pengaduanData[index];
                            return Container(
                              margin: EdgeInsets.only(bottom: 30),
                              padding: EdgeInsets.symmetric(horizontal: 20),
                              child: Container(
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
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 20),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: <Widget>[
                                          SizedBox(height: 20),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Pengaduan ${pengaduan['jenis']}',
                                                style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              SizedBox(
                                                height: 6,
                                              ),
                                              Row(
                                                children: [
                                                  Icon(Icons.calendar_month,
                                                      size: 20,
                                                      color: Colors.black),
                                                  SizedBox(width: 5),
                                                  Text(
                                                    pengaduan['tgl'],
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: 20),
                                          Container(
                                            width: double.infinity,
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              border: Border.all(
                                                  width: 1, color: Colors.grey),
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black
                                                      .withOpacity(0.2),
                                                  spreadRadius: 1,
                                                  blurRadius: 5,
                                                  offset: Offset(0, 3),
                                                ),
                                              ],
                                            ),
                                            child: Padding(
                                              padding: const EdgeInsets.all(20),
                                              child: Column(
                                                children: [
                                                  const Text("Pengaduanmu :",
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold)),
                                                  SizedBox(height: 10),
                                                  pengaduan['foto'] == null
                                                      ? SizedBox()
                                                      : Container(
                                                          margin:
                                                              const EdgeInsets
                                                                  .only(
                                                                  bottom: 20),
                                                          padding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                                  horizontal:
                                                                      20),
                                                          child: ClipRRect(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        20),
                                                            child:
                                                                Image.network(
                                                              'https://pexadont.agsa.site/uploads/pengaduan/${pengaduan['foto']}',
                                                              // fit: BoxFit.cover,
                                                              width: double
                                                                  .infinity,
                                                            ),
                                                          ),
                                                        ),
                                                  Text(
                                                    pengaduan['isi'],
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      color: Colors.black,
                                                    ),
                                                    textAlign:
                                                        TextAlign.justify,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          Container(
                                            margin:
                                                const EdgeInsets.only(top: 10),
                                            width: double.infinity,
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              border: Border.all(
                                                  width: 1, color: Colors.grey),
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black
                                                      .withOpacity(0.2),
                                                  spreadRadius: 1,
                                                  blurRadius: 5,
                                                  offset: Offset(0, 3),
                                                ),
                                              ],
                                            ),
                                            child: Padding(
                                              padding: const EdgeInsets.all(20),
                                              child: Column(
                                                children: [
                                                  const Text("Balasan :",
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold)),
                                                  SizedBox(height: 10),
                                                  Text(
                                                    pengaduan['balasan'] ?? "-",
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      color: Colors.black,
                                                    ),
                                                    textAlign:
                                                        TextAlign.justify,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                            height: 30,
                                          ),
                                        ],
                                      ),
                                    ),
                                    ClipRRect(
                                      borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(20),
                                        topRight: Radius.circular(20),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }),
                    ),
            ],
          );
        }
      }),
    );
  }
}
