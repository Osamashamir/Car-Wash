import 'dart:io';
import 'dart:convert';
import 'package:car_wash/screen/locationpicker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:location/location.dart' as loc;
import 'package:geocoding/geocoding.dart'; // Keep this if needed for reverse geocoding

class AddCompanyScreen extends StatefulWidget {
  const AddCompanyScreen({super.key});

  @override
  State<AddCompanyScreen> createState() => _AddCompanyScreenState();
}

class _AddCompanyScreenState extends State<AddCompanyScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController ownerController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController locationController = TextEditingController();

  File? companyLogo;
  bool isLoading = false;

  Future<void> pickLogoImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        companyLogo = File(picked.path);
      });
    }
  }

  Future<String?> uploadImage(File file) async {
    try {
      const cloudName = 'dce7gwpgn';
      const uploadPreset = 'ml_default';
      final uri = Uri.parse(
        'https://api.cloudinary.com/v1_1/$cloudName/image/upload',
      );

      final request = http.MultipartRequest('POST', uri)
        ..fields['upload_preset'] = uploadPreset
        ..files.add(await http.MultipartFile.fromPath('file', file.path));

      final response = await request.send();
      final res = await http.Response.fromStream(response);

      if (response.statusCode == 200) {
        final data = json.decode(res.body);
        return data['secure_url'];
      } else {
        print("Cloudinary upload failed: ${res.body}");
        return null;
      }
    } catch (e) {
      print("Cloudinary upload error: $e");
      return null;
    }
  }

  Future<void> registerCompany() async {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Email and Password are required")),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: emailController.text.trim(),
            password: passwordController.text.trim(),
          );

      String? imageUrl;
      if (companyLogo != null) {
        imageUrl = await uploadImage(companyLogo!);
      }

      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .set({
            'uid': userCredential.user!.uid,
            'name': nameController.text.trim(),
            'email': emailController.text.trim(),
            'phone': phoneController.text.trim(),
            'owner': ownerController.text.trim(),
            'address': addressController.text.trim(),
            'location': locationController.text.trim(),
            'logoUrl': imageUrl ?? '',
            'role': 'Company',
            'createdAt': Timestamp.now(),
          });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Company Registered Successfully!")),
      );

      nameController.clear();
      emailController.clear();
      passwordController.clear();
      phoneController.clear();
      ownerController.clear();
      addressController.clear();
      locationController.clear();
      setState(() {
        companyLogo = null;
      });
    } catch (e) {
      print('Registration failed: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Failed: ${e.toString()}")));
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
        title: const Text("Add Company"),
        backgroundColor: const Color(0xFF1595D2),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 50,
              backgroundImage: AssetImage('assets/image/logo.JPG'),
            ),
            const SizedBox(height: 10),
            const Text(
              "Admin - Muhammad Osama",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),

            _buildTextField("Company Name", nameController),
            _buildTextField("Company Email", emailController),
            _buildTextField("Password", passwordController, obscure: true),
            _buildTextField("Phone Number", phoneController),
            _buildTextField("Owner Name", ownerController),
            _buildTextField("Address", addressController),

            ElevatedButton(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LocationPickerScreen(),
                  ),
                );

                if (result != null) {
                  setState(() {
                    locationController.text =
                        '${result.latitude}, ${result.longitude}';
                  });
                }
              },
              child: const Text("Pick Location on Map"),
            ),

            const SizedBox(height: 20),
            GestureDetector(
              onTap: pickLogoImage,
              child: Container(
                height: 150,
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.grey[100],
                ),
                child: companyLogo == null
                    ? const Center(child: Text("Tap to upload company logo"))
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.file(companyLogo!, fit: BoxFit.cover),
                      ),
              ),
            ),
            const SizedBox(height: 30),

            isLoading
                ? const CircularProgressIndicator()
                : SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: registerCompany,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1595D2),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        "Register",
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    bool obscure = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}

class MapLocationPickerScreen extends StatefulWidget {
  const MapLocationPickerScreen({super.key});

  @override
  State<MapLocationPickerScreen> createState() =>
      _MapLocationPickerScreenState();
}

class _MapLocationPickerScreenState extends State<MapLocationPickerScreen> {
  GoogleMapController? mapController;
  LatLng? selectedLatLng;
  String selectedAddress = '';
  LatLng initialPosition = const LatLng(25.276987, 55.296249);

  @override
  void initState() {
    super.initState();
    getUserLocation();
  }

  Future<void> getUserLocation() async {
    loc.Location location = loc.Location();

    bool _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) return;
    }

    loc.PermissionStatus _permissionGranted = await location.hasPermission();
    if (_permissionGranted == loc.PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != loc.PermissionStatus.granted) return;
    }

    final userLocation = await location.getLocation();
    final TextEditingController locationController = TextEditingController();

    setState(() {
      locationController.text =
          '${userLocation.latitude}, ${userLocation.longitude}';
    });
  }

  Future<void> _onMapTap(LatLng latLng) async {
    setState(() {
      selectedLatLng = latLng;
    });

    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        latLng.latitude,
        latLng.longitude,
      );
      final place = placemarks.first;
      final address =
          "${place.name}, ${place.locality}, ${place.administrativeArea}, ${place.country}";
      setState(() {
        selectedAddress = address;
      });
    } catch (e) {
      print('Geocoding failed: $e');
      setState(() {
        selectedAddress = "Unable to get address.";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Pick Location")),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: initialPosition,
              zoom: 14,
            ),
            onMapCreated: (controller) => mapController = controller,
            onTap: _onMapTap,
            markers: selectedLatLng != null
                ? {
                    Marker(
                      markerId: const MarkerId('selected'),
                      position: selectedLatLng!,
                    ),
                  }
                : {},
          ),
          if (selectedAddress.isNotEmpty)
            Positioned(
              bottom: 80,
              left: 10,
              right: 10,
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(
                    selectedAddress,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ),
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: ElevatedButton(
              onPressed: selectedAddress.isNotEmpty
                  ? () {
                      Navigator.pop(context, selectedAddress);
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
                backgroundColor: const Color(0xFF1595D2),
              ),
              child: const Text("Select This Location"),
            ),
          ),
        ],
      ),
    );
  }
}
