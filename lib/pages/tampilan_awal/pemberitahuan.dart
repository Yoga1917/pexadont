import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class PemberitahuanPage extends StatefulWidget {
  @override
  _MyPemberitahuanPageState createState() => _MyPemberitahuanPageState();
}

class _MyPemberitahuanPageState extends State<PemberitahuanPage> {
  List<dynamic> pemberitahuanList = [];
  List<dynamic> filteredPemberitahuanList = [];
  TextEditingController searchController = TextEditingController();
  bool isSearching = false;
  bool isLoading = true;
  List<bool> isExpanded = [];

  @override
  void initState() {
    super.initState();
    fetchPemberitahuanData();
  }

  Future<void> fetchPemberitahuanData() async {
    final response = await http
        .get(Uri.parse('https://pexadont.agsa.site/api/pemberitahuan'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print('Data dari api: $data');
      setState(() {
        pemberitahuanList = (data['data'] as List)
            .map(
              (item) => {
                'id_pemberitahuan': item['id_pemberitahuan']?.toString() ?? "0",
                'pemberitahuan': item['pemberitahuan'],
                'deskripsi': item['deskripsi'],
                'tgl': item['tgl']?.toString() ?? '',
                'file': item['file'] != null && item['file'].isNotEmpty
                    ? 'https://pexadont.agsa.site/uploads/pemberitahuan/${item['file']}'
                    : null,
                'aksiBy': item['aksiBy'],
                'fotoAksiBy': item['fotoAksiBy'],
                'isExpanded': false,
              },
            )
            .toList();

        pemberitahuanList.sort((a, b) {
          String tglA = a['tgl'] ?? '';
          String tglB = b['tgl'] ?? '';

          DateTime dateA = DateTime.parse(tglA);
          DateTime dateB = DateTime.parse(tglB);

          int dateComparison = dateB.compareTo(dateA);
          if (dateComparison == 0) {
            String idA = a['id_pemberitahuan'] ?? "0";
            String idB = b['id_pemberitahuan'] ?? "0";

            int idAInt = int.tryParse(idA) ?? 0;
            int idBInt = int.tryParse(idB) ?? 0;

            return idBInt.compareTo(idAInt);
          }
          return dateComparison;
        });

        filteredPemberitahuanList = pemberitahuanList;
        isLoading = false;
      });
    } else {
      throw Exception('Failed to load data: ${response.statusCode}');
    }
  }

  Future<void> downloadFile(String url) async {
    try {
      final Uri fileUri = Uri.parse(url);
      if (await canLaunchUrl(fileUri)) {
        await launchUrl(fileUri, mode: LaunchMode.externalApplication);
      } else {
        throw 'Tidak dapat membuka URL: $url';
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mengunduh file: $e')),
      );
    }
  }

  void searchPemberitahuan(String query) {
    final cleanedQuery =
        query.trim().replaceAll(RegExp(r'\s+'), ' ').toLowerCase();

    if (cleanedQuery.isEmpty) {
      setState(() {
        filteredPemberitahuanList = pemberitahuanList;
        isSearching = false;
      });
      return;
    }

    final suggestions = pemberitahuanList.where((pemberitahuan) {
      final pemberitahuanName = pemberitahuan['pemberitahuan'].toLowerCase();
      return pemberitahuanName.contains(cleanedQuery);
    }).toList();

    setState(() {
      isSearching = true;
      filteredPemberitahuanList = suggestions;
      filteredPemberitahuanList.sort((a, b) {
        if (a['pemberitahuan'].toLowerCase() == cleanedQuery) return -1;
        if (b['pemberitahuan'].toLowerCase() == cleanedQuery) return 1;
        return a['pemberitahuan'].compareTo(b['pemberitahuan']);
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
      backgroundColor: Color(0xff30C083),
      body: GestureDetector(
        onTap: () {
          FocusManager.instance.primaryFocus?.unfocus();
        },
        child: Column(
          children: [
            SizedBox(height: 50),
            Padding(
              padding: const EdgeInsets.only(left: 20),
              child: Align(
                alignment: Alignment.topLeft,
                child: Text(
                  'Pemberitahuan',
                  style: TextStyle(
                      fontSize: 24,
                      color: Colors.white,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
            SizedBox(height: 10),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
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
                    Padding(
                      padding: EdgeInsets.only(
                          left: 20, right: 20, top: 30, bottom: 20),
                      child: TextField(
                        controller: searchController,
                        cursorColor: Color(0xff30C083),
                        decoration: InputDecoration(
                          hintText: 'Cari Pengumuman...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide(color: Color(0xff30C083)),
                          ),
                          prefixIcon: GestureDetector(
                            onTap: () {
                              searchPemberitahuan(searchController.text);
                            },
                            child: Icon(Icons.search),
                          ),
                          suffixIcon: isSearching
                              ? IconButton(
                                  icon: Icon(Icons.clear),
                                  onPressed: () {
                                    searchController.clear();
                                    searchPemberitahuan('');
                                  },
                                )
                              : null,
                        ),
                        onChanged: searchPemberitahuan,
                      ),
                    ),
                    Expanded(
                      child: filteredPemberitahuanList.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Data tidak ditemukan.',
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              padding: EdgeInsets.zero,
                              itemCount: filteredPemberitahuanList.length,
                              itemBuilder: (context, index) {
                                final pemberitahuan =
                                    filteredPemberitahuanList[index];
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20),
                                  child: Container(
                                    margin: const EdgeInsets.only(bottom: 20),
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      border: Border.all(
                                          width: 1, color: Colors.grey),
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
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 20),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              SizedBox(height: 20),
                                              Text(
                                                pemberitahuan['pemberitahuan'],
                                                style: TextStyle(
                                                    fontSize: 20,
                                                    color: Colors.black,
                                                    fontWeight:
                                                        FontWeight.bold),
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
                                                                          10),
                                                              child:
                                                                  Image.network(
                                                                'https://pexadont.agsa.site/uploads/warga/${pemberitahuan['fotoAksiBy']}',
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
                                                        'https://pexadont.agsa.site/uploads/warga/${pemberitahuan['fotoAksiBy']}',
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    width: 10,
                                                  ),
                                                  Text(
                                                    '${pemberitahuan['aksiBy']}',
                                                  ),
                                                ],
                                              ),
                                              SizedBox(height: 10),
                                              Row(
                                                children: [
                                                  Icon(
                                                      Icons
                                                          .calendar_month_outlined,
                                                      size: 20),
                                                  SizedBox(width: 10),
                                                  Text(
                                                    '${formatDate(pemberitahuan['tgl'])}',
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                        SizedBox(height: 15),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 20),
                                          child: Column(
                                            children: [
                                              Container(
                                                width: double.infinity,
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  border: Border.all(
                                                      width: 1,
                                                      color: Colors.grey),
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
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 20,
                                                      vertical: 20),
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        pemberitahuan[
                                                                'isExpanded']
                                                            ? pemberitahuan[
                                                                'deskripsi']
                                                            : (pemberitahuan[
                                                                            'deskripsi']
                                                                        .length >
                                                                    100
                                                                ? pemberitahuan[
                                                                            'deskripsi']
                                                                        .substring(
                                                                            0,
                                                                            100) +
                                                                    '...'
                                                                : pemberitahuan[
                                                                    'deskripsi']),
                                                        textAlign:
                                                            TextAlign.justify,
                                                      ),
                                                      SizedBox(height: 10),
                                                      if (pemberitahuan[
                                                                  'deskripsi']
                                                              .length >
                                                          100) ...[
                                                        GestureDetector(
                                                          onTap: () {
                                                            setState(() {
                                                              pemberitahuan[
                                                                      'isExpanded'] =
                                                                  !pemberitahuan[
                                                                      'isExpanded'];
                                                            });
                                                          },
                                                          child: Align(
                                                            alignment: Alignment
                                                                .bottomRight,
                                                            child: Text(
                                                              pemberitahuan[
                                                                      'isExpanded']
                                                                  ? 'Klik lagi untuk sembunyikan'
                                                                  : 'Lihat selengkapnya',
                                                              style: TextStyle(
                                                                color: Color(
                                                                    0xff30C083),
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                decoration:
                                                                    TextDecoration
                                                                        .underline,
                                                                decorationColor:
                                                                    Color(
                                                                        0xff30C083),
                                                                height: 1.5,
                                                                decorationThickness:
                                                                    2,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              SizedBox(height: 20),
                                              GestureDetector(
                                                onTap: () async {
                                                  final fileUrl =
                                                      pemberitahuan['file'];
                                                  if (fileUrl != null &&
                                                      fileUrl.isNotEmpty) {
                                                    await downloadFile(fileUrl);
                                                  } else {
                                                    ScaffoldMessenger.of(
                                                            context)
                                                        .showSnackBar(SnackBar(
                                                      content: Text(
                                                          'File tidak ada'),
                                                      backgroundColor:
                                                          Colors.red,
                                                    ));
                                                  }
                                                },
                                                child: Container(
                                                  alignment: Alignment.center,
                                                  width: double.infinity,
                                                  decoration: BoxDecoration(
                                                    color:
                                                        pemberitahuan['file'] !=
                                                                    null &&
                                                                pemberitahuan[
                                                                        'file']
                                                                    .isNotEmpty
                                                            ? const Color(
                                                                0xff30C083)
                                                            : Colors.red,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
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
                                                            10),
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .center,
                                                      children: [
                                                        Icon(
                                                          Icons.download,
                                                          color: Colors.white,
                                                          size: 20,
                                                        ),
                                                        SizedBox(
                                                          width: 5,
                                                        ),
                                                        Text(
                                                          'Download',
                                                          style: TextStyle(
                                                            color: Colors.white,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 16,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                        SizedBox(height: 20),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
