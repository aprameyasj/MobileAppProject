import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _formatBookingNumber(String orderId) {
    // Extract the timestamp from the orderId
    final timestamp = orderId.split('_').last;
    // Format it as HH-XXXXXX where HH is Heavenly Havens and XXXXXX is last 6 digits
    return 'HH-${timestamp.substring(timestamp.length - 6)}';
  }

  String _formatDate(Timestamp timestamp) {
    final date = timestamp.toDate();
    return DateFormat('dd MMM yyyy, hh:mm a').format(date);
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final email = user?.email ?? 'Not available';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.orange,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'User Info',
                style: TextStyle(
                  color: Colors.orange,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'Email: $email',
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Previous Bookings',
                style: TextStyle(
                  color: Colors.orange,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('bookings')
                    .where('userId', isEqualTo: user?.uid)
                    .orderBy('createdAt', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator(color: Colors.orange));
                  }
                  if (snapshot.hasError) {
                    print('Error loading bookings: ${snapshot.error}');
                    return Text(
                      'Error loading bookings: ${snapshot.error}',
                      style: const TextStyle(color: Colors.red, fontSize: 16),
                    );
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Text(
                      'No previous bookings',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    );
                  }

                  final bookings = snapshot.data!.docs;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: bookings.map((doc) {
                      final bookingDetails = doc.data() as Map<String, dynamic>;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  'Booking Number: ${_formatBookingNumber(doc.id)}',
                                  style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  '(${_formatDate(bookingDetails['createdAt'])})',
                                  style: const TextStyle(color: Colors.grey, fontSize: 14),
                                ),
                              ],
                            ),
                            Text(
                              'City: ${bookingDetails['city']}',
                              style: const TextStyle(color: Colors.white, fontSize: 16),
                            ),
                            Text(
                              'Check-in Date: ${bookingDetails['checkInDate']}',
                              style: const TextStyle(color: Colors.white, fontSize: 16),
                            ),
                            Text(
                              'Check-out Date: ${bookingDetails['checkOutDate']}',
                              style: const TextStyle(color: Colors.white, fontSize: 16),
                            ),
                            Text(
                              'Number of Rooms: ${bookingDetails['numberOfRooms']}',
                              style: const TextStyle(color: Colors.white, fontSize: 16),
                            ),
                            Text(
                              'Total Cost: ₹${bookingDetails['totalCost'].toStringAsFixed(2)}',
                              style: const TextStyle(color: Colors.white, fontSize: 16),
                            ),
                            Text(
                              'Payment Method: ${bookingDetails['paymentMethod']}',
                              style: const TextStyle(color: Colors.white, fontSize: 16),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
