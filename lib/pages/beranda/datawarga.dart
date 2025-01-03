import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
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
        filteredWargaList = wargaList; // Initialize with full list
        isLoading = false;
        totalWarga = wargaList.length;
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
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: Color(0xff30C083),
              ),
            )
          : SingleChildScrollView(
              child: Column(
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
                          borderSide: BorderSide(color: Colors.black),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Color(0xff30C083)),
                        ),
                        prefixIcon: GestureDetector(
                          onTap: () {
                            searchWarga(searchController.text);
                          },
                          child: Icon(Icons.search, color: Colors.black),
                        ),
                        suffixIcon: isSearching
                            ? IconButton(
                                icon: Icon(Icons.clear, color: Colors.black),
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
                  Text('Total Warga : $totalWarga Warga'),
                  SizedBox(height: 20),
                  if (filteredWargaList.isEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 150),
                      child: Text(
                        'Data tidak ditemukan.',
                      ),
                    ),
                  if (filteredWargaList.isNotEmpty)
                    for (var warga in filteredWargaList)
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: Container(
                          margin: EdgeInsets.only(bottom: 20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(width: 1, color: Colors.grey),
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
                                  borderRadius: BorderRadius.circular(20),
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
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 20),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: <Widget>[
                                    SizedBox(height: 10),
                                    Text(
                                      warga['nama'] ?? 'Unknown Name',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: 10),
                                    Text(
                                      'Nik : ${warga['nik']}',
                                      style: TextStyle(
                                        fontSize: 14,
                                      ),
                                    ),
                                    SizedBox(height: 2),
                                    Text(
                                      'Tanggal Lahir : ${warga['tgl_lahir']}',
                                      style: TextStyle(
                                        fontSize: 14,
                                      ),
                                    ),
                                    SizedBox(height: 2),
                                    Text(
                                      'Jenis Kelamin : ${warga['jenis_kelamin']}',
                                      style: TextStyle(
                                        fontSize: 14,
                                      ),
                                    ),
                                    SizedBox(height: 2),
                                    Text(
                                      'No. Rumah : ${warga['no_rumah']}',
                                      style: TextStyle(
                                        fontSize: 14,
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
                      ),
                  SizedBox(
                    height: 30,
                  ),
                ],
              ),
            ),
    );
  }
}
