import 'dart:convert';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:pexadont/pages/beranda/pengaduan.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TambahAduanPage extends StatefulWidget {
  @override
  State<TambahAduanPage> createState() => _TambahAduanPageState();
}

class _TambahAduanPageState extends State<TambahAduanPage> {
  final TextEditingController isiController = TextEditingController();
  String? jenis;
  File? _foto;
  bool isLoading = false;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _foto = File(pickedFile.path);
      });
    }
  }

  Future<void> _kirimData() async {
    if (jenis == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Harap Pilih Jenis Pengaduan!')),
      );
      return;
    }

    if (isiController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Harap isi Keterangan Aduan!')),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('https://pexadont.agsa.site/api/pengaduan/simpan'),
      );
      request.fields['nik'] = prefs.getString('nik')!;
      request.fields['isi'] = isiController.text;
      request.fields['tgl'] = DateFormat('yyyy-MM-dd').format(DateTime.now());
      request.fields['jenis'] = jenis!;
      if (_foto != null) {
        request.files
            .add(await http.MultipartFile.fromPath('foto', _foto!.path));
      }

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 201) {
        var responseData = jsonDecode(response.body);
        if (responseData['status'] == 201) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Pengaduan berhasil dikirim')),
          );
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => PengaduanPage()),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Gagal mengirim pengaduan')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Terjadi kesalahan pada server')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
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
          'Tambah Aduan',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: GestureDetector(
        onTap: () {
          FocusManager.instance.primaryFocus?.unfocus();
        },
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
                          child: DropdownButtonFormField<String>(
                            decoration: InputDecoration(
                              labelText: 'Jenis Pengaduan',
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
                              prefixIcon: Icon(Icons.bug_report),
                            ),
                            items: [
                              'Keuangan',
                              'Fasilitas',
                              'Kebersihan',
                              'Keamanan',
                              'Kinerja',
                              'Kegiatan',
                            ].map((String bulan) {
                              return DropdownMenuItem<String>(
                                value: bulan,
                                child: Text(bulan),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              setState(() {
                                jenis = newValue!;
                              });
                            },
                          ),
                        ),
                        SizedBox(height: 20),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: GestureDetector(
                            onTap: _pickImage,
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 15),
                              decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey),
                                  borderRadius: BorderRadius.circular(10)),
                              child: const Row(
                                children: [
                                  Icon(Icons.upload_file),
                                  SizedBox(width: 10),
                                  Text("Upload Foto")
                                ],
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 10),
                        if (_foto != null)
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10),
                            child: Image.file(
                              _foto!,
                              height: 100,
                              width: 100,
                              fit: BoxFit.cover,
                            ),
                          ),
                        SizedBox(
                          height: 10,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: TextFormField(
                            controller: isiController,
                            maxLines: 5,
                            cursorColor: Color(0xff30C083),
                            decoration: InputDecoration(
                              labelText: 'Keterangan Aduan',
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
                                  isLoading ? 'Mengirim...' : 'Kirim Aduan',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w900,
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
              ],
            );
          }
        }),
      ),
    );
  }
}
