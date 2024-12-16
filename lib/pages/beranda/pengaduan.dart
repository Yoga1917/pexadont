import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:pexadont/pages/Pengaduan/tambah_aduan.dart';

class PengaduanPage extends StatefulWidget {
  @override
  State<PengaduanPage> createState() => _PengaduanPageState();
}

class _PengaduanPageState extends State<PengaduanPage> {
  List pengaduanData = [];

  @override
  void initState() {
    super.initState();
    _fetchPengaduan();
  }
  
  Future<void> _fetchPengaduan() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final nik = prefs.getString('nik');

    final request = await http.get(Uri.parse("https://pexadont.agsa.site/api/pengaduan/warga/${nik}"));
    final data = json.decode(request.body)['data'];
    
    data.sort((a, b) {
      final tglA = DateTime.parse(a['tgl']);
      final tglB = DateTime.parse(b['tgl']);
      return tglB.compareTo(tglA); // Mengurutkan dari terbaru ke terlama
    });

    setState(() {
      pengaduanData = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xff30C083),
        title: Text(
          'Pengaduan',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: LayoutBuilder(builder: (context, constraints) {
        if (constraints.maxWidth > 600) {
          return Column();
        } else {
          return Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => TambahAduanPage()),
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xff30C083),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(15),
                          child: Row(
                            children: [
                              Icon(Icons.add, color: Colors.white),
                              SizedBox(width: 5),
                              Text(
                                'Aduan',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 18,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 30,
                    ),
                    Expanded(
                      child: TextField(
                        cursorColor: Color(0xff30C083),
                        decoration: InputDecoration(
                          hintText: 'Cari Pengaduan...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: Colors.black),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: Color(0xff30C083)),
                          ),
                          prefixIcon: Icon(Icons.search, color: Colors.black),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Text('Total Pengaduan : ${pengaduanData.length} Pengaduan'),
              SizedBox(
                height: 30,
              ),
              pengaduanData.isEmpty
              ? Center(child: Text("Belum ada data pengaduan"))
              : Expanded(
                child: ListView.builder(
                    itemCount: pengaduanData.length,
                    itemBuilder: (context, index) {
                      final pengaduan = pengaduanData[index];
                      return Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: Container(
                          margin: EdgeInsets.only(bottom: 30),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(width: 1, color: Colors.grey),
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
                              ClipRRect(
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(20),
                                  topRight: Radius.circular(20),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 20),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(height: 20),
                                    Text(
                                      'Pengaduan ${pengaduan['jenis']}',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: 10),
                                    Row(
                                      children: [
                                        Icon(Icons.calendar_month,
                                            color: Colors.black),
                                        SizedBox(width: 5),
                                        Text(
                                          pengaduan['tgl'],
                                          style: TextStyle(
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 20),
                              Text(
                                'Anda Mengadukan :',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              pengaduan['foto'] == null
                              ? SizedBox()
                              : Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 20),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(20),
                                  child: Image.network(
                                    'https://pexadont.agsa.site/uploads/pengaduan/${pengaduan['foto']}',
                                    // fit: BoxFit.cover,
                                    width: double.infinity,
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 20),
                                child: Text(
                                  pengaduan['isi'],
                                  style: TextStyle(
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              pengaduan['balasan'] == null
                              ? Text("Belum ada balasan") : Container(
                                margin: const EdgeInsets.only(top: 20),
                                child: Text("Balasan : ${pengaduan['balasan']}"),
                              ),
                              SizedBox(
                                height: 30,
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                ),
              ),
            ],
          );
        }
      }),
    );
  }
}
