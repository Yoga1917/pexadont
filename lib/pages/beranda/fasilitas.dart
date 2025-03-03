import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:pexadont/pages/tampilan_awal/layout.dart';

class FasilitasPage extends StatefulWidget {
  @override
  State<FasilitasPage> createState() => _FasilitasPageState();
}

class _FasilitasPageState extends State<FasilitasPage> {
  List<dynamic> fasilitasList = [];
  List<dynamic> filteredFasilitasList = [];
  int totalFasilitas = 0;
  TextEditingController searchController = TextEditingController();
  bool isSearching = false;
  bool isLoading = true;
  String formattedTotalFasilitas = '';

  @override
  void initState() {
    super.initState();
    fetchFasilitasData();
  }

  Future<void> fetchFasilitasData() async {
    final response =
        await http.get(Uri.parse('https://pexadont.agsa.site/api/fasilitas'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        fasilitasList = (data['data'] as List)
            .map((item) => {
                  'nama': item['nama'],
                  'jml': item['jml'],
                  'status': item['status'],
                  'foto': item['foto']
                })
            .toList();
        filteredFasilitasList = fasilitasList;
        isLoading = false;
        totalFasilitas = fasilitasList.length;

        formattedTotalFasilitas =
            NumberFormat.decimalPattern('id').format(totalFasilitas);
      });
    } else {
      throw Exception('Failed to load data: ${response.statusCode}');
    }
  }

  void searchFasilitas(String query) {
    final cleanedQuery =
        query.trim().replaceAll(RegExp(r'\s+'), ' ').toLowerCase();

    if (cleanedQuery.isEmpty) {
      setState(() {
        filteredFasilitasList = fasilitasList;
        isSearching = false;
      });
      return;
    }

    final suggestions = fasilitasList.where((fasilitas) {
      final fasilitasName = fasilitas['nama'].toLowerCase();
      return fasilitasName.contains(cleanedQuery);
    }).toList();

    setState(() {
      isSearching = true;
      filteredFasilitasList = suggestions;
      filteredFasilitasList.sort((a, b) {
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
          'Fasilitas',
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
                  valueColor: AlwaysStoppedAnimation(Color(0xff30C083)),
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
                        hintText: 'Cari Fasilitas...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Color(0xff30C083)),
                        ),
                        prefixIcon: GestureDetector(
                          onTap: () {
                            searchFasilitas(searchController.text);
                          },
                          child: Icon(Icons.search),
                        ),
                        suffixIcon: isSearching
                            ? IconButton(
                                icon: Icon(Icons.clear),
                                onPressed: () {
                                  searchController.clear();
                                  searchFasilitas('');
                                },
                              )
                            : null,
                      ),
                      onChanged: searchFasilitas,
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Total Fasilitas : '),
                      Text(
                        NumberFormat.decimalPattern('id')
                            .format(totalFasilitas),
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(' Fasilitas'),
                    ],
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Expanded(
                    child: filteredFasilitasList.isEmpty
                        ? Center(
                            child: Text(
                              'Data tidak ditemukan.',
                            ),
                          )
                        : ListView.builder(
                            itemCount: filteredFasilitasList.length,
                            itemBuilder: (context, index) {
                              final fasilitas = filteredFasilitasList[index];
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
                                        padding: const EdgeInsets.all(20),
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          child: Image.network(
                                            (fasilitas['foto'] != null)
                                                ? 'https://pexadont.agsa.site/uploads/fasilitas/${fasilitas['foto']}'
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
                                              fasilitas['nama'],
                                              style: TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            SizedBox(height: 5),
                                            Text(
                                              'Jumlah : ${fasilitas['jml']}',
                                            ),
                                            SizedBox(height: 2),
                                            Text(
                                              ' Kondisi : ${fasilitas['status']}',
                                            ),
                                            SizedBox(height: 20),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  )
                ],
              ),
      ),
    );
  }
}
