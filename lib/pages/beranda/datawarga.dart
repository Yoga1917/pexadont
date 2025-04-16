import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:pexadont/pages/tampilan_awal/layout.dart';

class DataWargaPage extends StatefulWidget {
  @override
  State<DataWargaPage> createState() => _DataWargaPageState();
}

class _DataWargaPageState extends State<DataWargaPage> {
  List<dynamic> wargaList = [];
  List<dynamic> filteredWargaList = [];
  int totalWarga = 0;
  TextEditingController searchController = TextEditingController();
  bool isLoading = true;
  bool isSearching = false;
  String formattedTotalWarga = '';

  @override
  void initState() {
    super.initState();
    fetchWargaData();
  }

  Future<void> fetchWargaData() async {
    final response =
        await http.get(Uri.parse('https://pexadont.agsa.site/api/warga'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        wargaList =
            data['data'].where((item) => item['status'] == "1").toList();
        filteredWargaList = wargaList;
        isLoading = false;
        totalWarga = wargaList.length;
        formattedTotalWarga =
            NumberFormat.decimalPattern('id').format(totalWarga);
      });
    } else {
      throw Exception('Failed to load data');
    }
  }

  void searchWarga(String query) {
    final cleanedQuery =
        query.trim().replaceAll(RegExp(r'\s+'), ' ').toLowerCase();

    if (cleanedQuery.isEmpty) {
      setState(() {
        filteredWargaList = wargaList;
        isSearching = false;
      });
      return;
    }

    final suggestions = wargaList.where((warga) {
      final wargaName = warga['nama'].toLowerCase();
      return wargaName.contains(cleanedQuery);
    }).toList();

    setState(() {
      isSearching = true;
      filteredWargaList = suggestions;
      filteredWargaList.sort((a, b) {
        if (a['nama'].toLowerCase() == cleanedQuery) return -1;
        if (b['nama'].toLowerCase() == cleanedQuery) return 1;
        return a['nama'].compareTo(b['nama']);
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
          'Data Warga',
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
            : Column(
                children: [
                  SizedBox(height: 10),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                    child: TextField(
                      controller: searchController,
                      cursorColor: Color(0xff30C083),
                      decoration: InputDecoration(
                        hintText: 'Cari data warga...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Color(0xff30C083)),
                        ),
                        prefixIcon: GestureDetector(
                          onTap: () {
                            searchWarga(searchController.text);
                          },
                          child: Icon(Icons.search),
                        ),
                        suffixIcon: isSearching
                            ? IconButton(
                                icon: Icon(Icons.clear),
                                onPressed: () {
                                  searchController.clear();
                                  searchWarga('');
                                },
                              )
                            : null,
                      ),
                      onChanged: searchWarga,
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Total Warga : '),
                      Text(
                        NumberFormat.decimalPattern('id').format(totalWarga),
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(' Warga')
                    ],
                  ),
                  SizedBox(height: 20),
                  Expanded(
                    child: filteredWargaList.isEmpty
                        ? Center(child: Text('Data tidak ditemukan.'))
                        : ListView.builder(
                            itemCount: filteredWargaList.length,
                            itemBuilder: (context, index) {
                              final warga = filteredWargaList[index];
                              return Padding(
                                padding: EdgeInsets.symmetric(horizontal: 20),
                                child: Container(
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
                                      Padding(
                                        padding: const EdgeInsets.all(20),
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          child: Image.network(
                                            (warga['foto'] != null)
                                                ? 'https://pexadont.agsa.site/uploads/warga/${warga['foto']}'
                                                : 'https://placehold.co/300x300.png',
                                            fit: BoxFit.cover,
                                            width: double.infinity,
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
                                              'Tanggal Lahir : ${formatDate(warga['tgl_lahir'])}',
                                            ),
                                            SizedBox(height: 2),
                                            Text(
                                              'Jenis Kelamin : ${warga['jenis_kelamin']}',
                                            ),
                                            SizedBox(height: 2),
                                            Text(
                                              'No. Rumah : ${warga['no_rumah']}',
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
              ),
      ),
    );
  }
}
