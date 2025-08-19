import 'package:flutter/material.dart';
import 'payment_method_screen.dart';

class PaymentsScreen extends StatefulWidget {
  final String city;
  final String fullName;
  final String phone;
  final String numberOfRooms;
  final String checkInDate;
  final String checkOutDate;

  const PaymentsScreen({
    super.key,
    required this.city,
    required this.fullName,
    required this.phone,
    required this.numberOfRooms,
    required this.checkInDate,
    required this.checkOutDate,
  });

  @override
  _PaymentsScreenState createState() => _PaymentsScreenState();
}

class _PaymentsScreenState extends State<PaymentsScreen> {
  int _calculateDays() {
    try {
      final checkIn = DateTime.parse(widget.checkInDate);
      final checkOut = DateTime.parse(widget.checkOutDate);
      return checkOut.difference(checkIn).inDays;
    } catch (e) {
      print('Error calculating days: $e');
      return 0;
    }
  }

  double _calculateTotalCost() {
    final days = _calculateDays();
    final rooms = int.tryParse(widget.numberOfRooms) ?? 0;
    const costPerRoomPerDay = 3000;
    return rooms * days * costPerRoomPerDay.toDouble();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payments'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.orange,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Booking Details',
              style: TextStyle(
                color: Colors.orange,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'City: ${widget.city}',
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              'Guest Name: ${widget.fullName}',
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              'Phone: ${widget.phone}',
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              'Number of Rooms: ${widget.numberOfRooms}',
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              'Check-in Date: ${widget.checkInDate}',
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              'Check-out Date: ${widget.checkOutDate}',
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
            const SizedBox(height: 16),
            Text(
              'Total Cost: ₹${_calculateTotalCost().toStringAsFixed(2)}',
              style: const TextStyle(
                color: Colors.orange,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 48),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PaymentMethodScreen(
                      city: widget.city,
                      fullName: widget.fullName,
                      phone: widget.phone,
                      numberOfRooms: widget.numberOfRooms,
                      checkInDate: widget.checkInDate,
                      checkOutDate: widget.checkOutDate,
                      totalCost: _calculateTotalCost(),
                    ),
                  ),
                );
              },
              child: const Text(
                'Pay Now',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}