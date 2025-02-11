import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:indonesia/indonesia.dart';
import 'package:pexadont/pages/kas_rt/detail_kas.dart';
import 'package:pexadont/pages/tampilan_awal/layout.dart';
import 'package:pexadont/widget/kartu_laporan.dart';
import 'package:pexadont/widget/kartu_total_laporan.dart';

class KasPage extends StatefulWidget {
  @override
  State<KasPage> createState() => _KasPageState();
}

class _KasPageState extends State<KasPage> {
  String? selectedYear;
  List<dynamic> kasData = [];
  List<dynamic> kasSaldo = [];
  bool isLoading = true;
  int saldoKas = 0;
  int sisaDana = 0;
  int totalIncome = 0;
  int totalExpense = 0;

  @override
  void initState() {
    super.initState();
    selectedYear = DateTime.now().year.toString();
    _fetchKas();
    _fetchAllKas();
  }

  void _fetchKas() async {
    try {
      String url = selectedYear == null
          ? 'https://pexadont.agsa.site/api/kas'
          : 'https://pexadont.agsa.site/api/kas?tahun=${selectedYear}';

      final response = await http.get(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);

        setState(() {
          kasData = responseData['data']
              .where((item) => item['publish'] == '1')
              .toList();

          kasData.sort((a, b) =>
              int.parse(b['id_kas']).compareTo(int.parse(a['id_kas'])));

          perhitunganTotal();
          isLoading = false;
        });
      } else {
        showSnackbar('Gagal memuat data kas');
      }
    } catch (e) {
      showSnackbar('Terjadi kesalahan: $e');
    }
  }

  void _fetchAllKas() async {
    try {
      String url = 'https://pexadont.agsa.site/api/kas';
      final response = await http.get(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        setState(() {
          kasSaldo = responseData['data']
              .where((kas) => kas['publish'] == '1')
              .toList();
          kasSaldo.sort((a, b) =>
              int.parse(b['id_kas']).compareTo(int.parse(a['id_kas'])));

          _saldoKas();
        });
      } else {
        showSnackbar('Gagal memuat data kas');
      }
    } catch (e) {
      showSnackbar('Terjadi kesalahan: $e');
    }
  }

  void _saldoKas() {
    for (var kas in kasSaldo) {
      int pemasukan =
          kas['pemasukan'] != null ? int.parse(kas['pemasukan']) : 0;
      int pengeluaran =
          kas['pengeluaran'] != null ? int.parse(kas['pengeluaran']) : 0;

      saldoKas += (pemasukan - pengeluaran);
    }
  }

  void perhitunganTotal() {
    totalIncome = 0;
    totalExpense = 0;
    sisaDana = 0;

    for (var kas in kasData) {
      if (kas['tahun'] == selectedYear) {
        int pemasukan =
            kas['pemasukan'] != null ? int.parse(kas['pemasukan']) : 0;
        int pengeluaran =
            kas['pengeluaran'] != null ? int.parse(kas['pengeluaran']) : 0;

        totalIncome += pemasukan;
        totalExpense += pengeluaran;
        sisaDana += (pemasukan - pengeluaran);
      }
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
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
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
          : LayoutBuilder(builder: (context, constraints) {
              if (constraints.maxWidth > 600) {
                return Column();
              } else {
                return Column(
                  children: [
                    SizedBox(
                      height: 30,
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Color(0xff30C083),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: DropdownButton<String>(
                          dropdownColor: Color(0xff30C083),
                          iconEnabledColor: Colors.white,
                          hint: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            child: Text(
                              '',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 18),
                            ),
                          ),
                          value: selectedYear,
                          items: generateYearList()
                              .map<DropdownMenuItem<String>>((String year) {
                            return DropdownMenuItem<String>(
                              value: year,
                              child: Padding(
                                padding:
                                    const EdgeInsets.only(left: 20, right: 5),
                                child: Text(
                                  year,
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 18),
                                ),
                              ),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              selectedYear = newValue;
                            });
                            _fetchKas();
                          },
                          itemHeight: null,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 30,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Saldo Kas : ',
                        ),
                        Text(
                          '${rupiah(saldoKas)},-',
                          style: TextStyle(
                              color: Colors.black, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    Expanded(
                      child: kasData.length > 0
                          ? SingleChildScrollView(
                              child: Column(
                                children: [
                                  ListView.builder(
                                    padding: EdgeInsets.zero,
                                    shrinkWrap: true,
                                    physics: NeverScrollableScrollPhysics(),
                                    itemCount: kasData.length,
                                    itemBuilder: (context, index) {
                                      final kas =
                                          kasData.reversed.toList()[index];
                                      return KartuLaporan(
                                        month:
                                            kas['bulan'] + " " + kas['tahun'],
                                        aksiBy: '${kas['aksiBy']}',
                                        fotoAksiBy: '${kas['fotoAksiBy']}',
                                        income: rupiah(kas['pemasukan'] ?? 0),
                                        expense:
                                            rupiah(kas['pengeluaran'] ?? 0),
                                        onDetail: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    DetailKASPage(
                                                        kas['id_kas'])),
                                          );
                                        },
                                      );
                                    },
                                  ),
                                  if (kasData.isNotEmpty)
                                    TotalCard(
                                      totalIncome:
                                          rupiah(totalIncome.toString()),
                                      totalExpense:
                                          rupiah(totalExpense.toString()),
                                      remainingFunds:
                                          rupiah(sisaDana.toString()),
                                    ),
                                  SizedBox(height: 30)
                                ],
                              ),
                            )
                          : Center(
                              child: Text(
                                  "Tidak ada data KAS di tahun yang dipilih."),
                            ),
                    ),
                  ],
                );
              }
            }),
    );
  }

  List<String> generateYearList() {
    int currentYear = DateTime.now().year;
    List<String> years = [];

    for (int i = 2014; i <= currentYear; i++) {
      years.add(i.toString());
    }
    return years;
  }
}
