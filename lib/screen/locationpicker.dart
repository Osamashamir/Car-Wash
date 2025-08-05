import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class LocationPickerScreen extends StatefulWidget {
  const LocationPickerScreen({super.key});

  @override
  State<LocationPickerScreen> createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends State<LocationPickerScreen> {
  LatLng selectedLocation = LatLng(25.276987, 55.296249); // Default: Dubai

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Pick Location"),
        backgroundColor: const Color(0xFF1595D2),
      ),
      body: FlutterMap(
        options: MapOptions(
          initialCenter: selectedLocation,
          initialZoom: 13.0,
          onTap: (tapPosition, point) {
            setState(() {
              selectedLocation = point;
            });
          },
        ),
        children: [
          TileLayer(
            urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
            userAgentPackageName: 'com.example.app',
          ),
          MarkerLayer(
            markers: [
              Marker(
                width: 40,
                height: 40,
                point: selectedLocation,
                child: const Icon(
                  Icons.location_pin,
                  color: Colors.red,
                  size: 40,
                ),
              ),
            ],
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(12),
        child: ElevatedButton(
          onPressed: () {
            Navigator.pop(context, selectedLocation);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1595D2),
          ),
          child: const Text(
            "Confirm Location",
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }
}
