import 'package:flutter/material.dart';
import 'package:pexadont/widget/kartu_laporan.dart';
import 'package:pexadont/widget/kartu_total_laporan.dart';

class KasPage extends StatefulWidget {
  @override
  State<KasPage> createState() => _KasPageState();
}

class _KasPageState extends State<KasPage> {
  String? selectedYear;

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
      ),
      body: SingleChildScrollView(
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
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
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
                  height: 30,
                ),
                Text('Sisa Dana Kas : Rp. 100.000.000'),
                SizedBox(
                  height: 30,
                ),
                ListView(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  children: [
                    KartuLaporan(
                        month: 'Januari',
                        date: '01-01-2023',
                        income: 'Rp 1,000,000',
                        expense: 'Rp 500,000',
                        description:
                            'Pengeluaran digunakan untuk membeli peralatan kebersihan'),
                    KartuLaporan(
                        month: 'Februari',
                        date: '01-02-2023',
                        income: 'Rp 1,200,000',
                        expense: 'Rp 600,000',
                        description:
                            'Pengeluaran digunakan untuk membeli bahan bakar genset'),
                    KartuLaporan(
                        month: 'Maret',
                        date: '01-03-2023',
                        income: 'Rp 1,100,000',
                        expense: 'Rp 700,000',
                        description:
                            'Pengeluaran digunakan untuk perbaikan jalan'),
                    KartuLaporan(
                        month: 'April',
                        date: '01-04-2023',
                        income: 'Rp 1,300,000',
                        expense: 'Rp 800,000',
                        description:
                            'Pengeluaran digunakan untuk acara 17 Agustus'),
                    KartuLaporan(
                        month: 'Mei',
                        date: '01-05-2023',
                        income: 'Rp 1,400,000',
                        expense: 'Rp 900,000',
                        description:
                            'Pengeluaran digunakan untuk membeli alat olahraga'),
                    KartuLaporan(
                        month: 'Juni',
                        date: '01-06-2023',
                        income: 'Rp 1,500,000',
                        expense: 'Rp 1,000,000',
                        description:
                            'Pengeluaran digunakan untuk perbaikan saluran air'),
                    KartuLaporan(
                        month: 'Juli',
                        date: '01-07-2023',
                        income: 'Rp 1,600,000',
                        expense: 'Rp 1,100,000',
                        description:
                            'Pengeluaran digunakan untuk membeli alat kebersihan'),
                    KartuLaporan(
                        month: 'Agustus',
                        date: '01-08-2023',
                        income: 'Rp 1,700,000',
                        expense: 'Rp 1,200,000',
                        description:
                            'Pengeluaran digunakan untuk membeli bahan bakar genset'),
                    KartuLaporan(
                        month: 'September',
                        date: '01-09-2023',
                        income: 'Rp 1,800,000',
                        expense: 'Rp 1,300,000',
                        description:
                            'Pengeluaran digunakan untuk perbaikan jalan'),
                    KartuLaporan(
                        month: 'Oktober',
                        date: '01-10-2023',
                        income: 'Rp 1,900,000',
                        expense: 'Rp 1,400,000',
                        description:
                            'Pengeluaran digunakan untuk acara 17 Agustus'),
                    KartuLaporan(
                        month: 'November',
                        date: '01-11-2023',
                        income: 'Rp 2,000,000',
                        expense: 'Rp 1,500,000',
                        description:
                            'Pengeluaran digunakan untuk membeli alat olahraga'),
                    KartuLaporan(
                        month: 'Desember',
                        date: '01-12-2023',
                        income: 'Rp 2,100,000',
                        expense: 'Rp 1,600,000',
                        description:
                            'Pengeluaran digunakan untuk perbaikan saluran air'),
                    TotalCard(
                        totalIncome: 'Rp 18,800,000',
                        totalExpense: 'Rp 12,000,000',
                        remainingFunds: 'Rp 6,800,000'),
                  ],
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
