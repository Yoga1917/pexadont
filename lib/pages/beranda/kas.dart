import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:indonesia/indonesia.dart';
import 'package:pexadont/pages/kas_rt/detail_kas.dart';
import 'package:pexadont/pages/tampilan_awal/beranda.dart';
import 'package:pexadont/pages/tampilan_awal/layout.dart';
import 'package:pexadont/widget/kartu_laporan.dart';
import 'package:pexadont/widget/kartu_total_laporan.dart';
import 'package:http/http.dart' as http;

class KasPage extends StatefulWidget {
  @override
  State<KasPage> createState() => _KasPageState();
}

class _KasPageState extends State<KasPage> {
  String? selectedYear;
  List<dynamic> kasData = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _getKasTerakhir();
  }

  void _getKasTerakhir() async {
    try {
      final response = await http.get(
        Uri.parse('https://pexadont.agsa.site/api/kas'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        setState(() {
          kasData = responseData['data'];
          isLoading = false;
        });
      } else {
        showSnackbar('Gagal memuat data kas');
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
          'Uang KAS RT',
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
                      SizedBox(
                        height: 30,
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: Color(0xff30C083),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: DropdownButton<String>(
                          dropdownColor: Color(0xff30C083),
                          iconEnabledColor: Colors.white,
                          hint: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Text(
                              'Pilih Tahun',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                          value: selectedYear,
                          items: generateYearList()
                              .map<DropdownMenuItem<String>>((String year) {
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
                      SizedBox(
                        height: 18,
                      ),
                      Text('Saldo Kas : Rp. 100.000.000,-'),
                      SizedBox(
                        height: 12,
                      ),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: kasData.length,
                        itemBuilder: (context, index) {
                          final kas = kasData[index];
                          return Column(
                            children: [
                              KartuLaporan(
                                month: kas['bulan'] + " " + kas['tahun'],
                                income: rupiah(kas['pemasukan']),
                                expense: rupiah(kas['pengeluaran']),
                                publish: kas['publish'],
                                onDetail: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            DetailKASPage(kas['id_kas'])),
                                  );
                                },
                                onPublish: () {},
                              ),
                              TotalCard(
                                totalIncome: rupiah(kas['pemasukan']),
                                totalExpense: rupiah(kas['pengeluaran']),
                                remainingFunds: rupiah(
                                  (int.parse(kas['pemasukan']) -
                                          int.parse(kas['pengeluaran']))
                                      .toString(),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                      SizedBox(
                        height: 30,
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
