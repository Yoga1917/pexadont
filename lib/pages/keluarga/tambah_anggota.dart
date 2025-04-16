import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pexadont/pages/tampilan_awal/layout.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class TambahAnggotaKeluargaPage extends StatefulWidget {
  @override
  _TambahAnggotaKeluargaPageState createState() =>
      _TambahAnggotaKeluargaPageState();
}

class _TambahAnggotaKeluargaPageState extends State<TambahAnggotaKeluargaPage> {
  final TextEditingController nikController = TextEditingController();
  final TextEditingController namaController = TextEditingController();
  final TextEditingController jenisKelaminController = TextEditingController();
  final TextEditingController tempatLahirController = TextEditingController();
  final TextEditingController tanggalLahirController = TextEditingController();
  final TextEditingController agamaController = TextEditingController();
  final TextEditingController statusNikahController = TextEditingController();
  final TextEditingController namaAyahController = TextEditingController();
  final TextEditingController namaIbuController = TextEditingController();
  final TextEditingController statusKeluargaController =
      TextEditingController();

  bool isLoading = false;

  String convertToApiDateFormat(String date) {
    try {
      final DateFormat inputFormat = DateFormat('dd MMMM yyyy', 'id_ID');
      final DateTime dateTime = inputFormat.parse(date);

      final DateFormat outputFormat = DateFormat('yyyy-MM-dd');
      return outputFormat.format(dateTime);
    } catch (e) {
      return "";
    }
  }

  Future<void> _kirimData() async {
    final prefs = await SharedPreferences.getInstance();
    final no_kk = prefs.getString('no_kk');

    if (nikController.text.isEmpty ||
        namaController.text.isEmpty ||
        jenisKelaminController.text.isEmpty ||
        tempatLahirController.text.isEmpty ||
        tanggalLahirController.text.isEmpty ||
        agamaController.text.isEmpty ||
        statusNikahController.text.isEmpty ||
        namaAyahController.text.isEmpty ||
        namaIbuController.text.isEmpty ||
        statusKeluargaController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Harap isi semua data!')),
      );
      return;
    }

    if (nikController.text.length < 16) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('NIK harus 16 digit angka!')),
      );
      return;
    }

    if (int.tryParse(nikController.text) == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Data NIK harus berupa angka!')),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final url = Uri.parse('https://pexadont.agsa.site/api/warga/simpan');

      final data = {
        'nik': nikController.text,
        'no_kk': no_kk,
        'nama': namaController.text,
        'jenis_kelamin': jenisKelaminController.text,
        'tempat_lahir': tempatLahirController.text,
        'tgl_lahir': convertToApiDateFormat(tanggalLahirController.text),
        'agama': agamaController.text,
        'status_nikah': statusNikahController.text,
        'nama_ayah': namaAyahController.text,
        'nama_ibu': namaIbuController.text,
        'status_keluarga': statusKeluargaController.text,
        'status': "0",
      };

      print('Mengirim data ke API: $data');

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(data),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Data berhasil dikirim')),
        );

        nikController.clear();
        namaController.clear();
        jenisKelaminController.clear();
        tempatLahirController.clear();
        tanggalLahirController.clear();
        agamaController.clear();
        statusNikahController.clear();
        namaAyahController.clear();
        namaIbuController.clear();
        statusKeluargaController.clear();

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => TambahAnggotaKeluargaPage(),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal mengirim data: ${response.body}')),
        );
      }
    } catch (e, stackTrace) {
      print('Terjadi kesalahan saat kirim data: $e');
      print('Stack trace: $stackTrace');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Terjadi kesalahan: $e')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xff30C083),
        title: Text(
          'Tambah Anggota Keluarga',
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
                  builder: (context) => LayoutPage(goToKeluarga: true)),
            );
          },
        ),
      ),
      body: GestureDetector(
        onTap: () {
          FocusManager.instance.primaryFocus?.unfocus();
        },
        child: SingleChildScrollView(
          child: LayoutBuilder(builder: (context, constraints) {
            if (constraints.maxWidth > 600) {
              return Column();
            } else {
              return Column(
                children: [
                  SizedBox(
                    height: 30,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Container(
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
                        children: [
                          SizedBox(
                            height: 30,
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: TextFormField(
                              controller: nikController,
                              decoration: InputDecoration(
                                prefixIcon: Icon(Icons.badge_rounded),
                                labelText: 'NIK',
                                floatingLabelStyle: const TextStyle(
                                  color: Colors.black,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(
                                    color: const Color(0xff30C083),
                                    width: 2,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 20),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: TextFormField(
                              controller: namaController,
                              decoration: InputDecoration(
                                prefixIcon: Icon(Icons.account_box),
                                labelText: 'Nama Sesuai NIK',
                                floatingLabelStyle: const TextStyle(
                                  color: Colors.black,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(
                                    color: const Color(0xff30C083),
                                    width: 2,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 20),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: DropdownButtonFormField<String>(
                              decoration: InputDecoration(
                                prefixIcon: const Icon(Icons.female),
                                labelText: 'Jenis Kelamin',
                                floatingLabelStyle: const TextStyle(
                                  color: Colors.black,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(
                                    color: const Color(0xff30C083),
                                    width: 2,
                                  ),
                                ),
                              ),
                              items: <String>[
                                'Laki-Laki',
                                'Perempuan'
                              ].map<DropdownMenuItem<String>>((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                              onChanged: (String? newValue) {
                                setState(() {
                                  jenisKelaminController.text = newValue!;
                                });
                              },
                            ),
                          ),
                          SizedBox(height: 20),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: TextFormField(
                              controller: tempatLahirController,
                              decoration: InputDecoration(
                                prefixIcon: const Icon(Icons.location_history),
                                labelText: 'Tempat Lahir',
                                floatingLabelStyle: const TextStyle(
                                  color: Colors.black,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(
                                    color: const Color(0xff30C083),
                                    width: 2,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 20),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: TextFormField(
                              controller: tanggalLahirController,
                              readOnly: true,
                              onTap: () async {
                                DateTime today = DateTime.now();
                                DateTime? pickedDate = await showDatePicker(
                                  context: context,
                                  initialDate: DateTime.now(),
                                  firstDate: DateTime(1900),
                                  lastDate: today,
                                  builder:
                                      (BuildContext context, Widget? child) {
                                    return Theme(
                                      data: ThemeData.light().copyWith(
                                        primaryColor: Color(0xff30C083),
                                        colorScheme: ColorScheme.light(
                                            primary: Color(0xff30C083)),
                                        buttonTheme: ButtonThemeData(
                                            textTheme: ButtonTextTheme.primary),
                                      ),
                                      child: child ?? Container(),
                                    );
                                  },
                                );
                                if (pickedDate != null) {
                                  setState(() {
                                    tanggalLahirController.text =
                                        DateFormat('dd MMMM yyyy', 'id_ID')
                                            .format(pickedDate);
                                  });
                                }
                              },
                              decoration: InputDecoration(
                                prefixIcon: const Icon(Icons.calendar_today),
                                labelText: 'Tanggal Lahir',
                                floatingLabelStyle: const TextStyle(
                                  color: Colors.black,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(
                                    color: Color(0xff30C083),
                                    width: 2,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 20),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: DropdownButtonFormField<String>(
                              decoration: InputDecoration(
                                prefixIcon: const Icon(Icons.self_improvement),
                                labelText: 'Agama',
                                floatingLabelStyle: const TextStyle(
                                  color: Colors.black,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(
                                    color: const Color(0xff30C083),
                                    width: 2,
                                  ),
                                ),
                              ),
                              items: <String>[
                                'Islam',
                                'Kristen',
                                'Katolik',
                                'Hindu',
                                'Buddha',
                                'Konghucu',
                              ].map<DropdownMenuItem<String>>((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                              onChanged: (String? newValue) {
                                setState(() {
                                  agamaController.text = newValue!;
                                });
                              },
                            ),
                          ),
                          SizedBox(height: 20),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: DropdownButtonFormField<String>(
                              decoration: InputDecoration(
                                prefixIcon: const Icon(Icons.favorite),
                                labelText: 'Status Menikah',
                                floatingLabelStyle: const TextStyle(
                                  color: Colors.black,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(
                                    color: const Color(0xff30C083),
                                    width: 2,
                                  ),
                                ),
                              ),
                              items: <String>[
                                'Belum Menikah',
                                'Menikah',
                                'Cerai Hidup',
                                'Cerai Mati',
                              ].map<DropdownMenuItem<String>>((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                              onChanged: (String? newValue) {
                                setState(() {
                                  statusNikahController.text = newValue!;
                                });
                              },
                            ),
                          ),
                          SizedBox(height: 20),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: TextFormField(
                              controller: namaAyahController,
                              decoration: InputDecoration(
                                prefixIcon: const Icon(Icons.man),
                                labelText: 'Nama Ayah Kandung',
                                floatingLabelStyle: const TextStyle(
                                  color: Colors.black,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(
                                    color: const Color(0xff30C083),
                                    width: 2,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 20),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: TextFormField(
                              controller: namaIbuController,
                              decoration: InputDecoration(
                                prefixIcon: const Icon(Icons.woman),
                                labelText: 'Nama Ibu Kandung',
                                floatingLabelStyle: const TextStyle(
                                  color: Colors.black,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(
                                    color: const Color(0xff30C083),
                                    width: 2,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 20),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: DropdownButtonFormField<String>(
                              decoration: InputDecoration(
                                prefixIcon: const Icon(Icons.family_restroom),
                                labelText: 'Status Anggota Keluarga',
                                floatingLabelStyle: const TextStyle(
                                  color: Colors.black,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(
                                    color: const Color(0xff30C083),
                                    width: 2,
                                  ),
                                ),
                              ),
                              items: <String>[
                                'Istri',
                                'Anak',
                              ].map<DropdownMenuItem<String>>((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                              onChanged: (String? newValue) {
                                setState(() {
                                  statusKeluargaController.text = newValue!;
                                });
                              },
                            ),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: GestureDetector(
                              onTap: isLoading ? null : _kirimData,
                              child: Container(
                                width: double.infinity,
                                height: 55,
                                decoration: BoxDecoration(
                                  color: const Color(0xff30C083),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(15),
                                  child: Text(
                                    isLoading ? 'Mengirim...' : 'Kirim',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 30,
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 30,
                  ),
                ],
              );
            }
          }),
        ),
      ),
    );
  }
}
