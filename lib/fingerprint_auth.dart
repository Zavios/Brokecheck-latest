// ignore_for_file: unused_field, library_private_types_in_public_api, avoid_print, use_build_context_synchronously, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter/services.dart';

class FingerprintAuthPage extends StatefulWidget {
  const FingerprintAuthPage({super.key});

  @override
  _FingerprintAuthPageState createState() => _FingerprintAuthPageState();
}

class _FingerprintAuthPageState extends State<FingerprintAuthPage> {
  final LocalAuthentication _localAuthentication = LocalAuthentication();
  bool _canCheckBiometrics = false;
  List<BiometricType> _availableBiometrics = [];
  String _authStatus = 'Not Authenticated';
  bool _isAuthenticating = false;

  @override
  @override
  void initState() {
    super.initState();
    _initBiometrics();
  }

  Future<void> _initBiometrics() async {
    try {
      await _checkBiometrics();
      await _getAvailableBiometrics();

      // Add a short delay to ensure everything is initialized
      await Future.delayed(const Duration(milliseconds: 500));

      if (_canCheckBiometrics && _availableBiometrics.isNotEmpty) {
        _authenticate();
      } else {
        setState(() {
          _authStatus = 'Biometrics not available';
        });
      }
    } catch (e) {
      print("Error initializing biometrics: $e");
    }
  }

  // Check if biometrics are available on the device
  Future<void> _checkBiometrics() async {
    bool canCheckBiometrics;
    try {
      canCheckBiometrics = await _localAuthentication.canCheckBiometrics;
    } on PlatformException catch (e) {
      canCheckBiometrics = false;
      print(e);
    }
    if (!mounted) return;

    setState(() {
      _canCheckBiometrics = canCheckBiometrics;
    });
  }

  // Get the list of available biometrics
  Future<void> _getAvailableBiometrics() async {
    List<BiometricType> availableBiometrics;
    try {
      availableBiometrics = await _localAuthentication.getAvailableBiometrics();
    } on PlatformException catch (e) {
      availableBiometrics = <BiometricType>[];
      print(e);
    }
    if (!mounted) return;

    setState(() {
      _availableBiometrics = availableBiometrics;
    });
  }

  // Authenticate with fingerprint
  Future<void> _authenticate() async {
    bool authenticated = false;

    if (_isAuthenticating) {
      print("Already authenticating, returning");
      return;
    }

    // First check if biometrics are available
    if (!_canCheckBiometrics) {
      print("Biometrics not available on this device");
      setState(() {
        _authStatus = 'Biometrics not available on this device';
      });
      return;
    }

    // Check if there are available biometrics
    if (_availableBiometrics.isEmpty) {
      print("No biometrics enrolled on this device");
      setState(() {
        _authStatus = 'No biometrics enrolled on this device';
      });
      return;
    }

    setState(() {
      _isAuthenticating = true;
      _authStatus = 'Authenticating...';
    });

    try {
      print("Attempting authentication");
      authenticated = await _localAuthentication.authenticate(
        localizedReason: 'Scan your fingerprint to authenticate',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );
      print("Authentication result: $authenticated");
    } on PlatformException catch (e) {
      print("Authentication error: ${e.message}");
      setState(() {
        _isAuthenticating = false;
        _authStatus = 'Error: ${e.message}';
      });
      return;
    } catch (e) {
      print("Unexpected error: $e");
      setState(() {
        _isAuthenticating = false;
        _authStatus = 'Unexpected error occurred';
      });
      return;
    }

    if (!mounted) return;

    setState(() {
      _isAuthenticating = false;
      _authStatus = authenticated ? 'Authenticated' : 'Authentication Failed';
    });

    if (authenticated) {
      // Navigate to the home page or main content
      Future.delayed(const Duration(milliseconds: 500), () {
        Navigator.of(context).pushReplacementNamed('/home');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade800, Colors.blue.shade500],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // App logo or icon
                  const Icon(
                    Icons.lock_outline,
                    size: 80,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 32),

                  // App name or welcome text
                  const Text(
                    'Welcome Back',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Subtitle
                  const Text(
                    'Please authenticate to continue',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 64),

                  // Fingerprint icon
                  GestureDetector(
                    onTap: _authenticate,
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.fingerprint,
                        size: 80,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Status text
                  Text(
                    _authStatus == 'Not Authenticated'
                        ? 'Tap the fingerprint icon to authenticate'
                        : _authStatus,
                    style: TextStyle(
                      fontSize: 16,
                      color: _authStatus == 'Authenticated'
                          ? Colors.green.shade100
                          : _authStatus.contains('Error') ||
                                  _authStatus == 'Authentication Failed'
                              ? Colors.red.shade100
                              : Colors.white70,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),

                  // Alternative auth method button
                  if (_authStatus != 'Authenticating...')
                    TextButton(
                      onPressed: () {
                        // Navigate to alternative login method
                        Navigator.pushNamed(context, '/login');
                      },
                      child: const Text(
                        'Use alternative login method',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
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
