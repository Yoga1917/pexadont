import 'dart:convert';
import 'dart:io';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:pexadont/pages/mulai/login.dart';
import 'package:pexadont/pages/mulai/start_page.dart';
import 'package:pexadont/pages/pengaturan/kebijakan_privasi.dart';
import 'package:pexadont/pages/pengaturan/syarat.dart';

class DaftarPage extends StatefulWidget {
  @override
  _DaftarPageState createState() => _DaftarPageState();
}

class _DaftarPageState extends State<DaftarPage> {
  String buttonText = 'Daftar';
  final TextEditingController nikController = TextEditingController();
  final TextEditingController namaController = TextEditingController();
  final TextEditingController nomorRumahController = TextEditingController();
  final TextEditingController nomorTeleponController = TextEditingController();
  final TextEditingController tanggalLahirController = TextEditingController();
  final TextEditingController jenisKelaminController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController ulangiPasswordController =
      TextEditingController();

  File? _image;

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  void _submitData() {
    setState(() {
      buttonText = 'Mendaftar...';
    });

    if ((nikController.text == "") ||
        (namaController.text == "") ||
        (nomorRumahController.text == "") ||
        (nomorTeleponController.text == "") ||
        (tanggalLahirController.text == "") ||
        (jenisKelaminController.text == "") ||
        (passwordController.text == "") ||
        (ulangiPasswordController.text == "") ||
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

    if (passwordController.text != ulangiPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Konfirmasi Password Tidak Cocok!')),
      );

      setState(() {
        buttonText = 'Daftar';
      });
      return;
    }

    _register().whenComplete(() {
      setState(() {
        buttonText = 'Daftar';
      });
    });
  }

  Future<void> _register() async {
    try {
      var request = http.MultipartRequest(
          'POST', Uri.parse('https://pexadont.agsa.site/api/warga/simpan'));
      request.fields['nik'] = nikController.text;
      request.fields['nama'] = namaController.text;
      request.fields['tgl_lahir'] = tanggalLahirController.text;
      request.fields['jenis_kelamin'] = jenisKelaminController.text;
      request.fields['no_rumah'] = nomorRumahController.text;
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
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              child: TextFormField(
                                controller: nikController,
                                cursorColor: Color(0xff30C083),
                                decoration: InputDecoration(
                                  prefixIcon: const Icon(Icons.credit_card),
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
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              child: TextFormField(
                                controller: namaController,
                                cursorColor: Color(0xff30C083),
                                decoration: InputDecoration(
                                  prefixIcon: const Icon(Icons.account_box),
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
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              child: TextFormField(
                                controller: nomorRumahController,
                                cursorColor: Color(0xff30C083),
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
                            SizedBox(height: 20),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              child: TextFormField(
                                controller: nomorTeleponController,
                                cursorColor: Color(0xff30C083),
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
                            SizedBox(height: 20),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              child: TextFormField(
                                controller: tanggalLahirController,
                                readOnly: true,
                                onTap: () async {
                                  DateTime? pickedDate = await showDatePicker(
                                    context: context,
                                    initialDate: DateTime.now(),
                                    firstDate: DateTime(1900),
                                    lastDate: DateTime(2100),
                                    builder:
                                        (BuildContext context, Widget? child) {
                                      return Theme(
                                        data: ThemeData.light().copyWith(
                                          primaryColor: Color(0xff30C083),
                                          colorScheme: ColorScheme.light(
                                              primary: Color(0xff30C083)),
                                          buttonTheme: ButtonThemeData(
                                              textTheme:
                                                  ButtonTextTheme.primary),
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
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
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
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              child: GestureDetector(
                                  onTap: _pickImage,
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 15),
                                    decoration: BoxDecoration(
                                        border: Border.all(
                                            color: const Color.fromARGB(
                                                255, 132, 130, 130)),
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    child: const Row(
                                      children: [
                                        Icon(Icons.upload_file),
                                        SizedBox(width: 10),
                                        Text("Upload Foto")
                                      ],
                                    ),
                                  )),
                            ),
                            if (_image != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 20),
                                child: Image.file(
                                  _image!,
                                  height: 100,
                                  width: 100,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            SizedBox(height: 20),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              child: TextFormField(
                                controller: passwordController,
                                cursorColor: Color(0xff30C083),
                                obscureText: !_isPasswordVisible,
                                decoration: InputDecoration(
                                  prefixIcon: const Icon(Icons.lock),
                                  labelText: 'Password',
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
                            ),
                            SizedBox(height: 20),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              child: TextFormField(
                                controller: ulangiPasswordController,
                                cursorColor: Color(0xff30C083),
                                obscureText: !_isConfirmPasswordVisible,
                                decoration: InputDecoration(
                                  prefixIcon: const Icon(Icons.lock),
                                  labelText: 'Ulangi Password',
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
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _isConfirmPasswordVisible
                                          ? Icons.visibility
                                          : Icons.visibility_off,
                                      color: _isConfirmPasswordVisible
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
