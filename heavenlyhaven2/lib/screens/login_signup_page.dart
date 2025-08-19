import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';

class LoginSignupPage extends StatefulWidget {
  final VoidCallback onLogin;

  const LoginSignupPage({super.key, required this.onLogin});

  @override
  _LoginSignupPageState createState() => _LoginSignupPageState();
}

class _LoginSignupPageState extends State<LoginSignupPage> {
  bool _isLogin = true;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _verificationCodeController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;
  bool _isEmailVerified = false;
  bool _isCodeSent = false;
  String? _verificationCode;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _verificationCodeController.dispose();
    super.dispose();
  }

  void _toggleForm() {
    setState(() {
      _isLogin = !_isLogin;
      _emailController.clear();
      _passwordController.clear();
      _verificationCodeController.clear();
      _errorMessage = null;
      _isEmailVerified = false;
      _isCodeSent = false;
      _verificationCode = null;
    });
  }

  // Generate a random 6-digit code
  String _generateVerificationCode() {
    final random = Random();
    return (100000 + random.nextInt(900000)).toString(); // generates a number between 100000 and 999999
  }

  Future<void> _sendVerificationCode() async {
    if (_emailController.text.trim().isEmpty ||
        !RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(_emailController.text.trim())) {
      setState(() {
        _errorMessage = 'Please enter a valid email address';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Check if email already exists
      final methods = await _auth.fetchSignInMethodsForEmail(_emailController.text.trim());
      if (methods.isNotEmpty) {
        setState(() {
          _errorMessage = 'This email is already registered. Please login instead.';
        });
        return;
      }

      // Generate verification code
      _verificationCode = _generateVerificationCode();

      // Store verification data in Firestore with timestamp
      await _firestore.collection('verification_codes').doc(_emailController.text.trim()).set({
        'code': _verificationCode,
        'createdAt': FieldValue.serverTimestamp(),
        'attempts': 0
      });

      // TODO: Implement actual email sending here
      // For now, we'll just print the code (in production, you should send via email)
      print('Verification code: $_verificationCode');

      setState(() {
        _isCodeSent = true;
        _errorMessage = 'Verification code has been sent to your email.';
      });

    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to send verification code. Please try again.';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _verifyCode() async {
    if (_verificationCodeController.text.trim().isEmpty) {
      setState(() {
        _errorMessage = 'Please enter the verification code';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Get the stored verification data
      final verificationDoc = await _firestore
          .collection('verification_codes')
          .doc(_emailController.text.trim())
          .get();

      if (!verificationDoc.exists) {
        setState(() {
          _errorMessage = 'Verification code expired. Please request a new one.';
        });
        return;
      }

      final data = verificationDoc.data()!;
      final storedCode = data['code'] as String;
      final createdAt = (data['createdAt'] as Timestamp).toDate();
      final attempts = (data['attempts'] as int?) ?? 0;

      // Check if code is expired (10 minutes validity)
      if (DateTime.now().difference(createdAt).inMinutes > 10) {
        await _firestore
            .collection('verification_codes')
            .doc(_emailController.text.trim())
            .delete();
        setState(() {
          _errorMessage = 'Verification code expired. Please request a new one.';
        });
        return;
      }

      // Check if too many attempts (max 3)
      if (attempts >= 3) {
        setState(() {
          _errorMessage = 'Too many attempts. Please request a new code.';
        });
        return;
      }

      // Update attempts
      await _firestore
          .collection('verification_codes')
          .doc(_emailController.text.trim())
          .update({'attempts': attempts + 1});

      // Verify code
      if (_verificationCodeController.text.trim() != storedCode) {
        setState(() {
          _errorMessage = 'Invalid verification code. ${2 - attempts} attempts remaining.';
        });
        return;
      }

      setState(() {
        _isEmailVerified = true;
        _errorMessage = 'Email verified! Please create your password.';
      });

    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to verify code. Please try again.';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _createAccount() async {
    if (_passwordController.text.trim().isEmpty) {
      setState(() {
        _errorMessage = 'Please create a password';
      });
      return;
    }

    // Validate password strength
    String password = _passwordController.text.trim();
    if (password.length < 8) {
      setState(() {
        _errorMessage = 'Password must be at least 8 characters long';
      });
      return;
    }
    if (!RegExp(r'[A-Z]').hasMatch(password)) {
      setState(() {
        _errorMessage = 'Password must contain at least one uppercase letter';
      });
      return;
    }
    if (!RegExp(r'[a-z]').hasMatch(password)) {
      setState(() {
        _errorMessage = 'Password must contain at least one lowercase letter';
      });
      return;
    }
    if (!RegExp(r'[0-9]').hasMatch(password)) {
      setState(() {
        _errorMessage = 'Password must contain at least one number';
      });
      return;
    }
    if (!RegExp(r'[!@#\$%^&*(),.?":{}|<>]').hasMatch(password)) {
      setState(() {
        _errorMessage = 'Password must contain at least one special character';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Create user account
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // Store user data in Firestore
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'email': _emailController.text.trim(),
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Delete verification code document
      await _firestore
          .collection('verification_codes')
          .doc(_emailController.text.trim())
          .delete();

      widget.onLogin();

    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to create account. Please try again.';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      try {
        if (_isLogin) {
          // Login
          final userCredential = await _auth.signInWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
          );

          widget.onLogin();
        }
      } on FirebaseAuthException catch (e) {
        setState(() {
          _errorMessage = _getErrorMessage(e.code);
        });
      } catch (e) {
        setState(() {
          _errorMessage = 'An unexpected error occurred. Please try again.';
        });
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String _getErrorMessage(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No user found with this email.';
      case 'wrong-password':
        return 'Incorrect password.';
      case 'email-already-in-use':
        return 'This email is already registered.';
      case 'invalid-email':
        return 'Invalid email format.';
      case 'weak-password':
        return 'Password must be at least 8 characters long and include uppercase, lowercase, numbers, and special characters.';
      default:
        return 'An error occurred. Please try again.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.grey[900],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _isLogin ? 'Login' : 'Sign Up',
                    style: const TextStyle(
                      color: Colors.orange,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (_errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Text(
                        _errorMessage!,
                        style: TextStyle(
                          color: _isCodeSent && !_isEmailVerified ? Colors.orange : 
                                 _isEmailVerified ? Colors.green : Colors.red,
                        ),
                      ),
                    ),
                  TextFormField(
                    controller: _emailController,
                    enabled: !_isCodeSent || _isLogin,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      labelStyle: const TextStyle(color: Colors.orange),
                      filled: true,
                      fillColor: Colors.black,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    style: const TextStyle(color: Colors.white),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter your email';
                      }
                      if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ),
                  if (_isLogin || _isEmailVerified) ...[
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passwordController,
                      decoration: InputDecoration(
                        labelText: _isLogin ? 'Password' : 'Create Password',
                        labelStyle: const TextStyle(color: Colors.orange),
                        filled: true,
                        fillColor: Colors.black,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      obscureText: true,
                      style: const TextStyle(color: Colors.white),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return _isLogin
                              ? 'Please enter your password'
                              : 'Please create a password';
                        }
                        
                        // Only check for strong password during signup
                        if (!_isLogin) {
                          if (value.length < 8) {
                            return 'Password must be at least 8 characters long';
                          }
                          if (!RegExp(r'[A-Z]').hasMatch(value)) {
                            return 'Password must contain at least one uppercase letter';
                          }
                          if (!RegExp(r'[a-z]').hasMatch(value)) {
                            return 'Password must contain at least one lowercase letter';
                          }
                          if (!RegExp(r'[0-9]').hasMatch(value)) {
                            return 'Password must contain at least one number';
                          }
                          if (!RegExp(r'[!@#\$%^&*(),.?":{}|<>]').hasMatch(value)) {
                            return 'Password must contain at least one special character';
                          }
                        }
                        return null;
                      },
                    ),
                  ],
                  if (!_isLogin && _isCodeSent && !_isEmailVerified) ...[
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _verificationCodeController,
                      decoration: InputDecoration(
                        labelText: 'Verification Code',
                        labelStyle: const TextStyle(color: Colors.orange),
                        filled: true,
                        fillColor: Colors.black,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      style: const TextStyle(color: Colors.white),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter the verification code';
                        }
                        if (value.length != 6) {
                          return 'Verification code must be 6 digits';
                        }
                        return null;
                      },
                    ),
                  ],
                  const SizedBox(height: 24),
                  if (_isLoading)
                    const CircularProgressIndicator(color: Colors.orange)
                  else if (!_isLogin && !_isCodeSent)
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        padding: const EdgeInsets.symmetric(
                            vertical: 16, horizontal: 48),
                      ),
                      onPressed: _sendVerificationCode,
                      child: const Text(
                        'Send Verification Code',
                        style: TextStyle(fontSize: 18),
                      ),
                    )
                  else if (!_isLogin && _isCodeSent && !_isEmailVerified)
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        padding: const EdgeInsets.symmetric(
                            vertical: 16, horizontal: 48),
                      ),
                      onPressed: _verifyCode,
                      child: const Text(
                        'Verify Code',
                        style: TextStyle(fontSize: 18),
                      ),
                    )
                  else if (!_isLogin && _isEmailVerified)
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        padding: const EdgeInsets.symmetric(
                            vertical: 16, horizontal: 48),
                      ),
                      onPressed: _createAccount,
                      child: const Text(
                        'Create Account',
                        style: TextStyle(fontSize: 18),
                      ),
                    )
                  else if (_isLogin)
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        padding: const EdgeInsets.symmetric(
                            vertical: 16, horizontal: 48),
                      ),
                      onPressed: _submit,
                      child: const Text(
                        'Login',
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  const SizedBox(height: 16),
                  if (!_isCodeSent || _isLogin)
                    TextButton(
                      onPressed: _toggleForm,
                      child: Text(
                        _isLogin
                            ? 'Don\'t have an account? Sign Up'
                            : 'Already have an account? Login',
                        style: const TextStyle(color: Colors.orange),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
