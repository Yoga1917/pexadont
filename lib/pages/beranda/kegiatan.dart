import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pexadont/pages/tampilan_awal/layout.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;

class KegiatanPage extends StatefulWidget {
  @override
  State<KegiatanPage> createState() => _KegiatanPageState();
}

class _KegiatanPageState extends State<KegiatanPage> {
  List<dynamic> kegiatanList = [];
  List<dynamic> filteredKegiatanList = [];
  TextEditingController searchController = TextEditingController();
  bool isSearching = false;
  List<bool> isExpanded = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchKegiatanData();
  }

  Future<void> fetchKegiatanData() async {
    final response =
        await http.get(Uri.parse('https://pexadont.agsa.site/api/kegiatan'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      setState(() {
        kegiatanList = responseData['data'];
        for (var kegiatan in kegiatanList) {
          kegiatan['isExpanded'] = false;
        }

        kegiatanList = kegiatanList.map((kegiatan) {
          kegiatan['foto_ketua_pelaksana'] = kegiatan['foto_ketua_pelaksana'] !=
                  null
              ? "https://pexadont.agsa.site/uploads/warga/${kegiatan['foto_ketua_pelaksana']}"
              : null;
          return kegiatan;
        }).toList();

        kegiatanList.sort((a, b) {
          DateTime tglA = DateTime.parse(a['tgl']);
          DateTime tglB = DateTime.parse(b['tgl']);

          if (tglA == tglB) {
            return int.parse(b['id_kegiatan'])
                .compareTo(int.parse(a['id_kegiatan']));
          }

          return tglB.compareTo(tglA);
        });

        filteredKegiatanList = kegiatanList;
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

  void searchKegiatan(String query) {
    final cleanedQuery =
        query.trim().replaceAll(RegExp(r'\s+'), ' ').toLowerCase();

    if (cleanedQuery.isEmpty) {
      setState(() {
        filteredKegiatanList = kegiatanList;
        isSearching = false;
      });
      return;
    }

    final suggestions = kegiatanList.where((kegiatan) {
      final kegiatanName = kegiatan['nama_kegiatan'].toLowerCase();
      return kegiatanName.contains(cleanedQuery);
    }).toList();

    setState(() {
      isSearching = true;
      filteredKegiatanList = suggestions;
      filteredKegiatanList.sort((a, b) {
        if (a['nama_kegiatan'].toLowerCase() == cleanedQuery) return -1;
        if (b['nama_kegiatan'].toLowerCase() == cleanedQuery) return 1;
        return a['nama_kegiatan'].compareTo(b['nama_kegiatan']);
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
          'Kegiatan',
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
            : LayoutBuilder(
                builder: (context, constraints) {
                  if (constraints.maxWidth > 600) {
                    return Column();
                  } else {
                    return Column(
                      children: [
                        SizedBox(height: 10),
                        Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 20, vertical: 20),
                          child: TextField(
                            controller: searchController,
                            cursorColor: Color(0xff30C083),
                            decoration: InputDecoration(
                              hintText: 'Cari Kegiatan...',
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
                                  searchKegiatan(searchController.text);
                                },
                                child: Icon(Icons.search),
                              ),
                              suffixIcon: isSearching
                                  ? IconButton(
                                      icon: Icon(Icons.clear),
                                      onPressed: () {
                                        searchController.clear();
                                        searchKegiatan('');
                                      },
                                    )
                                  : null,
                            ),
                            onChanged: searchKegiatan,
                          ),
                        ),
                        Expanded(
                          child: filteredKegiatanList.isEmpty
                              ? Center(
                                  child: Text(
                                    'Data tidak ditemukan.',
                                  ),
                                )
                              : ListView.builder(
                                  itemCount: filteredKegiatanList.length,
                                  itemBuilder: (context, index) {
                                    final kegiatan =
                                        filteredKegiatanList[index];
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 20),
                                      child: Column(
                                        children: [
                                          Container(
                                            margin: EdgeInsets.only(bottom: 20),
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
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 20,
                                                      vertical: 20),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    kegiatan['nama_kegiatan'],
                                                    style: TextStyle(
                                                      fontSize: 20,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                  SizedBox(height: 10),
                                                  Row(
                                                    children: [
                                                      GestureDetector(
                                                        onTap: () {
                                                          showDialog(
                                                            context: context,
                                                            builder:
                                                                (BuildContext
                                                                    context) {
                                                              return Dialog(
                                                                shape:
                                                                    RoundedRectangleBorder(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              20),
                                                                ),
                                                                child:
                                                                    ClipRRect(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              20),
                                                                  child: Image
                                                                      .network(
                                                                    kegiatan[
                                                                        'foto_ketua_pelaksana'],
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
                                                            kegiatan[
                                                                'foto_ketua_pelaksana'],
                                                          ),
                                                        ),
                                                      ),
                                                      SizedBox(width: 10),
                                                      Text(
                                                        "${kegiatan['ketua_pelaksana']} (Ketua Pelaksana)",
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
                                                        '${formatDate(kegiatan['tgl'])}',
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
                                                              20.0),
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text(
                                                            kegiatan[
                                                                    'isExpanded']
                                                                ? kegiatan[
                                                                    'keterangan']
                                                                : (kegiatan['keterangan']
                                                                            .length >
                                                                        100
                                                                    ? kegiatan['keterangan'].substring(
                                                                            0,
                                                                            100) +
                                                                        '...'
                                                                    : kegiatan[
                                                                        'keterangan']),
                                                            textAlign: TextAlign
                                                                .justify,
                                                          ),
                                                          SizedBox(height: 10),
                                                          if (kegiatan[
                                                                      'keterangan']
                                                                  .length >
                                                              100) ...[
                                                            GestureDetector(
                                                              onTap: () {
                                                                setState(() {
                                                                  kegiatan[
                                                                          'isExpanded'] =
                                                                      !kegiatan[
                                                                          'isExpanded'];
                                                                });
                                                              },
                                                              child: Align(
                                                                alignment: Alignment
                                                                    .bottomRight,
                                                                child: Text(
                                                                  kegiatan[
                                                                          'isExpanded']
                                                                      ? 'Klik lagi untuk sembunyikan'
                                                                      : 'Lihat selengkapnya',
                                                                  style:
                                                                      TextStyle(
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
                                                          ]
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(height: 30),
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceAround,
                                                    children: [
                                                      Column(
                                                        children: [
                                                          Container(
                                                            width: 100,
                                                            height: 100,
                                                            decoration:
                                                                BoxDecoration(
                                                              border: Border.all(
                                                                  width: 1,
                                                                  color: Colors
                                                                      .grey),
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          10),
                                                            ),
                                                            child: Column(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .center,
                                                              children: [
                                                                Icon(
                                                                    Icons
                                                                        .picture_as_pdf,
                                                                    color: Colors
                                                                        .red),
                                                                SizedBox(
                                                                    height: 5),
                                                                Text('Proposal',
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            12)),
                                                              ],
                                                            ),
                                                          ),
                                                          SizedBox(
                                                            height: 15,
                                                          ),
                                                          GestureDetector(
                                                            onTap: () async {
                                                              final fileUrl =
                                                                  "https://pexadont.agsa.site/uploads/kegiatan/proposal/" +
                                                                      kegiatan[
                                                                          'proposal'];
                                                              await downloadFile(
                                                                  fileUrl);
                                                            },
                                                            child: Container(
                                                              alignment:
                                                                  Alignment
                                                                      .center,
                                                              decoration:
                                                                  BoxDecoration(
                                                                color: const Color(
                                                                    0xff30C083),
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            10),
                                                                boxShadow: [
                                                                  BoxShadow(
                                                                    color: Colors
                                                                        .black
                                                                        .withOpacity(
                                                                            0.2),
                                                                    spreadRadius:
                                                                        1,
                                                                    blurRadius:
                                                                        5,
                                                                    offset:
                                                                        Offset(
                                                                            0,
                                                                            3),
                                                                  ),
                                                                ],
                                                              ),
                                                              child: Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .all(
                                                                        10),
                                                                child: Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .center,
                                                                  children: [
                                                                    Icon(
                                                                        Icons
                                                                            .download,
                                                                        size:
                                                                            14,
                                                                        color: Colors
                                                                            .white),
                                                                    SizedBox(
                                                                        width:
                                                                            5),
                                                                    Text(
                                                                      'Download',
                                                                      style:
                                                                          TextStyle(
                                                                        color: Colors
                                                                            .white,
                                                                        fontWeight:
                                                                            FontWeight.bold,
                                                                        fontSize:
                                                                            12,
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      Column(
                                                        children: [
                                                          Container(
                                                            width: 100,
                                                            height: 100,
                                                            decoration:
                                                                BoxDecoration(
                                                              border: Border.all(
                                                                  width: 1,
                                                                  color: Colors
                                                                      .grey),
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          10),
                                                            ),
                                                            child: Column(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .center,
                                                              children: [
                                                                Icon(
                                                                    Icons
                                                                        .picture_as_pdf,
                                                                    color: Colors
                                                                        .red),
                                                                SizedBox(
                                                                    height: 5),
                                                                Text('LPJ',
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            12)),
                                                              ],
                                                            ),
                                                          ),
                                                          SizedBox(
                                                            height: 15,
                                                          ),
                                                          GestureDetector(
                                                            onTap: () async {
                                                              final fileUrl =
                                                                  kegiatan[
                                                                      'lpj'];
                                                              if (fileUrl !=
                                                                  null) {
                                                                await downloadFile(
                                                                    "https://pexadont.agsa.site/uploads/kegiatan/lpj/${fileUrl}");
                                                              } else {
                                                                ScaffoldMessenger.of(
                                                                        context)
                                                                    .showSnackBar(
                                                                        SnackBar(
                                                                  content: Text(
                                                                      'LPJ belum tersedia'),
                                                                  backgroundColor:
                                                                      Colors
                                                                          .red,
                                                                ));
                                                              }
                                                            },
                                                            child: Container(
                                                              alignment:
                                                                  Alignment
                                                                      .center,
                                                              decoration:
                                                                  BoxDecoration(
                                                                color: kegiatan[
                                                                            'lpj'] ==
                                                                        null
                                                                    ? Colors.red
                                                                    : const Color(
                                                                        0xff30C083),
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            10),
                                                                boxShadow: [
                                                                  BoxShadow(
                                                                    color: Colors
                                                                        .black
                                                                        .withOpacity(
                                                                            0.2),
                                                                    spreadRadius:
                                                                        1,
                                                                    blurRadius:
                                                                        5,
                                                                    offset:
                                                                        Offset(
                                                                            0,
                                                                            3),
                                                                  ),
                                                                ],
                                                              ),
                                                              child: Padding(
                                                                padding:
                                                                    EdgeInsets
                                                                        .all(
                                                                            10),
                                                                child: Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .center,
                                                                  children: [
                                                                    kegiatan['lpj'] ==
                                                                            null
                                                                        ? const Icon(
                                                                            Icons
                                                                                .download,
                                                                            size:
                                                                                14,
                                                                            color: Colors
                                                                                .white)
                                                                        : const Icon(
                                                                            Icons
                                                                                .download,
                                                                            size:
                                                                                14,
                                                                            color:
                                                                                Colors.white),
                                                                    const SizedBox(
                                                                        width:
                                                                            5),
                                                                    Text(
                                                                      kegiatan['lpj'] ==
                                                                              null
                                                                          ? 'Download'
                                                                          : "Download",
                                                                      style:
                                                                          const TextStyle(
                                                                        color: Colors
                                                                            .white,
                                                                        fontWeight:
                                                                            FontWeight.bold,
                                                                        fontSize:
                                                                            12,
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                  SizedBox(height: 10),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                        )
                      ],
                    );
                  }
                },
              ),
      ),
    );
  }
}
