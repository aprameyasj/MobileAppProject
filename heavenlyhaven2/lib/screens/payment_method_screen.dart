import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'home_page.dart';

class PaymentMethodScreen extends StatefulWidget {
  final String city;
  final String fullName;
  final String phone;
  final String numberOfRooms;
  final String checkInDate;
  final String checkOutDate;
  final double totalCost;

  const PaymentMethodScreen({
    super.key,
    required this.city,
    required this.fullName,
    required this.phone,
    required this.numberOfRooms,
    required this.checkInDate,
    required this.checkOutDate,
    required this.totalCost,
  });

  @override
  _PaymentMethodScreenState createState() => _PaymentMethodScreenState();
}

class _PaymentMethodScreenState extends State<PaymentMethodScreen> {
  bool _isLoading = false;
  String? _selectedPaymentMethod;
  final List<String> _paymentMethods = ['Credit/Debit Card', 'UPI', 'Net Banking', 'Wallet'];
  final TextEditingController _cardNumberController = TextEditingController();
  final TextEditingController _expiryController = TextEditingController();
  final TextEditingController _cvvController = TextEditingController();
  final TextEditingController _upiIdController = TextEditingController();
  String? _selectedBank;
  String? _selectedWallet;
  final List<String> _banks = ['HDFC Bank', 'ICICI Bank', 'SBI', 'Axis Bank'];
  final List<String> _wallets = ['Paytm', 'PhonePe', 'Google Pay', 'Amazon Pay'];

  @override
  void dispose() {
    _cardNumberController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    _upiIdController.dispose();
    super.dispose();
  }

  Future<void> _processPayment() async {
    setState(() {
      _isLoading = true;
    });

    if (widget.totalCost <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid booking amount')),
      );
      setState(() {
        _isLoading = false;
      });
      return;
    }

    if (_selectedPaymentMethod == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a payment method')),
      );
      setState(() {
        _isLoading = false;
      });
      return;
    }

    // Validate inputs based on payment method
    if (_selectedPaymentMethod == 'Credit/Debit Card') {
      if (_cardNumberController.text.isEmpty ||
          _expiryController.text.isEmpty ||
          _cvvController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter all card details')),
        );
        setState(() {
          _isLoading = false;
        });
        return;
      }
    } else if (_selectedPaymentMethod == 'UPI') {
      if (_upiIdController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter UPI ID')),
        );
        setState(() {
          _isLoading = false;
        });
        return;
      }
    } else if (_selectedPaymentMethod == 'Net Banking' && _selectedBank == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a bank')),
      );
      setState(() {
        _isLoading = false;
      });
      return;
    } else if (_selectedPaymentMethod == 'Wallet' && _selectedWallet == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a wallet')),
      );
      setState(() {
        _isLoading = false;
      });
      return;
    }

    // Simulate payment (100% success rate)
    final orderId = 'mock_order_${DateTime.now().millisecondsSinceEpoch}';
    await _verifyPayment(orderId);
  }

  Future<void> _verifyPayment(String orderId) async {
    print('Payment Successful: $orderId');
    try {
      // Get current user's email
      final userEmail = FirebaseAuth.instance.currentUser?.email;
      if (userEmail == null) {
        throw Exception('User email not found');
      }

      await FirebaseFirestore.instance.collection('bookings').doc(orderId).set({
        'userId': FirebaseAuth.instance.currentUser?.uid,
        'email': userEmail,  // Add user's email
        'city': widget.city,
        'fullName': widget.fullName,
        'phone': widget.phone,
        'numberOfRooms': int.tryParse(widget.numberOfRooms) ?? 0,
        'checkInDate': widget.checkInDate,
        'checkOutDate': widget.checkOutDate,
        'totalCost': widget.totalCost,
        'orderId': orderId,
        'paymentMethod': _selectedPaymentMethod,
        'createdAt': FieldValue.serverTimestamp(),
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Booking Confirmed')),
      );
      // Redirect to HomePage and clear the navigation stack
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => HomePage(onLogout: () => FirebaseAuth.instance.signOut()),
        ),
        (route) => false, // Remove all previous routes
      );
    } catch (error) {
      print('Firestore Error: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save booking: $error')),
      );
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Payment Method'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.orange,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select Payment Method',
              style: TextStyle(
                color: Colors.orange,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                filled: true,
                fillColor: Colors.grey[900],
                labelText: 'Payment Method',
                labelStyle: const TextStyle(color: Colors.orange),
              ),
              value: _selectedPaymentMethod,
              dropdownColor: Colors.grey[800], // Darker background for dropdown menu
              style: const TextStyle(color: Colors.white, fontSize: 16), // White text for visibility
              items: _paymentMethods.map((method) {
                return DropdownMenuItem<String>(
                  value: method,
                  child: Text(
                    method,
                    style: const TextStyle(
                      color: Colors.white, // Ensure dropdown items are white
                      fontSize: 16,
                    ),
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedPaymentMethod = value;
                  // Clear previous inputs
                  _cardNumberController.clear();
                  _expiryController.clear();
                  _cvvController.clear();
                  _upiIdController.clear();
                  _selectedBank = null;
                  _selectedWallet = null;
                });
              },
            ),
            const SizedBox(height: 16),
            if (_selectedPaymentMethod == 'Credit/Debit Card') ...[
              TextFormField(
                controller: _cardNumberController,
                decoration: InputDecoration(
                  labelText: 'Card Number',
                  border: const OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.grey[900],
                  labelStyle: const TextStyle(color: Colors.orange),
                ),
                style: const TextStyle(color: Colors.white),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _expiryController,
                      decoration: InputDecoration(
                        labelText: 'Expiry (MM/YY)',
                        border: const OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.grey[900],
                        labelStyle: const TextStyle(color: Colors.orange),
                      ),
                      style: const TextStyle(color: Colors.white),
                      keyboardType: TextInputType.datetime,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _cvvController,
                      decoration: InputDecoration(
                        labelText: 'CVV',
                        border: const OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.grey[900],
                        labelStyle: const TextStyle(color: Colors.orange),
                      ),
                      style: const TextStyle(color: Colors.white),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
            ] else if (_selectedPaymentMethod == 'UPI') ...[
              TextFormField(
                controller: _upiIdController,
                decoration: InputDecoration(
                  labelText: 'UPI ID (e.g., user@upi)',
                  border: const OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.grey[900],
                  labelStyle: const TextStyle(color: Colors.orange),
                ),
                style: const TextStyle(color: Colors.white),
                keyboardType: TextInputType.emailAddress,
              ),
            ] else if (_selectedPaymentMethod == 'Net Banking') ...[
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.grey[900],
                  labelText: 'Select Bank',
                  labelStyle: const TextStyle(color: Colors.orange),
                ),
                value: _selectedBank,
                dropdownColor: Colors.grey[800], // Darker background for dropdown menu
                style: const TextStyle(color: Colors.white, fontSize: 16), // White text for visibility
                items: _banks.map((bank) {
                  return DropdownMenuItem<String>(
                    value: bank,
                    child: Text(
                      bank,
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedBank = value;
                  });
                },
              ),
            ] else if (_selectedPaymentMethod == 'Wallet') ...[
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.grey[900],
                  labelText: 'Select Wallet',
                  labelStyle: const TextStyle(color: Colors.orange),
                ),
                value: _selectedWallet,
                dropdownColor: Colors.grey[800], // Darker background for dropdown menu
                style: const TextStyle(color: Colors.white, fontSize: 16), // White text for visibility
                items: _wallets.map((wallet) {
                  return DropdownMenuItem<String>(
                    value: wallet,
                    child: Text(
                      wallet,
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedWallet = value;
                  });
                },
              ),
            ],
            const SizedBox(height: 24),
            _isLoading
                ? const Center(child: CircularProgressIndicator(color: Colors.orange))
                : ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 48),
                    ),
                    onPressed: _processPayment,
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