import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:pexadont/pages/Pengaduan/tambah_aduan.dart';
import 'package:pexadont/pages/tampilan_awal/layout.dart';

class PengaduanPage extends StatefulWidget {
  @override
  State<PengaduanPage> createState() => _PengaduanPageState();
}

class _PengaduanPageState extends State<PengaduanPage> {
  List pengaduanData = [];
  List filteredPengaduanList = [];
  TextEditingController searchController = TextEditingController();
  bool isLoading = true;
  bool isSearching = false;
  String formattedTotalPengaduan = '';

  @override
  void initState() {
    super.initState();
    _fetchPengaduan();
  }

  Future<void> _fetchPengaduan() async {
    setState(() {
      isLoading = true;
    });

    try {
      final request = await http.get(
        Uri.parse("https://pexadont.agsa.site/api/pengaduan"),
      );

      if (request.statusCode == 200) {
        final response = json.decode(request.body);
        final data = response['data'];

        data.sort((a, b) {
          // Pastikan nilai 'tgl' tidak null
          if (a['tgl'] == null || b['tgl'] == null) return 0;

          // Konversi tanggal ke DateTime
          final tglA = DateTime.tryParse(a['tgl']);
          final tglB = DateTime.tryParse(b['tgl']);

          // Jika parsing gagal, jangan ubah urutan
          if (tglA == null || tglB == null) return 0;

          // Urutkan berdasarkan tanggal (terbaru ke terlama)
          int compareDate = tglB.compareTo(tglA);

          // Jika tanggal sama, urutkan berdasarkan id_pengaduan (terbaru ke lama)
          if (compareDate == 0) {
            int idA = int.tryParse(a['id_pengaduan'].toString()) ?? 0;
            int idB = int.tryParse(b['id_pengaduan'].toString()) ?? 0;
            return idB.compareTo(idA);
          }

          return compareDate;
        });

        final updatedData = data.map((item) {
          item['foto_warga'] = item['foto_warga'] != null
              ? "https://pexadont.agsa.site/uploads/warga/${item['foto_warga']}"
              : null;

          return item;
        }).toList();

        setState(() {
          pengaduanData = updatedData;
          filteredPengaduanList = data;

          formattedTotalPengaduan =
              NumberFormat.decimalPattern('id').format(pengaduanData.length);

          isLoading = false;
        });
      } else {
        throw Exception("Failed to fetch data: ${request.statusCode}");
      }
    } catch (error) {
      setState(() {
        isLoading = false;
      });
      print("Error fetching data: $error");
    }
  }

  void searchPengaduan(String query) {
    final cleanedQuery =
        query.trim().replaceAll(RegExp(r'\s+'), ' ').toLowerCase();

    if (cleanedQuery.isEmpty) {
      setState(() {
        filteredPengaduanList = pengaduanData;
        isSearching = false;
      });
      return;
    }

    final suggestions = pengaduanData.where((pengaduan) {
      final pengaduanName = pengaduan['jenis'].toLowerCase();
      return pengaduanName.contains(cleanedQuery);
    }).toList();

    setState(() {
      isSearching = true;
      filteredPengaduanList = suggestions;
      filteredPengaduanList.sort((a, b) {
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
          'Pengaduan',
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
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => TambahAduanPage()),
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
                                        'Aduan',
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
                            SizedBox(
                              width: 30,
                            ),
                            Expanded(
                              child: TextField(
                                controller: searchController,
                                cursorColor: Color(0xff30C083),
                                decoration: InputDecoration(
                                  hintText: 'Cari Pengaduan...',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide:
                                        BorderSide(color: Color(0xff30C083)),
                                  ),
                                  prefixIcon: GestureDetector(
                                    onTap: () {
                                      searchPengaduan(searchController.text);
                                    },
                                    child: Icon(Icons.search),
                                  ),
                                  suffixIcon: isSearching
                                      ? IconButton(
                                          icon: Icon(Icons.clear),
                                          onPressed: () {
                                            searchController.clear();
                                            searchPengaduan('');
                                          },
                                        )
                                      : null,
                                ),
                                onChanged: searchPengaduan,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Total Pengaduan : '),
                          Text(
                            NumberFormat.decimalPattern('id')
                                .format(pengaduanData.length),
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(' Pengaduan'),
                        ],
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Expanded(
                        child: filteredPengaduanList.isEmpty
                            ? Center(
                                child: Text(
                                  'Data tidak ditemukan.',
                                ),
                              )
                            : ListView.builder(
                                itemCount: filteredPengaduanList.length,
                                itemBuilder: (context, index) {
                                  final pengaduan =
                                      filteredPengaduanList[index];
                                  return Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 20),
                                    child: Container(
                                      margin: EdgeInsets.only(bottom: 20),
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
                                          ClipRRect(
                                            borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(20),
                                              topRight: Radius.circular(20),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 20),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                SizedBox(height: 20),
                                                Text(
                                                  'Pengaduan ${pengaduan['jenis']}',
                                                  style: TextStyle(
                                                    fontSize: 20,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                SizedBox(height: 10),
                                                Row(
                                                  children: [
                                                    Icon(Icons.calendar_month,
                                                        size: 20),
                                                    SizedBox(width: 10),
                                                    Text(
                                                      '${formatDate(pengaduan['tgl'])}',
                                                    ),
                                                  ],
                                                ),
                                                SizedBox(height: 10),
                                                Row(
                                                  children: [
                                                    GestureDetector(
                                                      onTap: () {
                                                        showDialog(
                                                          context: context,
                                                          builder: (BuildContext
                                                              context) {
                                                            return Dialog(
                                                              shape:
                                                                  RoundedRectangleBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            20),
                                                              ),
                                                              child: ClipRRect(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            20),
                                                                child: Image
                                                                    .network(
                                                                  pengaduan[
                                                                      'foto_warga'],
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
                                                        radius: 20,
                                                        backgroundImage:
                                                            NetworkImage(
                                                          pengaduan[
                                                              'foto_warga'],
                                                        ),
                                                      ),
                                                    ),
                                                    SizedBox(width: 10),
                                                    Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          pengaduan['nama'],
                                                          style: TextStyle(
                                                            fontSize: 18,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                        Text(
                                                          pengaduan['nik'],
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                          SizedBox(height: 10),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                bottom: 10),
                                            child: Text(
                                              'Mengadukan :',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          pengaduan['foto'] == null
                                              ? SizedBox()
                                              : Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 20,
                                                          right: 20,
                                                          top: 10,
                                                          bottom: 20),
                                                  child: ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            20),
                                                    child: Image.network(
                                                      'https://pexadont.agsa.site/uploads/pengaduan/${pengaduan['foto']}',
                                                      // fit: BoxFit.cover,
                                                      width: double.infinity,
                                                    ),
                                                  ),
                                                ),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 20),
                                            child: Text(
                                              pengaduan['isi'],
                                            ),
                                          ),
                                          SizedBox(
                                            height: 20,
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
      ),
    );
  }
}
