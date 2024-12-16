import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class LupaSandiPage extends StatefulWidget {
  @override
  State<LupaSandiPage> createState() => _LupaSandiPageState();
}

class _LupaSandiPageState extends State<LupaSandiPage> {
  final TextEditingController _nikController = TextEditingController();

  void _cekNIK() async {
    final request = await http.get(
      Uri.parse(
          'https://pexadont.agsa.site/api/warga/edit/${_nikController.text}'),
      headers: {'Content-Type': 'application/json'},
    );

    final response = jsonDecode(request.body);

    if (response["status"] == 200) {
      setState(() {});
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Data warga tidak ditemukan')),
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
      body: SingleChildScrollView(
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
                        _cekNIK();
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
                          child: const Text(
                            'Cek NIK',
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
