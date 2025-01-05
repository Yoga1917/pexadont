import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pexadont/pages/tampilan_awal/layout.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfilPage extends StatefulWidget {
  @override
  State<ProfilPage> createState() => _ProfilPageState();
}

class _ProfilPageState extends State<ProfilPage> {
  final _nomorRumahController = TextEditingController();
  final _noWaController = TextEditingController();
  Map<String, dynamic>? _profile;
  bool _isUpdating = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _getProfile();
    if (_profile != null) {
      _nomorRumahController.text = _profile!['no_rumah'] ?? '';
      _noWaController.text = _profile!['no_wa'] ?? '';
    }
  }

  Future<void> _getProfile() async {
    try {
      // Ambil NIK dari SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final nik = prefs.getString('nik');

      if (nik == null || nik.isEmpty) {
        throw Exception('NIK tidak ditemukan.');
      }

      // Panggil API
      final response = await http
          .get(Uri.parse('https://pexadont.agsa.site/api/warga/edit/$nik'));

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        if (responseData['status'] == 200 && responseData['data'] != null) {
          setState(() {
            _profile = responseData['data'];
            _isLoading = false;

            _nomorRumahController.text = _profile!['no_rumah'] ?? '';
            _noWaController.text = _profile!['no_wa'] ?? '';
          });
        } else {
          throw Exception('Format data tidak valid');
        }
      } else {
        throw Exception('Gagal mengambil data: ${response.statusCode}');
      }
    } catch (error) {
      setState(() {
        _isLoading = false;
      });
      print('Error: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Terjadi kesalahan: $error')),
      );
    }
  }

  Future<void> _updateProfile() async {
    setState(() {
      _isUpdating = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final nik = prefs.getString('nik');

      if (nik == null || nik.isEmpty) {
        throw Exception('NIK tidak ditemukan.');
      }

      if (_nomorRumahController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text(
                  'Form tidak boleh kosong! Perbarui data yang diperlukan!.')),
        );
        return;
      }

      if (_noWaController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text(
                  'Form tidak boleh kosong! Perbarui data yang diperlukan!.')),
        );
        return;
      }

      // Cek jika tidak ada perubahan
      if (_nomorRumahController.text == _profile!['no_rumah'] &&
          _noWaController.text == _profile!['no_wa']) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tidak ada data yang diubah.')),
        );
        return;
      }

      // Persiapkan data untuk API
      final requestBody = {
        'nik': _profile!['nik'],
        'nama': _profile!['nama'],
        'tgl_lahir': _profile!['tgl_lahir'],
        'jenis_kelamin': _profile!['jenis_kelamin'],
        'no_rumah': _nomorRumahController.text, // data baru
        'no_wa': _noWaController.text, // data baru
        'status': _profile!['status'],
      };

      // Kirim permintaan ke API
      final response = await http.post(
        Uri.parse('https://pexadont.agsa.site/api/warga/update/$nik'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(requestBody),
      );
      if (response.statusCode == 202) {
        final data = json.decode(response.body);

        if (data['status'] == 202) {
          // Update data lokal
          setState(() {
            _profile!['no_rumah'] = _nomorRumahController.text;
            _profile!['no_wa'] = _noWaController.text;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profil berhasil diperbarui')),
          );
        } else {
          throw Exception('Gagal memperbarui profil');
        }
      } else {
        throw Exception('Gagal menghubungi server: ${response.statusCode}');
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Terjadi kesalahan: $error')),
      );
    } finally {
      setState(() {
        _isUpdating = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xff30C083),
        title: Text(
          'Profil',
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
                  builder: (context) => LayoutPage(goToPengaturan: true)),
            );
          },
        ),
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: Color(0xff30C083),
              ),
            )
          : _profile == null
              ? Center(child: Text('Data tidak ditemukan.'))
              : SingleChildScrollView(
                  child: Center(
                    child: Column(
                      children: [
                        SizedBox(
                          height: 30,
                        ),
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
                                      _profile!['foto'] != null
                                          ? 'https://pexadont.agsa.site/uploads/warga/${_profile!['foto']}'
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
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: <Widget>[
                                      SizedBox(height: 10),
                                      Text(
                                        _profile!['nama'] ?? 'Unknown Name',
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(height: 10),
                                      Text(
                                        'Nik : ${_profile!['nik']}',
                                        style: TextStyle(
                                          fontSize: 14,
                                        ),
                                      ),
                                      SizedBox(height: 2),
                                      Text(
                                        'Tanggal Lahir : ${_profile!['tgl_lahir']}',
                                        style: TextStyle(
                                          fontSize: 14,
                                        ),
                                      ),
                                      SizedBox(height: 2),
                                      Text(
                                        'Jenis Kelamin : ${_profile!['jenis_kelamin']}',
                                        style: TextStyle(
                                          fontSize: 14,
                                        ),
                                      ),
                                      SizedBox(height: 2),
                                      Text(
                                        'No. Rumah : ${_profile!['no_rumah']}',
                                        style: TextStyle(
                                          fontSize: 14,
                                        ),
                                      ),
                                      SizedBox(height: 2),
                                      Text(
                                        'No. WhatsApp : ${_profile!['no_wa']}',
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
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                          child: Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(width: 1, color: Colors.grey),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  spreadRadius: 1,
                                  blurRadius: 5,
                                  offset: Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 20),
                                  child: Text(
                                    'Edit Profil Anda',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20),
                                  child: TextFormField(
                                    controller: _nomorRumahController,
                                    cursorColor: Colors.black,
                                    decoration: InputDecoration(
                                      prefixIcon: const Icon(Icons.home),
                                      labelText: 'Nomor Rumah',
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
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20),
                                  child: TextFormField(
                                    controller: _noWaController,
                                    cursorColor: Colors.black,
                                    decoration: InputDecoration(
                                      prefixIcon: const Icon(Icons.call),
                                      labelText: 'Nomor WhatsApp',
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
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20),
                                  child: GestureDetector(
                                    onTap: _updateProfile,
                                    child: Container(
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        color: const Color(0xff30C083),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(15),
                                        child: Text(
                                          _isUpdating ? 'Simpan...' : 'Simpan',
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
                        SizedBox(
                          height: 30,
                        ),
                      ],
                    ),
                  ),
                ),
    );
  }
}
