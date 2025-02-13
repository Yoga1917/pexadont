import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:pexadont/pages/tampilan_awal/layout.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PesanPengaduanPage extends StatefulWidget {
  @override
  State<PesanPengaduanPage> createState() => _PesanPengaduanPageState();
}

class _PesanPengaduanPageState extends State<PesanPengaduanPage> {
  List pengaduanData = [];
  bool isLoading = true;
  List<dynamic> filteredPesanList = [];
  int totalPesan = 0;
  bool isSearching = false;
  TextEditingController searchController = TextEditingController();
  String formattedTotalPesanPengaduan = '';

  @override
  void initState() {
    super.initState();
    _fetchPengaduan();
  }

  Future<void> _fetchPengaduan() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final nik = prefs.getString('nik');

    final request = await http
        .get(Uri.parse("https://pexadont.agsa.site/api/pengaduan/warga/$nik"));

    if (request.statusCode == 200) {
      final responseBody = json.decode(request.body);

      if (responseBody['status'] == 200) {
        final dataRaw = responseBody['data'];

        // Filter hanya yang memiliki balasan
        final data = dataRaw.where((item) => item['balasan'] != null).toList();

        // Urutkan berdasarkan tanggal terbaru
        data.sort((a, b) {
          final tglA = DateTime.parse(a['tgl']);
          final tglB = DateTime.parse(b['tgl']);
          return tglB.compareTo(tglA);
        });

        // Update URL fotoAksiBy jika ada
        final updatedData = data.map((item) {
          return {
            ...item,
            'fotoAksiBy': (item['fotoAksiBy'] != null &&
                    item['fotoAksiBy'].isNotEmpty)
                ? "https://pexadont.agsa.site/uploads/warga/${item['fotoAksiBy']}"
                : null,
          };
        }).toList();

        setState(() {
          pengaduanData = updatedData;
          filteredPesanList = updatedData;
          formattedTotalPesanPengaduan =
              NumberFormat.decimalPattern('id').format(pengaduanData.length);
          isLoading = false;
        });
      } else {
        _showError("Gagal mengambil data: ${responseBody['message']}");
      }
    } else {
      _showError("Terjadi kesalahan saat mengambil data.");
    }
  }

  void _showError(String message) {
    setState(() {
      isLoading = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void searchPesan(String query) {
    final cleanedQuery =
        query.trim().replaceAll(RegExp(r'\s+'), ' ').toLowerCase();

    if (cleanedQuery.isEmpty) {
      setState(() {
        filteredPesanList = pengaduanData;
        isSearching = false;
      });
      return;
    }

    final suggestions = pengaduanData.where((pengaduan) {
      final pesanName = pengaduan['jenis'].toLowerCase();
      return pesanName.contains(cleanedQuery);
    }).toList();

    setState(() {
      isSearching = true;
      filteredPesanList = suggestions;
      filteredPesanList.sort((a, b) {
        if (a['jenis'].toLowerCase() == cleanedQuery) return -1;
        if (b['jenis'].toLowerCase() == cleanedQuery) return 1;
        return a['jenis'].compareTo(b['jenis']);
      });
    });
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
      body: GestureDetector(
        onTap: () {
          FocusManager.instance.primaryFocus?.unfocus();
        },
        child: isLoading
            ? Center(
                child: CircularProgressIndicator(
                  color: Color(0xff30C083),
                ),
              )
            : LayoutBuilder(builder: (context, constraints) {
                if (constraints.maxWidth > 600) {
                  return Column();
                } else {
                  return Column(
                    children: [
                      SizedBox(height: 10),
                      Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                        child: TextField(
                          controller: searchController,
                          cursorColor: Color(0xff30C083),
                          decoration: InputDecoration(
                            hintText: 'Cari Pesan Pengaduan Anda...',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: Color(0xff30C083)),
                            ),
                            prefixIcon: GestureDetector(
                              onTap: () {
                                searchPesan(searchController.text);
                              },
                              child: Icon(Icons.search),
                            ),
                            suffixIcon: isSearching
                                ? IconButton(
                                    icon: Icon(Icons.clear),
                                    onPressed: () {
                                      searchController.clear();
                                      searchPesan('');
                                    },
                                  )
                                : null,
                          ),
                          onChanged: searchPesan,
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Total Pesan : '),
                          Text(
                            NumberFormat.decimalPattern('id')
                                .format(pengaduanData.length),
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(' Pesan Pengaduan'),
                        ],
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Expanded(
                        child: filteredPesanList.isEmpty
                            ? Center(
                                child: Text(
                                  'Data tidak ditemukan.',
                                ),
                              )
                            : ListView.builder(
                                itemCount: filteredPesanList.length,
                                itemBuilder: (context, index) {
                                  final pengaduan = filteredPesanList[index];
                                  return Container(
                                    margin: EdgeInsets.only(bottom: 20),
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 20),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        border: Border.all(
                                            width: 1, color: Colors.grey),
                                        borderRadius: BorderRadius.circular(20),
                                        boxShadow: [
                                          BoxShadow(
                                            color:
                                                Colors.black.withOpacity(0.2),
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
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      height: 10,
                                                    ),
                                                    Row(
                                                      children: [
                                                        Icon(
                                                          Icons.calendar_month,
                                                          size: 20,
                                                        ),
                                                        SizedBox(width: 10),
                                                        Text(
                                                          '${formatDate(pengaduan['tgl'])}',
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
                                                        width: 1,
                                                        color: Colors.grey),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            20),
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
                                                    padding:
                                                        const EdgeInsets.all(
                                                            20),
                                                    child: Column(
                                                      children: [
                                                        const Text(
                                                            "Anda Mengadukan :",
                                                            style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold)),
                                                        pengaduan['foto'] ==
                                                                null
                                                            ? SizedBox(
                                                                height: 5)
                                                            : Padding(
                                                                padding: EdgeInsets
                                                                    .symmetric(
                                                                        vertical:
                                                                            10),
                                                                child:
                                                                    ClipRRect(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              20),
                                                                  child: Image
                                                                      .network(
                                                                    'https://pexadont.agsa.site/uploads/pengaduan/${pengaduan['foto']}',
                                                                    width: double
                                                                        .infinity,
                                                                  ),
                                                                ),
                                                              ),
                                                        Text(
                                                          pengaduan['isi'],
                                                          textAlign:
                                                              TextAlign.justify,
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                                Container(
                                                  margin: const EdgeInsets.only(
                                                      top: 20),
                                                  width: double.infinity,
                                                  decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    border: Border.all(
                                                        width: 1,
                                                        color: Colors.grey),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            20),
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
                                                    padding:
                                                        const EdgeInsets.all(
                                                            20),
                                                    child: Column(
                                                      children: [
                                                        Text(
                                                          "Balasan dari",
                                                          style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                          textAlign:
                                                              TextAlign.center,
                                                        ),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                                  vertical: 5),
                                                          child:
                                                              GestureDetector(
                                                            onTap: () {
                                                              showDialog(
                                                                context:
                                                                    context,
                                                                builder:
                                                                    (BuildContext
                                                                        context) {
                                                                  return Dialog(
                                                                    shape:
                                                                        RoundedRectangleBorder(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              20),
                                                                    ),
                                                                    child:
                                                                        ClipRRect(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              20),
                                                                      child: Image
                                                                          .network(
                                                                        '${pengaduan['fotoAksiBy']}',
                                                                        fit: BoxFit
                                                                            .cover,
                                                                        width: double
                                                                            .infinity,
                                                                      ),
                                                                    ),
                                                                  );
                                                                },
                                                              );
                                                            },
                                                            child: CircleAvatar(
                                                              radius: 10,
                                                              backgroundImage:
                                                                  NetworkImage(
                                                                '${pengaduan['fotoAksiBy']}',
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                        Text(
                                                          "${pengaduan['aksiBy']} (${pengaduan['jabatanAksiBy']}) :",
                                                          style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                          textAlign:
                                                              TextAlign.center,
                                                        ),
                                                        SizedBox(height: 5),
                                                        Text(
                                                          pengaduan['balasan'] !=
                                                                  ""
                                                              ? pengaduan[
                                                                  'balasan']
                                                              : "-",
                                                          textAlign:
                                                              TextAlign.justify,
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(
                                                  height: 20,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                      ),
                    ],
                  );
                }
              }),
      ),
    );
  }
}
