import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pexadont/pages/tampilan_awal/layout.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

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
      filteredPesanList = data;
      isLoading = false;
    });
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
                              borderSide: BorderSide(color: Colors.black),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: Color(0xff30C083)),
                            ),
                            prefixIcon: GestureDetector(
                              onTap: () {
                                searchPesan(searchController.text);
                              },
                              child: Icon(Icons.search, color: Colors.black),
                            ),
                            suffixIcon: isSearching
                                ? IconButton(
                                    icon:
                                        Icon(Icons.clear, color: Colors.black),
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
                      Text(
                          'Total Pesan : ${pengaduanData.length} Pesan Pengaduan'),
                      SizedBox(
                        height: 20,
                      ),
                      filteredPesanList.isEmpty
                          ? Padding(
                              padding: const EdgeInsets.only(top: 150),
                              child: Text(
                                'Data tidak ditemukan.',
                              ),
                            )
                          : ListView.builder(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: filteredPesanList.length,
                              itemBuilder: (context, index) {
                                final pengaduan = filteredPesanList[index];
                                return Container(
                                  margin: EdgeInsets.only(bottom: 20),
                                  padding: EdgeInsets.symmetric(horizontal: 20),
                                  child: Container(
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
                                                    height: 6,
                                                  ),
                                                  Row(
                                                    children: [
                                                      Icon(Icons.calendar_month,
                                                          size: 20,
                                                          color: Colors.black),
                                                      SizedBox(width: 5),
                                                      Text(
                                                        '${formatDate(pengaduan['tgl'])}',
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
                                                  padding:
                                                      const EdgeInsets.all(20),
                                                  child: Column(
                                                    children: [
                                                      const Text(
                                                          "Anda Mengadukan :",
                                                          style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold)),
                                                      SizedBox(height: 10),
                                                      pengaduan['foto'] == null
                                                          ? SizedBox()
                                                          : Container(
                                                              margin:
                                                                  const EdgeInsets
                                                                      .only(
                                                                      bottom:
                                                                          20),
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
                                                                child: Image
                                                                    .network(
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
                                                margin: const EdgeInsets.only(
                                                    top: 10),
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
                                                  padding:
                                                      const EdgeInsets.all(20),
                                                  child: Column(
                                                    children: [
                                                      Text(
                                                        "Balasan dari\n${pengaduan['aksiBy']} :",
                                                        style: const TextStyle(
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                        textAlign:
                                                            TextAlign.center,
                                                      ),
                                                      const SizedBox(
                                                          height: 10),
                                                      Text(
                                                        pengaduan['balasan'] !=
                                                                ""
                                                            ? pengaduan[
                                                                'balasan']
                                                            : "-",
                                                        style: const TextStyle(
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
                    ],
                  );
                }
              }),
            ),
    );
  }
}
