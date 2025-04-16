import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PilihLokasi extends StatefulWidget {
  @override
  _PilihLokasiState createState() => _PilihLokasiState();
}

class _PilihLokasiState extends State<PilihLokasi> {
  LatLng selectedLocation = LatLng(-6.9442340, 109.6523429); // Default: Jakarta
  final MapController _mapController = MapController();
  final TextEditingController _searchController = TextEditingController();

  // Fungsi untuk mencari lokasi menggunakan OpenStreetMap Nominatim API
  Future<List<LocationSearchResult>> searchLocation(String query) async {
    final url = Uri.parse(
        'https://nominatim.openstreetmap.org/search?format=json&q=$query');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data
          .map((item) => LocationSearchResult(
                name: item['display_name'],
                latitude: double.parse(item['lat']),
                longitude: double.parse(item['lon']),
              ))
          .toList();
    } else {
      throw Exception('Gagal memuat data lokasi');
    }
  }

  Future<void> getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('GPS tidak aktif. Silakan aktifkan GPS.')),
      );
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Izin lokasi ditolak.')),
        );
        return;
      }
    }

    try {
      Position position = await Geolocator.getCurrentPosition();
      
      setState(() {
        selectedLocation = LatLng(position.latitude, position.longitude);
        _mapController.move(selectedLocation, 15);
      });
    } catch (e) {
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mendapatkan lokasi saat ini.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xff30C083),
        title: Text(
          'Pilih Lokasi',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(20),
            child: TypeAheadField<LocationSearchResult>(
              controller: _searchController,
              suggestionsCallback: (pattern) async {
                return await searchLocation(pattern);
              },
              itemBuilder: (context, suggestion) {
                return ListTile(
                  title: Text(suggestion.name),
                );
              },
              onSelected: (suggestion) {
                setState(() {
                  selectedLocation =
                      LatLng(suggestion.latitude, suggestion.longitude);
                  _mapController.move(selectedLocation, 15);
                });
              },
              builder: (context, controller, focusNode) {
                return TextField(
                  controller: controller,
                  focusNode: focusNode,
                  decoration: InputDecoration(
                    hintText: 'Cari provinsi, kota, atau desa...',
                    border: OutlineInputBorder(),
                  ),
                );
              },
            ),
          ),
          ElevatedButton(
            onPressed: getCurrentLocation,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              shadowColor: Colors.black26,
              elevation: 5,
              side: BorderSide(color: Color(0xff30C083), width: 1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: Text(
              "Pilih Lokasi Saya",
              style: TextStyle(
                color: Color(0xff30C083),
              ),
            ),
          ),
          SizedBox(height: 20),
          Expanded(
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: selectedLocation,
                initialZoom: 15,
                onTap: (tapPosition, point) {
                  setState(() {
                    selectedLocation = point;
                  });
                },
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                  subdomains: ['a', 'b', 'c'],
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: selectedLocation,
                      width: 50,
                      height: 50,
                      child: Icon(
                        Icons.location_pin,
                        color: Color(0xff30C083),
                        size: 40,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.white,
        child: Icon(
          Icons.check,
          color: Color(0xff30C083),
        ),
        onPressed: () {
          Navigator.pop(context, selectedLocation);
        },
      ),
    );
  }
}

// Model untuk hasil pencarian lokasi
class LocationSearchResult {
  final String name;
  final double latitude;
  final double longitude;

  LocationSearchResult({
    required this.name,
    required this.latitude,
    required this.longitude,
  });
}
