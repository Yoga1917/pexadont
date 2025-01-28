import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class LupaSandiPage extends StatefulWidget {
  @override
  State<LupaSandiPage> createState() => _LupaSandiPageState();
}

class _LupaSandiPageState extends State<LupaSandiPage> {
  final TextEditingController _nikController = TextEditingController();
  String? nama;
  String? whatsapp;
  bool isLoadingCek = false;
  bool isLoadingReset = false;

  void _cekNIK() async {
    setState(() {
      isLoadingCek = true;
    });

    if (_nikController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Harap isi data NIK!')),
      );
      setState(() {
        isLoadingCek = false;
      });
      return;
    }

    if (_nikController.text.length < 16) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('NIK harus 16 digit angka!')),
      );
      setState(() {
        isLoadingCek = false;
      });
      return;
    }

    if (int.tryParse(_nikController.text) == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Data NIK harus berupa angka!')),
      );
      setState(() {
        isLoadingCek = false;
      });
      return;
    }

    final request = await http.get(
      Uri.parse(
          'https://pexadont.agsa.site/api/warga/edit/${_nikController.text}'),
      headers: {'Content-Type': 'application/json'},
    );

    final response = jsonDecode(request.body);

    setState(() {
      isLoadingCek = false;
    });

    if (response["status"] == 200) {
      setState(() {
        nama = response["data"]["nama"];
        whatsapp = response["data"]["no_wa"];
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Data warga tidak ditemukan.')),
      );
    }
  }

  void _resetPassword() async {
    setState(() {
      isLoadingReset = true;
    });

    final request = await http.get(
      Uri.parse(
          'https://pexadont.agsa.site/api/password/reset?nik=${_nikController.text}'),
      headers: {'Content-Type': 'application/json'},
    );

    final response = jsonDecode(request.body);

    setState(() {
      isLoadingReset = false;
    });

    if (response["status"] == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response["data"])),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mereset password')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xff30C083),
        title: Text(
          'Lupa Password',
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
        child: LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth > 600) {
              return Column();
            } else {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    SizedBox(height: 30),
                    TextFormField(
                      controller: _nikController,
                      cursorColor: Color(0xff30C083),
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.credit_card),
                        labelText: 'NIK',
                        floatingLabelStyle:
                            const TextStyle(color: Colors.black),
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
                    SizedBox(height: 20),
                    GestureDetector(
                      onTap: () {
                        if (!isLoadingCek) {
                          _cekNIK();
                        }
                      },
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
                            isLoadingCek ? 'Cek NIK...' : 'Cek NIK',
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
                    SizedBox(height: 30),
                    if (nama != null)
                      Container(
                        alignment: Alignment.center,
                        child: Column(
                          children: [
                            const Text("Data warga ditemukan :"),
                            SizedBox(height: 10),
                            Text(
                              nama!,
                              style: const TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 5),
                            Text("Whatsapp : ${whatsapp}"),
                            SizedBox(height: 20),
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 30),
                              child: Text(
                                  "Password baru akan dikirimkan ke nomor whatsapp diatas, klik konfirmasi untuk melanjutkan.",
                                  textAlign: TextAlign.center),
                            ),
                            SizedBox(height: 15),
                            GestureDetector(
                              onTap: () {
                                if (!isLoadingReset) {
                                  _resetPassword();
                                }
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
                                    isLoadingReset ? 'Merubah...' : 'Konfirmasi',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w900,
                                      fontSize: 18,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                  ],
                ),
              );
            }
          },
        ),
      ),
    );
  }
}
