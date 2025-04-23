import 'dart:convert';
import 'dart:io';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:pexadont/pages/daftar/pilih_lokasi.dart';
import 'package:pexadont/pages/lokasi_maps.dart';
import 'package:pexadont/pages/mulai/login.dart';
import 'package:pexadont/pages/mulai/start_page.dart';
import 'package:pexadont/pages/pengaturan/kebijakan_privasi.dart';
import 'package:pexadont/pages/pengaturan/syarat.dart';

class DaftarPage extends StatefulWidget {
  @override
  _DaftarPageState createState() => _DaftarPageState();
}

class _DaftarPageState extends State<DaftarPage> {
  final _formKey1 = GlobalKey<FormState>();
  final _formKey2 = GlobalKey<FormState>();
  final _formKey3 = GlobalKey<FormState>();
  final _formKey4 = GlobalKey<FormState>();

  String? _noRumah;
  String? _peta;
  String buttonText = 'Daftar';
  String? statusKeluarga;
  String? selectedJob;
  String? anggotaKeluarga;
  List<String> jobItems = ['Pelajar', 'Tidak Bekerja', 'Bekerja'];

  final TextEditingController nikController = TextEditingController();
  final TextEditingController noKKController = TextEditingController();
  final TextEditingController noKKAnggota = TextEditingController();
  final TextEditingController namaController = TextEditingController();
  final TextEditingController jenisKelaminController = TextEditingController();
  final TextEditingController tempatLahirController = TextEditingController();
  final TextEditingController tanggalLahirController = TextEditingController();
  final TextEditingController agamaController = TextEditingController();
  final TextEditingController statusNikahController = TextEditingController();
  final TextEditingController pendidikanController = TextEditingController();
  final TextEditingController pekerjaanController = TextEditingController();
  final TextEditingController gajiController = TextEditingController();
  final TextEditingController namaAyahController = TextEditingController();
  final TextEditingController namaIbuController = TextEditingController();
  final TextEditingController statusKeluargaController =
      TextEditingController();
  final TextEditingController nomorRumahController = TextEditingController();
  final TextEditingController nomorTeleponController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController ulangiPasswordController =
      TextEditingController();
  final TextEditingController lokasiController = TextEditingController();

  List<Map<String, dynamic>> provinsiList = [];
  List<Map<String, dynamic>> kotaList = [];

  File? _image;

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isExpanded = false;
  bool _isKKChecked = false;
  bool _isLoading = false;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

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

  void _submitData() {
    setState(() {
      buttonText = 'Mendaftar...';
    });

    if ((nikController.text == "") ||
        (noKKController.text == "") ||
        (namaController.text == "") ||
        (jenisKelaminController.text == "") ||
        (tempatLahirController.text == "") ||
        (tanggalLahirController.text == "") ||
        (agamaController.text == "") ||
        (statusNikahController.text == "") ||
        (pendidikanController.text == "") ||
        (pekerjaanController.text == "") ||
        (gajiController.text == "") ||
        (namaAyahController.text == "") ||
        (namaIbuController.text == "") ||
        (statusKeluargaController.text == "") ||
        (nomorRumahController.text == "") ||
        (nomorTeleponController.text == "") ||
        (passwordController.text == "") ||
        (ulangiPasswordController.text == "") ||
        (lokasiController.text == "") ||
        (_image == null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Harap lengkapi semua data!')),
      );

      setState(() {
        buttonText = 'Daftar';
      });
      return;
    }

    if (nikController.text.length < 16) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('NIK harus 16 digit angka!')),
      );

      setState(() {
        buttonText = 'Daftar';
      });
      return;
    }

    if (int.tryParse(nomorTeleponController.text) == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Nomor WhatsApp harus berupa angka!')),
      );

      setState(() {
        buttonText = 'Daftar';
      });
      return;
    }

    if (int.tryParse(nikController.text) == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Data NIK harus berupa angka!')),
      );

      setState(() {
        buttonText = 'Daftar';
      });
      return;
    }

    if (pekerjaanController.text == 'Bekerja') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Harap isi detail pekerjaan!')),
      );

      setState(() {
        buttonText = 'Daftar';
      });
      return;
    }

    if (passwordController.text != ulangiPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Konfirmasi Password Tidak Cocok!')),
      );

      setState(() {
        buttonText = 'Daftar';
      });
      return;
    }

    if (statusKeluargaController.text == "Kepala Keluarga") {
      print('Pendaftaran sebagai Kepala Keluarga');
      _register().then((_) {
        print('_register() berhasil, memanggil _registerKK()');
        _registerKK().whenComplete(() {
          setState(() {
            buttonText = 'Daftar';
          });
        });
      }).catchError((error) {
        setState(() {
          buttonText = 'Daftar';
        });
        print('Error di _register(): $error');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal mendaftar: $error')),
        );
      });
    } else {
      print('Pendaftaran sebagai Anggota Keluarga');
      _register().whenComplete(() {
        setState(() {
          buttonText = 'Daftar';
        });
      }).catchError((error) {
        setState(() {
          buttonText = 'Daftar';
        });
        print('Error di _register(): $error');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal mendaftar: $error')),
        );
      });
    }
  }

  Future<void> _register() async {
    try {
      var request = http.MultipartRequest(
          'POST', Uri.parse('https://pexadont.agsa.site/api/warga/simpan'));
      request.fields['nik'] = nikController.text;
      request.fields['no_kk'] = noKKController.text;
      request.fields['nama'] = namaController.text;
      request.fields['jenis_kelamin'] = jenisKelaminController.text;
      request.fields['tempat_lahir'] = tempatLahirController.text;
      request.fields['tgl_lahir'] =
          convertToApiDateFormat(tanggalLahirController.text);
      request.fields['agama'] = agamaController.text;
      request.fields['status_nikah'] = statusNikahController.text;
      request.fields['pendidikan'] = pendidikanController.text;
      request.fields['pekerjaan'] = pekerjaanController.text;
      request.fields['gaji'] = gajiController.text;
      request.fields['nama_ayah'] = namaAyahController.text;
      request.fields['nama_ibu'] = namaIbuController.text;
      request.fields['status_keluarga'] = statusKeluargaController.text;
      request.fields['no_wa'] = nomorTeleponController.text;
      request.fields['password'] = passwordController.text;
      request.fields['status'] = "0";
      request.files
          .add(await http.MultipartFile.fromPath('foto', _image!.path));

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);
      var responseData = jsonDecode(response.body);

      if (responseData['status'] == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Pendaftaran warga berhasil!')),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginPage()),
        );
      } else {
        if (responseData['data']['foto'] != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(responseData['data']['foto'])),
          );
        }
        if (responseData['data']['nik'] != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(responseData['data']['nik'])),
          );
        }
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Terjadi kesalahan: $error')),
      );
    }
  }

  Future<void> _registerKK() async {
    try {
      // Pisahkan latitude dan longitude
      var lokasi = lokasiController.text.split(', ');
      var latitude = lokasi[0];
      var longitude = lokasi[1];

      // Buat request
      var request = http.MultipartRequest(
          'POST', Uri.parse('https://pexadont.agsa.site/api/keluarga/simpan'));
      request.fields['no_kk'] = noKKController.text;
      request.fields['nik'] = nikController.text;
      request.fields['no_rumah'] = nomorRumahController.text;
      request.fields['alamat'] = "Pekajangan Gg.19 Rt.19 Rw.07";
      request.fields['latitude'] = latitude;
      request.fields['longitude'] = longitude;
      request.fields['status'] = "Proses Verifikasi";

      // Kirim request
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);
      var responseData = jsonDecode(response.body);

      if (responseData['status'] == 200) {
        print('Pendaftaran KK berhasil!');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Pendaftaran KK berhasil!')),
        );
      } else {
        print('Gagal mendaftar KK: ${responseData['message']}');
        throw Exception(responseData['message'] ?? 'Gagal mendaftar KK');
      }
    } catch (error) {
      print('Terjadi kesalahan di _registerKK(): $error');
      throw Exception('Terjadi kesalahan: $error');
    }
  }

  void _cekNoKK() async {
    if (noKKAnggota.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Harap isi data No KK!')),
      );
      return;
    }

    if (noKKAnggota.text.length < 16) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No KK harus 16 digit angka!')),
      );
      return;
    }

    if (int.tryParse(noKKAnggota.text) == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Data No KK harus berupa angka!')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final request = await http.get(
        Uri.parse(
            'https://pexadont.agsa.site/api/keluarga/edit/${noKKAnggota.text}'),
        headers: {'Content-Type': 'application/json'},
      );

      final response = jsonDecode(request.body);

      if (response["status"] == 200) {
        setState(() {
          _isKKChecked = true;
          _noRumah = response["data"]["no_rumah"];
          _peta = response["data"]["latitude"] != null &&
                  response["data"]["longitude"] != null
              ? "${response["data"]["latitude"]}, ${response["data"]["longitude"]}"
              : 'Lokasi tidak tersedia';
          ;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Data KK ditemukan!')),
        );
      } else {
        setState(() {
          _isKKChecked = false;
          _noRumah = null;
          _peta = null;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Data KK tidak ditemukan!')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Terjadi kesalahan: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xff30C083),
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
        title: Text(
          'pexadon\'t',
          style: GoogleFonts.righteous(
            fontSize: 30,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => StartPage()),
            );
          },
        ),
      ),
      body: GestureDetector(
        onTap: () {
          FocusManager.instance.primaryFocus?.unfocus();
        },
        child: Stack(
          children: <Widget>[
            Container(
              width: double.infinity,
              height: 400,
              decoration: BoxDecoration(
                color: Color(0xff30C083),
                borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(40),
                    bottomRight: Radius.circular(40)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
            ),
            SingleChildScrollView(
              child: Center(
                child: Column(
                  children: [
                    SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Container(
                        width: 600,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Daftar',
                              style: TextStyle(
                                fontSize: 40,
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            Text(
                              'Daftarkan akun untuk bisa mengakses seluruh fitur yang ada di Aplikasi.',
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Container(
                        width: 600,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              spreadRadius: 2,
                              blurRadius: 5,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            SizedBox(height: 30),
                            Container(
                              width: 220,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              decoration: BoxDecoration(
                                border: Border.all(
                                    color: Color.fromARGB(255, 120, 116, 116),
                                    width: 1.5),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: DropdownButton<String>(
                                value: statusKeluarga,
                                isExpanded: true,
                                underline: const SizedBox(),
                                icon: const Icon(Icons.arrow_drop_down,
                                    size: 24, color: Colors.black),
                                iconSize: 24,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.black,
                                ),
                                alignment: Alignment.center,
                                hint: const Text(
                                  'Status Keluarga',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black),
                                ),
                                items: <String>[
                                  'Kepala Keluarga',
                                  'Anggota Keluarga'
                                ].map<DropdownMenuItem<String>>((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(
                                      value,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  );
                                }).toList(),
                                onChanged: (String? newValue) {
                                  setState(() {
                                    statusKeluarga = newValue!;
                                    if (statusKeluarga == "Kepala Keluarga") {
                                      statusKeluargaController.text =
                                          "Kepala Keluarga";
                                      anggotaKeluarga = null;
                                    } else {
                                      statusKeluargaController.text = "";
                                    }
                                  });
                                },
                              ),
                            ),
                            SizedBox(height: 30),
                            if (statusKeluarga != null) ...[
                              Card(
                                color: Colors.white,
                                margin: EdgeInsets.only(left: 20, right: 20),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  side: BorderSide(
                                    color: Color.fromARGB(255, 120, 116, 116),
                                  ),
                                ),
                                child: ExpansionTile(
                                  title: Text(
                                    "Identitas Keluarga",
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  initiallyExpanded: _isExpanded,
                                  onExpansionChanged: (expanded) {
                                    if (!expanded &&
                                        !_formKey1.currentState!.validate()) {
                                      return;
                                    }
                                    setState(() {
                                      _isExpanded = expanded;
                                    });
                                  },
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.zero),
                                  collapsedShape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.zero),
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 20),
                                      child: Form(
                                          key: _formKey1,
                                          child: Column(children: [
                                            SizedBox(height: 5),
                                            statusKeluarga == "Kepala Keluarga"
                                                ? TextFormField(
                                                    controller:
                                                        statusKeluargaController,
                                                    enabled: false,
                                                    decoration: InputDecoration(
                                                      prefixIcon: const Icon(
                                                          Icons
                                                              .family_restroom),
                                                      labelText:
                                                          'Status Keluarga',
                                                      floatingLabelStyle:
                                                          const TextStyle(
                                                        color: Colors.black,
                                                      ),
                                                      border:
                                                          OutlineInputBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10),
                                                      ),
                                                      focusedBorder:
                                                          OutlineInputBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10),
                                                        borderSide:
                                                            const BorderSide(
                                                          color: const Color(
                                                              0xff30C083),
                                                          width: 2,
                                                        ),
                                                      ),
                                                    ),
                                                  )
                                                : SizedBox(),
                                            statusKeluarga == "Kepala Keluarga"
                                                ? Padding(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        vertical: 20),
                                                    child: TextFormField(
                                                      controller:
                                                          noKKController,
                                                      decoration:
                                                          InputDecoration(
                                                        prefixIcon: const Icon(
                                                            Icons.credit_card),
                                                        labelText: 'No KK',
                                                        floatingLabelStyle:
                                                            const TextStyle(
                                                          color: Colors.black,
                                                        ),
                                                        border:
                                                            OutlineInputBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(10),
                                                        ),
                                                        focusedBorder:
                                                            OutlineInputBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(10),
                                                          borderSide:
                                                              const BorderSide(
                                                            color: const Color(
                                                                0xff30C083),
                                                            width: 2,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  )
                                                : Column(
                                                    children: [
                                                      TextFormField(
                                                        controller: noKKAnggota,
                                                        decoration:
                                                            InputDecoration(
                                                          prefixIcon:
                                                              const Icon(Icons
                                                                  .credit_card),
                                                          labelText:
                                                              'Cek No KK',
                                                          floatingLabelStyle:
                                                              const TextStyle(
                                                            color: Colors.black,
                                                          ),
                                                          border:
                                                              OutlineInputBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        10),
                                                          ),
                                                          focusedBorder:
                                                              OutlineInputBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        10),
                                                            borderSide:
                                                                const BorderSide(
                                                              color: const Color(
                                                                  0xff30C083),
                                                              width: 2,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      SizedBox(height: 20),
                                                      _isLoading
                                                          ? Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .only(
                                                                      bottom:
                                                                          20),
                                                              child:
                                                                  CircularProgressIndicator(),
                                                            )
                                                          : _isKKChecked
                                                              ? SizedBox()
                                                              : GestureDetector(
                                                                  onTap:
                                                                      _cekNoKK,
                                                                  child:
                                                                      Container(
                                                                    margin: EdgeInsets.only(
                                                                        bottom:
                                                                            20),
                                                                    width: double
                                                                        .infinity,
                                                                    height: 55,
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      color: const Color(
                                                                          0xff30C083),
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              10),
                                                                    ),
                                                                    child:
                                                                        Padding(
                                                                      padding: const EdgeInsets
                                                                          .all(
                                                                          15),
                                                                      child:
                                                                          Text(
                                                                        'Cek KK',
                                                                        style:
                                                                            TextStyle(
                                                                          color:
                                                                              Colors.white,
                                                                          fontWeight:
                                                                              FontWeight.w900,
                                                                          fontSize:
                                                                              18,
                                                                        ),
                                                                        textAlign:
                                                                            TextAlign.center,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                    ],
                                                  ),
                                            statusKeluarga == "Kepala Keluarga"
                                                ? TextFormField(
                                                    controller:
                                                        nomorRumahController,
                                                    decoration: InputDecoration(
                                                      prefixIcon: const Icon(
                                                          Icons.home),
                                                      labelText: 'Nomor Rumah',
                                                      floatingLabelStyle:
                                                          const TextStyle(
                                                        color: Colors.black,
                                                      ),
                                                      border:
                                                          OutlineInputBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10),
                                                      ),
                                                      focusedBorder:
                                                          OutlineInputBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10),
                                                        borderSide:
                                                            const BorderSide(
                                                          color: const Color(
                                                              0xff30C083),
                                                          width: 2,
                                                        ),
                                                      ),
                                                    ),
                                                  )
                                                : _isKKChecked
                                                    ? TextFormField(
                                                        initialValue: _noRumah,
                                                        readOnly: true,
                                                        decoration:
                                                            InputDecoration(
                                                          prefixIcon:
                                                              const Icon(
                                                                  Icons.home),
                                                          labelText:
                                                              'Nomor Rumah',
                                                          floatingLabelStyle:
                                                              const TextStyle(
                                                            color: Colors.black,
                                                          ),
                                                          border:
                                                              OutlineInputBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        10),
                                                          ),
                                                          focusedBorder:
                                                              OutlineInputBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        10),
                                                            borderSide:
                                                                const BorderSide(
                                                              color: const Color(
                                                                  0xff30C083),
                                                              width: 2,
                                                            ),
                                                          ),
                                                        ),
                                                      )
                                                    : SizedBox(),
                                            statusKeluarga == "Kepala Keluarga"
                                                ? Padding(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        vertical: 20),
                                                    child: TextFormField(
                                                      controller:
                                                          lokasiController,
                                                      readOnly: true,
                                                      onTap: () async {
                                                        final result =
                                                            await Navigator
                                                                .push(
                                                          context,
                                                          MaterialPageRoute(
                                                              builder: (context) =>
                                                                  PilihLokasi()),
                                                        );

                                                        if (result != null &&
                                                            result is LatLng) {
                                                          setState(() {
                                                            lokasiController
                                                                    .text =
                                                                "${result.latitude}, ${result.longitude}";
                                                          });
                                                        }
                                                      },
                                                      decoration:
                                                          InputDecoration(
                                                        prefixIcon: const Icon(
                                                            Icons.location_on),
                                                        labelText:
                                                            'Lokasi Maps Rumah',
                                                        border:
                                                            OutlineInputBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(10),
                                                        ),
                                                        floatingLabelStyle:
                                                            const TextStyle(
                                                          color: Colors.black,
                                                        ),
                                                        focusedBorder:
                                                            OutlineInputBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(10),
                                                          borderSide:
                                                              const BorderSide(
                                                            color: const Color(
                                                                0xff30C083),
                                                            width: 2,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  )
                                                : _isKKChecked
                                                    ? Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                                vertical: 20),
                                                        child: TextFormField(
                                                          initialValue: _peta,
                                                          readOnly: true,
                                                          onTap: () {
                                                            if (_peta == null ||
                                                                _peta ==
                                                                    'Lokasi tidak tersedia') {
                                                              ScaffoldMessenger
                                                                      .of(context)
                                                                  .showSnackBar(
                                                                SnackBar(
                                                                    content: Text(
                                                                        'Lokasi tidak tersedia')),
                                                              );
                                                              return;
                                                            }

                                                            final coords =
                                                                _peta!.split(
                                                                    ', ');
                                                            if (coords.length !=
                                                                2) {
                                                              ScaffoldMessenger
                                                                      .of(context)
                                                                  .showSnackBar(
                                                                SnackBar(
                                                                    content: Text(
                                                                        'Format lokasi tidak valid')),
                                                              );
                                                              return;
                                                            }

                                                            final lat =
                                                                double.tryParse(
                                                                    coords[0]);
                                                            final lng =
                                                                double.tryParse(
                                                                    coords[1]);

                                                            if (lat == null ||
                                                                lng == null) {
                                                              ScaffoldMessenger
                                                                      .of(context)
                                                                  .showSnackBar(
                                                                SnackBar(
                                                                    content: Text(
                                                                        'Koordinat tidak valid')),
                                                              );
                                                              return;
                                                            }

                                                            Navigator.push(
                                                              context,
                                                              MaterialPageRoute(
                                                                builder:
                                                                    (context) =>
                                                                        LokasiMapPage(
                                                                  latitude: lat,
                                                                  longitude:
                                                                      lng,
                                                                ),
                                                              ),
                                                            );
                                                          },
                                                          decoration:
                                                              InputDecoration(
                                                            prefixIcon:
                                                                const Icon(Icons
                                                                    .location_on),
                                                            labelText:
                                                                'Klik untuk lihat peta',
                                                            hintText:
                                                                'Klik untuk lihat peta',
                                                            border:
                                                                OutlineInputBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          10),
                                                            ),
                                                            floatingLabelStyle:
                                                                const TextStyle(
                                                              color:
                                                                  Colors.black,
                                                            ),
                                                            focusedBorder:
                                                                OutlineInputBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          10),
                                                              borderSide:
                                                                  const BorderSide(
                                                                color: Color(
                                                                    0xff30C083),
                                                                width: 2,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      )
                                                    : SizedBox(),
                                          ])),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 20),
                              Card(
                                color: Colors.white,
                                margin: EdgeInsets.only(left: 20, right: 20),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  side: BorderSide(
                                    color: Color.fromARGB(255, 120, 116, 116),
                                  ),
                                ),
                                child: ExpansionTile(
                                  title: Text(
                                    "Identitas Pribadi",
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  initiallyExpanded: _isExpanded,
                                  onExpansionChanged: (expanded) {
                                    if (!expanded &&
                                        !_formKey2.currentState!.validate()) {
                                      return;
                                    }
                                    setState(() {
                                      _isExpanded = expanded;
                                    });
                                  },
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.zero),
                                  collapsedShape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.zero),
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 20),
                                      child: Form(
                                          key: _formKey2,
                                          child: Column(children: [
                                            SizedBox(height: 5),
                                            statusKeluarga == "Kepala Keluarga"
                                                ? TextFormField(
                                                    controller: nikController,
                                                    decoration: InputDecoration(
                                                      prefixIcon: const Icon(
                                                          Icons.badge_rounded),
                                                      labelText: 'NIK',
                                                      floatingLabelStyle:
                                                          const TextStyle(
                                                        color: Colors.black,
                                                      ),
                                                      border:
                                                          OutlineInputBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10),
                                                      ),
                                                      focusedBorder:
                                                          OutlineInputBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10),
                                                        borderSide:
                                                            const BorderSide(
                                                          color: const Color(
                                                              0xff30C083),
                                                          width: 2,
                                                        ),
                                                      ),
                                                    ),
                                                  )
                                                : TextFormField(
                                                    controller: nikController,
                                                    decoration: InputDecoration(
                                                      prefixIcon: const Icon(
                                                          Icons.badge_rounded),
                                                      labelText: 'Pilih NIK',
                                                      floatingLabelStyle:
                                                          const TextStyle(
                                                        color: Colors.black,
                                                      ),
                                                      border:
                                                          OutlineInputBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10),
                                                      ),
                                                      focusedBorder:
                                                          OutlineInputBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10),
                                                        borderSide:
                                                            const BorderSide(
                                                          color: const Color(
                                                              0xff30C083),
                                                          width: 2,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                            SizedBox(height: 20),
                                            TextFormField(
                                              controller: namaController,
                                              decoration: InputDecoration(
                                                prefixIcon: const Icon(
                                                    Icons.account_box),
                                                labelText: 'Nama Sesuai NIK',
                                                floatingLabelStyle:
                                                    const TextStyle(
                                                  color: Colors.black,
                                                ),
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                                focusedBorder:
                                                    OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  borderSide: const BorderSide(
                                                    color:
                                                        const Color(0xff30C083),
                                                    width: 2,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            SizedBox(height: 20),
                                            DropdownButtonFormField<String>(
                                              decoration: InputDecoration(
                                                prefixIcon:
                                                    const Icon(Icons.female),
                                                labelText: 'Jenis Kelamin',
                                                floatingLabelStyle:
                                                    const TextStyle(
                                                  color: Colors.black,
                                                ),
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                                focusedBorder:
                                                    OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  borderSide: const BorderSide(
                                                    color:
                                                        const Color(0xff30C083),
                                                    width: 2,
                                                  ),
                                                ),
                                              ),
                                              items: <String>[
                                                'Laki-Laki',
                                                'Perempuan'
                                              ].map<DropdownMenuItem<String>>(
                                                  (String value) {
                                                return DropdownMenuItem<String>(
                                                  value: value,
                                                  child: Text(value),
                                                );
                                              }).toList(),
                                              onChanged: (String? newValue) {
                                                setState(() {
                                                  jenisKelaminController.text =
                                                      newValue!;
                                                });
                                              },
                                            ),
                                            SizedBox(height: 20),
                                            TextFormField(
                                              controller: tempatLahirController,
                                              decoration: InputDecoration(
                                                prefixIcon: const Icon(
                                                    Icons.location_history),
                                                labelText: 'Tempat Lahir',
                                                floatingLabelStyle:
                                                    const TextStyle(
                                                  color: Colors.black,
                                                ),
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                                focusedBorder:
                                                    OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  borderSide: const BorderSide(
                                                    color:
                                                        const Color(0xff30C083),
                                                    width: 2,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            SizedBox(height: 20),
                                            TextFormField(
                                              controller:
                                                  tanggalLahirController,
                                              readOnly: true,
                                              onTap: () async {
                                                DateTime today = DateTime.now();
                                                DateTime? pickedDate =
                                                    await showDatePicker(
                                                  context: context,
                                                  initialDate: DateTime.now(),
                                                  firstDate: DateTime(1900),
                                                  lastDate: today,
                                                  builder:
                                                      (BuildContext context,
                                                          Widget? child) {
                                                    return Theme(
                                                      data: ThemeData.light()
                                                          .copyWith(
                                                        primaryColor:
                                                            Color(0xff30C083),
                                                        colorScheme:
                                                            ColorScheme.light(
                                                                primary: Color(
                                                                    0xff30C083)),
                                                        buttonTheme: ButtonThemeData(
                                                            textTheme:
                                                                ButtonTextTheme
                                                                    .primary),
                                                      ),
                                                      child:
                                                          child ?? Container(),
                                                    );
                                                  },
                                                );
                                                if (pickedDate != null) {
                                                  setState(() {
                                                    tanggalLahirController
                                                        .text = DateFormat(
                                                            'dd MMMM yyyy',
                                                            'id_ID')
                                                        .format(pickedDate);
                                                  });
                                                }
                                              },
                                              decoration: InputDecoration(
                                                prefixIcon: const Icon(
                                                    Icons.calendar_today),
                                                labelText: 'Tanggal Lahir',
                                                floatingLabelStyle:
                                                    const TextStyle(
                                                  color: Colors.black,
                                                ),
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                                focusedBorder:
                                                    OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  borderSide: const BorderSide(
                                                    color: Color(0xff30C083),
                                                    width: 2,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            SizedBox(height: 20),
                                            DropdownButtonFormField<String>(
                                              decoration: InputDecoration(
                                                prefixIcon: const Icon(
                                                    Icons.self_improvement),
                                                labelText: 'Agama',
                                                floatingLabelStyle:
                                                    const TextStyle(
                                                  color: Colors.black,
                                                ),
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                                focusedBorder:
                                                    OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  borderSide: const BorderSide(
                                                    color:
                                                        const Color(0xff30C083),
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
                                              ].map<DropdownMenuItem<String>>(
                                                  (String value) {
                                                return DropdownMenuItem<String>(
                                                  value: value,
                                                  child: Text(value),
                                                );
                                              }).toList(),
                                              onChanged: (String? newValue) {
                                                setState(() {
                                                  agamaController.text =
                                                      newValue!;
                                                });
                                              },
                                            ),
                                            SizedBox(height: 20),
                                            DropdownButtonFormField<String>(
                                              decoration: InputDecoration(
                                                prefixIcon:
                                                    const Icon(Icons.favorite),
                                                labelText: 'Status Menikah',
                                                floatingLabelStyle:
                                                    const TextStyle(
                                                  color: Colors.black,
                                                ),
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                                focusedBorder:
                                                    OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  borderSide: const BorderSide(
                                                    color:
                                                        const Color(0xff30C083),
                                                    width: 2,
                                                  ),
                                                ),
                                              ),
                                              items: <String>[
                                                'Belum Menikah',
                                                'Menikah',
                                                'Cerai Hidup',
                                                'Cerai Mati',
                                              ].map<DropdownMenuItem<String>>(
                                                  (String value) {
                                                return DropdownMenuItem<String>(
                                                  value: value,
                                                  child: Text(value),
                                                );
                                              }).toList(),
                                              onChanged: (String? newValue) {
                                                setState(() {
                                                  statusNikahController.text =
                                                      newValue!;
                                                });
                                              },
                                            ),
                                            SizedBox(height: 20),
                                            TextFormField(
                                              controller: namaAyahController,
                                              decoration: InputDecoration(
                                                prefixIcon:
                                                    const Icon(Icons.man),
                                                labelText: 'Nama Ayah Kandung',
                                                floatingLabelStyle:
                                                    const TextStyle(
                                                  color: Colors.black,
                                                ),
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                                focusedBorder:
                                                    OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  borderSide: const BorderSide(
                                                    color:
                                                        const Color(0xff30C083),
                                                    width: 2,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            SizedBox(height: 20),
                                            TextFormField(
                                              controller: namaIbuController,
                                              decoration: InputDecoration(
                                                prefixIcon:
                                                    const Icon(Icons.woman),
                                                labelText: 'Nama Ibu Kandung',
                                                floatingLabelStyle:
                                                    const TextStyle(
                                                  color: Colors.black,
                                                ),
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                                focusedBorder:
                                                    OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  borderSide: const BorderSide(
                                                    color:
                                                        const Color(0xff30C083),
                                                    width: 2,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            SizedBox(height: 20),
                                          ])),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 20),
                              Card(
                                color: Colors.white,
                                margin: EdgeInsets.only(left: 20, right: 20),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  side: BorderSide(
                                    color: Color.fromARGB(255, 120, 116, 116),
                                  ),
                                ),
                                child: ExpansionTile(
                                  title: Text(
                                    "Sosial dan Ekonomi",
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  initiallyExpanded: _isExpanded,
                                  onExpansionChanged: (expanded) {
                                    if (!expanded &&
                                        !_formKey3.currentState!.validate()) {
                                      return;
                                    }
                                    setState(() {
                                      _isExpanded = expanded;
                                    });
                                  },
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.zero),
                                  collapsedShape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.zero),
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 20),
                                      child: Form(
                                          key: _formKey3,
                                          child: Column(children: [
                                            SizedBox(height: 5),
                                            DropdownButtonFormField<String>(
                                              isExpanded: true,
                                              decoration: InputDecoration(
                                                prefixIcon:
                                                    const Icon(Icons.school),
                                                labelText: 'Pendidikan',
                                                floatingLabelStyle:
                                                    const TextStyle(
                                                  color: Colors.black,
                                                ),
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                                focusedBorder:
                                                    OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  borderSide: const BorderSide(
                                                    color:
                                                        const Color(0xff30C083),
                                                    width: 2,
                                                  ),
                                                ),
                                              ),
                                              items: <String>[
                                                'Tidak Sekolah',
                                                'Sekolah Dasar',
                                                'Sekolah Menengah Pertama',
                                                'Sekolah Menengah Atas/Kejuruan',
                                                'Diploma 1',
                                                'Diploma 2',
                                                'Diploma 3',
                                                'Sarjana (S1)',
                                                'Magister (S2)',
                                                'Doktor (S3)',
                                              ].map<DropdownMenuItem<String>>(
                                                  (String value) {
                                                return DropdownMenuItem<String>(
                                                  value: value,
                                                  child: Text(value),
                                                );
                                              }).toList(),
                                              onChanged: (String? newValue) {
                                                setState(() {
                                                  pendidikanController.text =
                                                      newValue!;
                                                });
                                              },
                                            ),
                                            SizedBox(height: 20),
                                            DropdownButtonFormField<String>(
                                              decoration: InputDecoration(
                                                prefixIcon:
                                                    const Icon(Icons.work),
                                                labelText: 'Pekerjaan',
                                                floatingLabelStyle:
                                                    const TextStyle(
                                                  color: Colors.black,
                                                ),
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                                focusedBorder:
                                                    OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  borderSide: const BorderSide(
                                                    color: Color(0xff30C083),
                                                    width: 2,
                                                  ),
                                                ),
                                              ),
                                              value: selectedJob,
                                              items: jobItems.map<
                                                      DropdownMenuItem<String>>(
                                                  (String value) {
                                                return DropdownMenuItem<String>(
                                                  value: value,
                                                  child: Text(value),
                                                );
                                              }).toList(),
                                              onChanged: (String? newValue) {
                                                setState(() {
                                                  if (newValue ==
                                                      'Tidak Bekerja') {
                                                    selectedJob = newValue!;
                                                    pekerjaanController.text =
                                                        selectedJob!;
                                                  } else if (newValue ==
                                                      'Bekerja') {
                                                    showDialog(
                                                      context: context,
                                                      builder: (BuildContext
                                                          context) {
                                                        String jobDetail = '';
                                                        return AlertDialog(
                                                          title: Text(
                                                              'Masukkan Detail Pekerjaan'),
                                                          content: TextField(
                                                            onChanged: (value) {
                                                              jobDetail = value;
                                                            },
                                                            decoration:
                                                                InputDecoration(
                                                              hintText:
                                                                  'Contoh: Guru',
                                                            ),
                                                          ),
                                                          actions: <Widget>[
                                                            TextButton(
                                                              child:
                                                                  Text('Batal'),
                                                              onPressed: () {
                                                                Navigator.of(
                                                                        context)
                                                                    .pop();
                                                              },
                                                            ),
                                                            TextButton(
                                                              child: Text(
                                                                  'Simpan'),
                                                              onPressed: () {
                                                                if (jobDetail
                                                                    .trim()
                                                                    .isNotEmpty) {
                                                                  setState(() {
                                                                    selectedJob =
                                                                        jobDetail;
                                                                    pekerjaanController
                                                                            .text =
                                                                        selectedJob!;
                                                                    if (!jobItems
                                                                        .contains(
                                                                            jobDetail)) {
                                                                      jobItems.add(
                                                                          jobDetail);
                                                                    }
                                                                  });
                                                                  Navigator.of(
                                                                          context)
                                                                      .pop();
                                                                } else {
                                                                  ScaffoldMessenger.of(
                                                                          context)
                                                                      .showSnackBar(
                                                                          SnackBar(
                                                                    content: Text(
                                                                        'Detail pekerjaan tidak boleh kosong!'),
                                                                  ));
                                                                }
                                                              },
                                                            ),
                                                          ],
                                                        );
                                                      },
                                                    );
                                                  } else {
                                                    selectedJob = newValue;
                                                    pekerjaanController.text =
                                                        selectedJob!;
                                                  }
                                                });
                                              },
                                            ),
                                            SizedBox(height: 20),
                                            DropdownButtonFormField<String>(
                                              isExpanded: true,
                                              decoration: InputDecoration(
                                                prefixIcon:
                                                    const Icon(Icons.bar_chart),
                                                labelText: 'Pendapatan Sebulan',
                                                floatingLabelStyle:
                                                    const TextStyle(
                                                  color: Colors.black,
                                                ),
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                                focusedBorder:
                                                    OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  borderSide: const BorderSide(
                                                    color:
                                                        const Color(0xff30C083),
                                                    width: 2,
                                                  ),
                                                ),
                                              ),
                                              items: <String>[
                                                'Tidak Berpenghasilan',
                                                '<Rp. 1.000.000',
                                                'Rp. 1.000.000 - Rp. 3.000.000',
                                                'Rp. 3.000.000 - Rp. 6.000.000',
                                                'Rp. 6.000.000 - Rp. 10.000.000',
                                                '≥ Rp. 10.000.000',
                                              ].map<DropdownMenuItem<String>>(
                                                  (String value) {
                                                return DropdownMenuItem<String>(
                                                  value: value,
                                                  child: Text(value),
                                                );
                                              }).toList(),
                                              onChanged: (String? newValue) {
                                                setState(() {
                                                  gajiController.text =
                                                      newValue!;
                                                });
                                              },
                                            ),
                                            SizedBox(height: 20),
                                          ])),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 20),
                              Card(
                                color: Colors.white,
                                margin: EdgeInsets.only(left: 20, right: 20),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  side: BorderSide(
                                    color: Color.fromARGB(255, 120, 116, 116),
                                  ),
                                ),
                                child: ExpansionTile(
                                  title: Text(
                                    "Akun dan Kontak",
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  initiallyExpanded: _isExpanded,
                                  onExpansionChanged: (expanded) {
                                    if (!expanded &&
                                        !_formKey4.currentState!.validate()) {
                                      return;
                                    }
                                    setState(() {
                                      _isExpanded = expanded;
                                    });
                                  },
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.zero),
                                  collapsedShape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.zero),
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 20),
                                      child: Form(
                                          key: _formKey4,
                                          child: Column(children: [
                                            SizedBox(height: 5),
                                            GestureDetector(
                                                onTap: _pickImage,
                                                child: Container(
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal: 10,
                                                      vertical: 15),
                                                  decoration: BoxDecoration(
                                                      border: Border.all(
                                                          color: const Color
                                                              .fromARGB(255,
                                                              132, 130, 130)),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10)),
                                                  child: const Row(
                                                    children: [
                                                      Icon(Icons.upload_file),
                                                      SizedBox(width: 10),
                                                      Text("Upload Foto")
                                                    ],
                                                  ),
                                                )),
                                            if (_image != null)
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 20),
                                                child: Image.file(
                                                  _image!,
                                                  height: 100,
                                                  width: 100,
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                            SizedBox(height: 20),
                                            TextFormField(
                                              controller:
                                                  nomorTeleponController,
                                              decoration: InputDecoration(
                                                prefixIcon:
                                                    const Icon(Icons.call),
                                                labelText: 'Nomor WhatsApp',
                                                floatingLabelStyle:
                                                    const TextStyle(
                                                  color: Colors.black,
                                                ),
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                                focusedBorder:
                                                    OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  borderSide: const BorderSide(
                                                    color:
                                                        const Color(0xff30C083),
                                                    width: 2,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            SizedBox(height: 20),
                                            TextFormField(
                                              controller: passwordController,
                                              obscureText: !_isPasswordVisible,
                                              decoration: InputDecoration(
                                                prefixIcon:
                                                    const Icon(Icons.lock),
                                                labelText: 'Password',
                                                floatingLabelStyle:
                                                    const TextStyle(
                                                  color: Colors.black,
                                                ),
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                                focusedBorder:
                                                    OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  borderSide: const BorderSide(
                                                    color:
                                                        const Color(0xff30C083),
                                                    width: 2,
                                                  ),
                                                ),
                                                suffixIcon: IconButton(
                                                  icon: Icon(
                                                    _isPasswordVisible
                                                        ? Icons.visibility
                                                        : Icons.visibility_off,
                                                    color: _isPasswordVisible
                                                        ? Color(0xff30C083)
                                                        : null,
                                                  ),
                                                  onPressed: () {
                                                    setState(() {
                                                      _isPasswordVisible =
                                                          !_isPasswordVisible;
                                                    });
                                                  },
                                                ),
                                              ),
                                            ),
                                            SizedBox(height: 20),
                                            TextFormField(
                                              controller:
                                                  ulangiPasswordController,
                                              obscureText:
                                                  !_isConfirmPasswordVisible,
                                              decoration: InputDecoration(
                                                prefixIcon:
                                                    const Icon(Icons.lock),
                                                labelText: 'Ulangi Password',
                                                floatingLabelStyle:
                                                    const TextStyle(
                                                  color: Colors.black,
                                                ),
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                                focusedBorder:
                                                    OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  borderSide: const BorderSide(
                                                    color:
                                                        const Color(0xff30C083),
                                                    width: 2,
                                                  ),
                                                ),
                                                suffixIcon: IconButton(
                                                  icon: Icon(
                                                    _isConfirmPasswordVisible
                                                        ? Icons.visibility
                                                        : Icons.visibility_off,
                                                    color:
                                                        _isConfirmPasswordVisible
                                                            ? Color(0xff30C083)
                                                            : null,
                                                  ),
                                                  onPressed: () {
                                                    setState(() {
                                                      _isConfirmPasswordVisible =
                                                          !_isConfirmPasswordVisible;
                                                    });
                                                  },
                                                ),
                                              ),
                                            ),
                                            SizedBox(height: 20),
                                          ])),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 20),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 20),
                                child: GestureDetector(
                                  onTap: () {
                                    _submitData();
                                  },
                                  child: Container(
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      color: const Color(0xff30C083),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(15),
                                      child: Text(
                                        buttonText,
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
                              SizedBox(height: 20),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 20),
                                child: RichText(
                                  text: TextSpan(
                                    text:
                                        'Dengan mendaftar anda bersedia untuk menyetujui ',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 16,
                                    ),
                                    children: <TextSpan>[
                                      TextSpan(
                                        text: 'Syarat',
                                        style: TextStyle(
                                          color: Color(0xff30C083),
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                        recognizer: TapGestureRecognizer()
                                          ..onTap = () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      SyaratPage()),
                                            );
                                          },
                                      ),
                                      TextSpan(
                                        text: ' dan ',
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 16,
                                        ),
                                      ),
                                      TextSpan(
                                        text: 'Kebijakan Privasi',
                                        style: TextStyle(
                                          color: Color(0xff30C083),
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                        recognizer: TapGestureRecognizer()
                                          ..onTap = () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      KebijakanPrivasiPage()),
                                            );
                                          },
                                      ),
                                      TextSpan(
                                        text: ' dari kami.',
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(height: 30),
                            ],
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
