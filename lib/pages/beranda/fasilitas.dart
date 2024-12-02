import 'package:flutter/material.dart';

class FasilitasPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xff30C083),
        title: Text(
          'Fasilitas',
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
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                  child: TextField(
                    cursorColor: Color(0xff30C083),
                    decoration: InputDecoration(
                      hintText: 'Cari Fasilitas...',
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
                Text('Total Fasilitas : 10 Fasilitas'),
                SizedBox(
                  height: 30,
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
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
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Image.network(
                              'https://placehold.co/300x300.png',
                              fit: BoxFit.cover,
                              width: double.infinity,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              SizedBox(height: 10),
                              Text(
                                'Kursi',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 10),
                              Text(
                                'Jumlah : 10',
                                style: TextStyle(
                                  fontSize: 14,
                                ),
                              ),
                              Text(
                                ' Kondisi : Baik',
                                style: TextStyle(
                                  fontSize: 14,
                                ),
                              ),
                              SizedBox(height: 20),
                            ],
                          ),
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
    );
  }
}
