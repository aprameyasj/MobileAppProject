import 'package:flutter/material.dart';
import 'payments.dart';

class BookingsScreen extends StatefulWidget {
  const BookingsScreen({super.key});

  @override
  _BookingsScreenState createState() => _BookingsScreenState();
}

class _BookingsScreenState extends State<BookingsScreen> {
  String? _selectedCity;
  final List<String> _cities = ['Bangalore', 'Delhi', 'Mumbai', 'Chennai'];
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _numberOfRoomsController = TextEditingController();
  final TextEditingController _checkInController = TextEditingController();
  final TextEditingController _checkOutController = TextEditingController();

  DateTime? _selectedCheckInDate;

  Future<void> _selectCheckInDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2026),
    );
    if (picked != null) {
      setState(() {
        _selectedCheckInDate = picked;
        _checkInController.text = picked.toString().split(' ')[0]; // Format as YYYY-MM-DD
        // Clear check-out date if it's before or equal to new check-in date
        if (_checkOutController.text.isNotEmpty) {
          DateTime checkOut = DateTime.parse(_checkOutController.text);
          if (!checkOut.isAfter(_selectedCheckInDate!)) {
            _checkOutController.clear();
          }
        }
      });
    }
  }

  Future<void> _selectCheckOutDate(BuildContext context) async {
    if (_selectedCheckInDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select check-in date first')),
      );
      return;
    }

    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedCheckInDate!.add(const Duration(days: 1)),
      firstDate: _selectedCheckInDate!.add(const Duration(days: 1)),
      lastDate: DateTime(2026),
    );
    if (picked != null) {
      setState(() {
        _checkOutController.text = picked.toString().split(' ')[0]; // Format as YYYY-MM-DD
      });
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _numberOfRoomsController.dispose();
    _checkInController.dispose();
    _checkOutController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reservation Form'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.orange,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                ),
                value: _selectedCity,
                items: _cities.map((String city) {
                  return DropdownMenuItem<String>(
                    value: city,
                    child: Text(city),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedCity = newValue;
                  });
                },
                hint: const Text('Choose a city'),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _fullNameController,
                decoration: const InputDecoration(
                  labelText: 'Guest Name',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your phone number';
                  }
                  if (value.length != 10) {
                    return 'Phone number must be exactly 10 digits';
                  }
                  if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
                    return 'Phone number should only contain digits';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _numberOfRoomsController,
                decoration: const InputDecoration(
                  labelText: 'Number of Rooms',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _checkInController,
                decoration: const InputDecoration(
                  labelText: 'Check-in Date',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                ),
                readOnly: true,
                onTap: () => _selectCheckInDate(context),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select check-in date';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _checkOutController,
                decoration: const InputDecoration(
                  labelText: 'Check-out Date',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                ),
                readOnly: true,
                onTap: () => _selectCheckOutDate(context),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select check-out date';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PaymentsScreen(
                          city: _selectedCity ?? 'Not selected',
                          fullName: _fullNameController.text,
                          phone: _phoneController.text,
                          numberOfRooms: _numberOfRoomsController.text,
                          checkInDate: _checkInController.text,
                          checkOutDate: _checkOutController.text,
                        ),
                      ),
                    );
                  }
                },
                child: const Text(
                  'Proceed to Payment',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}