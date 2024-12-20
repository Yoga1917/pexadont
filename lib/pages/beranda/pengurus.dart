import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pexadont/pages/tampilan_awal/beranda.dart';
import 'package:pexadont/pages/tampilan_awal/layout.dart';

class PengurusPage extends StatefulWidget {
  @override
  _PengurusPageState createState() => _PengurusPageState();
}

class _PengurusPageState extends State<PengurusPage> {
  String? selectedYear;
  List<dynamic> pengurusData = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchPengurusData();
  }

  Future<void> fetchPengurusData() async {
    try {
      final response = await http.get(
        Uri.parse('https://pexadont.agsa.site/api/pengurus'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        if (!responseData['error']) {
          setState(() {
            pengurusData = responseData['data'];
            isLoading = false;
          });
        } else {
          showSnackbar(responseData['message']);
        }
      } else {
        showSnackbar('Gagal memuat data pengurus');
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xff30C083),
        title: Text(
          'Pengurus RT',
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
              MaterialPageRoute(builder: (context) => LayoutPage(goToHome: true)),
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
                      SizedBox(height: 30),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: Color(0xff30C083),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: DropdownButton<String>(
                                dropdownColor: Color(0xff30C083),
                                iconEnabledColor: Colors.white,
                                hint: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8.0),
                                  child: Text(
                                    'Pilih Tahun',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                                value: selectedYear,
                                items: generateYearList()
                                    .map<DropdownMenuItem<String>>(
                                        (String year) {
                                  return DropdownMenuItem<String>(
                                    value: year,
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        year,
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                  );
                                }).toList(),
                                onChanged: (String? newValue) {
                                  setState(() {
                                    selectedYear = newValue;
                                  });
                                },
                              ),
                            ),
                            SizedBox(height: 30),
                            ListView.builder(
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                itemCount: pengurusData.length,
                                itemBuilder: (context, index) {
                                  final pengurus = pengurusData[index];
                                  return Container(
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
                                        SizedBox(
                                          height: 20,
                                        ),
                                        Text(
                                          pengurus['jabatan'],
                                          style: TextStyle(
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(20),
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(20),
                                            child: Image.network(
                                              'https://pexadont.agsa.site/uploads/warga/${pengurus['foto']}',
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
                                              SizedBox(height: 10),
                                              Text(
                                                pengurus['nama'],
                                                style: TextStyle(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              SizedBox(height: 10),
                                              Text(
                                                'Nik : ${pengurus['nik']}',
                                                style: TextStyle(
                                                  fontSize: 14,
                                                ),
                                              ),
                                              Text(
                                                'Tanggal Lahir : ${pengurus['tgl_lahir']}',
                                                style: TextStyle(
                                                  fontSize: 14,
                                                ),
                                              ),
                                              Text(
                                                'Jenis Kelamin : ${pengurus['jenis_kelamin']}',
                                                style: TextStyle(
                                                  fontSize: 14,
                                                ),
                                              ),
                                              Text(
                                                'No. Rumah : ${pengurus['no_rumah']}',
                                                style: TextStyle(
                                                  fontSize: 14,
                                                ),
                                              ),
                                              SizedBox(height: 20),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }),
                          ],
                        ),
                      ),
                    ],
                  );
                }
              }),
            ),
    );
  }

  List<String> generateYearList() {
    int currentYear = DateTime.now().year;
    List<String> years = [];

    for (int i = currentYear - 10; i <= 2070; i++) {
      years.add(i.toString());
    }
    return years;
  }
}
