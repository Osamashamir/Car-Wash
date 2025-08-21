import 'package:car_wash/screen/feedback_screen.dart';
import 'package:car_wash/screen/offers_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'profile_screen.dart';

class BookServiceScreen extends StatefulWidget {
  const BookServiceScreen({super.key});

  @override
  State<BookServiceScreen> createState() => _BookServiceScreenState();
}

class _BookServiceScreenState extends State<BookServiceScreen> {
  String? selectedService;
  DateTime? selectedDate;
  TimeOfDay? selectedTime;

  int numberOfCars = 1; // default
  List<TextEditingController> carControllers = [TextEditingController()];

  final TextEditingController carController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController locationController = TextEditingController();

  List<String> serviceList = [];
  bool isLoadingServices = true;
  String userName = ""; // 🔹 Dynamic name store karne ke liye

  @override
  void initState() {
    super.initState();
    loadServicesFromFirestore();
    fetchUserName(); // 🔹 Naam laane ka function
  }

  Future<void> fetchUserName() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        if (doc.exists) {
          String firstName = doc.data()?['firstName'] ?? '';
          String lastName = doc.data()?['lastName'] ?? '';
          setState(() {
            userName = "$firstName $lastName".trim();
          });
        }
      }
    } catch (e) {
      print("Error fetching user name: $e");
    }
  }

  Future<void> loadServicesFromFirestore() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('services')
          .get();
      setState(() {
        serviceList = snapshot.docs.map((doc) {
          final data = doc.data();
          return '${data['name']} - QAR ${data['price']}';
        }).toList();
        isLoadingServices = false;
      });
    } catch (e) {
      print('Error loading services: $e');
      setState(() => isLoadingServices = false);
    }
  }

  Future<void> getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Location services are disabled.')),
      );
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location permissions are denied.')),
        );
        return;
      }
    }

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    List<Placemark> placemarks = await placemarkFromCoordinates(
      position.latitude,
      position.longitude,
    );
    Placemark place = placemarks[0];

    String fullAddress =
        '${place.name}, ${place.locality}, ${place.administrativeArea}, ${place.country}';

    setState(() {
      locationController.text = fullAddress;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Book a Service"),
        backgroundColor: const Color(0xFF1595D2),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: CircleAvatar(
                radius: 50,
                backgroundImage: AssetImage('assets/image/logo.JPG'),
              ),
            ),
            const SizedBox(height: 10),
            Center(
              child: Text(
                userName.isNotEmpty ? userName : "Loading...",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 30),
            const Text(
              "Select Service Type",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            isLoadingServices
                ? const Center(child: CircularProgressIndicator())
                : DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                    value: selectedService,
                    items: serviceList.map((service) {
                      return DropdownMenuItem(
                        value: service,
                        child: Text(service),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedService = value;
                      });
                    },
                  ),
            const SizedBox(height: 20),
            const Text(
              "Number of Cars",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<int>(
              decoration: const InputDecoration(border: OutlineInputBorder()),
              value: numberOfCars,
              items: List.generate(10, (index) => index + 1).map((num) {
                return DropdownMenuItem(
                  value: num,
                  child: Text(num.toString()),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  numberOfCars = value!;
                  carControllers = List.generate(
                    numberOfCars,
                    (index) => TextEditingController(),
                  );
                });
              },
            ),
            const SizedBox(height: 20),
            Column(
              children: List.generate(numberOfCars, (index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: TextField(
                    controller: carControllers[index],
                    decoration: InputDecoration(
                      labelText: 'Car ${index + 1} Details',
                      border: const OutlineInputBorder(),
                    ),
                  ),
                );
              }),
            ),
            InkWell(
              onTap: () async {
                DateTime? date = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime(2100),
                );
                if (date != null) {
                  setState(() {
                    selectedDate = date;
                  });
                }
              },
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Select Date',
                  border: OutlineInputBorder(),
                ),
                child: Text(
                  selectedDate != null
                      ? "${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}"
                      : 'Choose a date',
                ),
              ),
            ),
            const SizedBox(height: 20),
            InkWell(
              onTap: () async {
                TimeOfDay? time = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.now(),
                );
                if (time != null) {
                  setState(() {
                    selectedTime = time;
                  });
                }
              },
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Select Time',
                  border: OutlineInputBorder(),
                ),
                child: Text(
                  selectedTime != null
                      ? selectedTime!.format(context)
                      : 'Choose time',
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: addressController,
              decoration: const InputDecoration(
                labelText: 'Address',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: locationController,
              readOnly: true,
              decoration: InputDecoration(
                labelText: 'Current Location',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.my_location),
                  onPressed: () {
                    getCurrentLocation();
                  },
                ),
              ),
            ),
            const SizedBox(height: 30),
            Center(
              child: ElevatedButton(
                onPressed: () async {
                  if (selectedService == null ||
                      selectedDate == null ||
                      selectedTime == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please fill all required fields'),
                      ),
                    );
                    return;
                  }

                  try {
                    final user = FirebaseAuth.instance.currentUser;
                    if (user == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('User not logged in')),
                      );
                      return;
                    }

                    final orderData = {
                      'userId': user.uid,
                      'service': selectedService,
                      'numberOfCars': numberOfCars,
                      'cars': carControllers.map((c) => c.text).toList(),
                      'date': selectedDate!.toIso8601String(),
                      'time': selectedTime!.format(context),
                      'address': addressController.text,
                      'location': locationController.text,
                      'status': 'pending',
                      'createdAt': FieldValue.serverTimestamp(),
                    };

                    await FirebaseFirestore.instance
                        .collection('orders')
                        .add(orderData);

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Booking submitted successfully!'),
                      ),
                    );

                    setState(() {
                      selectedService = null;
                      selectedDate = null;
                      selectedTime = null;
                      numberOfCars = 1;
                      carControllers = [TextEditingController()];
                      addressController.clear();
                      locationController.clear();
                    });
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error submitting booking: $e')),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1595D2),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 60,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Book Now',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Color(0xFF1595D2),
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        currentIndex: 1,
        onTap: (index) {
          if (index == 0) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ProfileScreen()),
            );
          } else if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const OffersScreen()),
            );
          } else if (index == 3) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const FeedbackScreen()),
            );
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          BottomNavigationBarItem(
            icon: Icon(Icons.local_car_wash),
            label: 'Book',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.card_giftcard),
            label: 'Offer',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.feedback),
            label: 'Feedback',
          ),
        ],
      ),
    );
  }
}
