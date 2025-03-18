// ignore_for_file: non_constant_identifier_names, use_build_context_synchronously, duplicate_ignore, deprecated_member_use, unused_field, unused_element

import 'package:brokecheck/homepage.dart';
import 'package:brokecheck/mytextfield.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// Import the theme file
import 'package:brokecheck/app_themes.dart'; // Make sure this path is correct

// Custom dialog for displaying messages with improved styling
void showStyledDialog(BuildContext context, String message) {
  final isDarkMode = Theme.of(context).brightness == Brightness.dark;

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppThemes.getCardColor(isDarkMode),
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10.0,
                offset: const Offset(0.0, 10.0),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 16),
              Icon(
                message.toLowerCase().contains("error") ||
                        message.toLowerCase().contains("invalid")
                    ? Icons.error_outline
                    : Icons.check_circle_outline,
                color: message.toLowerCase().contains("error") ||
                        message.toLowerCase().contains("invalid")
                    ? AppThemes.getErrorColor(isDarkMode)
                    : AppThemes.getPrimaryColor(isDarkMode),
                size: 48,
              ),
              const SizedBox(height: 24),
              Text(
                message,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'poppy',
                  color: AppThemes.getTextColor(isDarkMode),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(120, 45),
                  backgroundColor: AppThemes.getPrimaryColor(isDarkMode),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  "OK",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'poppy',
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      );
    },
  );
}

class LoginSignupModal extends StatefulWidget {
  const LoginSignupModal({super.key});

  @override
  State<LoginSignupModal> createState() => _LoginSignupModalState();
}

class _LoginSignupModalState extends State<LoginSignupModal> {
  // Text controllers
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _confirmpwController = TextEditingController();
  final TextEditingController _verificationCodeController =
      TextEditingController();

  // UI state
  bool _isLogin = true;
  bool _isEmailVerification = false;
  bool _isLoading = false;
  String? _verificationId;

  // Store user data temporarily during verification process
  String? _tempEmail;
  String? _tempUsername;
  String? _tempPassword;

  // Regex for email validation
  static final RegExp _emailRegex = RegExp(
    r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
    caseSensitive: false,
  );

  @override
  void dispose() {
    // Clean up controllers to prevent memory leaks
    _emailController.dispose();
    _passwordController.dispose();
    _usernameController.dispose();
    _confirmpwController.dispose();
    _verificationCodeController.dispose();
    super.dispose();
  }

  // Show loading state
  void _setLoading(bool loading) {
    if (mounted) {
      setState(() {
        _isLoading = loading;
      });
    }
  }

  // Validate email
  bool _isValidEmail(String email) {
    return _emailRegex.hasMatch(email.trim());
  }

  // Login method
  Future<void> _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    // Validate email
    if (!_isValidEmail(email)) {
      showStyledDialog(context, "Please enter a valid email address");
      return;
    }

    // Validate password
    if (password.isEmpty) {
      showStyledDialog(context, "Password is required");
      return;
    }

    _setLoading(true);

    try {
      final userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Check if email is verified
      if (!userCredential.user!.emailVerified) {
        _setLoading(false);

        // Ask user if they want to resend verification email
        showDialog(
          context: context,
          builder: (BuildContext context) {
            final isDarkMode = Theme.of(context).brightness == Brightness.dark;
            return AlertDialog(
              backgroundColor: AppThemes.getCardColor(isDarkMode),
              title: Text(
                "Email Not Verified",
                style: TextStyle(
                  color: AppThemes.getTextColor(isDarkMode),
                  fontFamily: 'poppy',
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: Text(
                "Your email is not verified. Would you like to resend the verification email?",
                style: TextStyle(
                  color: AppThemes.getTextColor(isDarkMode),
                  fontFamily: 'quickie',
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    "Cancel",
                    style: TextStyle(
                      color: AppThemes.getSecondaryTextColor(isDarkMode),
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    Navigator.of(context).pop();
                    _setLoading(true);
                    try {
                      await userCredential.user!.sendEmailVerification();
                      _setLoading(false);
                      showStyledDialog(context,
                          "Verification email sent. Please check your inbox.");
                    } catch (e) {
                      _setLoading(false);
                      showStyledDialog(context,
                          "Error sending verification email. Please try again later.");
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppThemes.getPrimaryColor(isDarkMode),
                  ),
                  child: const Text("Resend"),
                ),
              ],
            );
          },
        );
        return;
      }

      if (mounted) {
        _setLoading(false);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const Homepage()),
        );
      }
    } on FirebaseAuthException catch (e) {
      _setLoading(false);
      // Display user-friendly error messages
      String errorMessage = _getFirebaseErrorMessage(e.code);
      showStyledDialog(context, errorMessage);
    } catch (e) {
      _setLoading(false);
      showStyledDialog(context, "An unexpected error occurred");
    }
  }

  // Step 1: Create account with email and password
  Future<void> _createAccountWithEmailAndPassword() async {
    final email = _emailController.text.trim();
    final username = _usernameController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmpwController.text;

    // Validate all fields
    if (!_isValidEmail(email)) {
      showStyledDialog(context, "Please enter a valid email address");
      return;
    }

    if (username.isEmpty) {
      showStyledDialog(context, "Username is required");
      return;
    }

    if (password.isEmpty) {
      showStyledDialog(context, "Password is required");
      return;
    }

    if (password.length < 6) {
      showStyledDialog(context, "Password must be at least 6 characters");
      return;
    }

    if (password != confirmPassword) {
      showStyledDialog(context, "Passwords don't match");
      return;
    }

    _setLoading(true);

    try {
      // Check if email already exists
      final methods =
          await FirebaseAuth.instance.fetchSignInMethodsForEmail(email);
      if (methods.isNotEmpty) {
        _setLoading(false);
        showStyledDialog(context, "This email is already registered");
        return;
      }

      // Create the user
      final userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Send email verification
      await userCredential.user!.sendEmailVerification();

      // Store data in Firestore
      await _createUserDocument(userCredential, username);

      _setLoading(false);

      // Show success dialog
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            final isDarkMode = Theme.of(context).brightness == Brightness.dark;
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0),
              ),
              elevation: 0,
              backgroundColor: Colors.transparent,
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppThemes.getCardColor(isDarkMode),
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10.0,
                      offset: Offset(0.0, 10.0),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 16),
                    Icon(
                      Icons.mark_email_read,
                      color: AppThemes.getPrimaryColor(isDarkMode),
                      size: 72,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      "Account Created!",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'poppy',
                        color: AppThemes.getTextColor(isDarkMode),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "We've sent a verification email to $email",
                      style: TextStyle(
                        fontSize: 16,
                        fontFamily: 'poppy',
                        color: AppThemes.getTextColor(isDarkMode),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Please verify your email before logging in",
                      style: TextStyle(
                        fontSize: 14,
                        fontFamily: 'poppy',
                        color: AppThemes.getSecondaryTextColor(isDarkMode),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        setState(() {
                          _isLogin = true;
                          _isEmailVerification = false;
                          _emailController.text = email;
                          _passwordController.text = "";
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(200, 50),
                        backgroundColor: AppThemes.getPrimaryColor(isDarkMode),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        "Go to Login",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'poppy',
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            );
          },
        );
      }
    } on FirebaseAuthException catch (e) {
      _setLoading(false);
      String errorMessage = _getFirebaseErrorMessage(e.code);
      showStyledDialog(context, errorMessage);
    } catch (e) {
      _setLoading(false);
      showStyledDialog(
          context, "An unexpected error occurred: ${e.toString()}");
    }
  }

  // Google sign-in method
  Future<void> _signInWithGoogle() async {
    // This is a placeholder for Google sign-in implementation
    showStyledDialog(
        context, "Google sign-in will be implemented in a future update");

    // Actual implementation requires google_sign_in package
    // For example:
    /*
    _setLoading(true);
    try {
      // Create a GoogleSignIn instance
      final GoogleSignIn googleSignIn = GoogleSignIn();
      // Start the sign-in process
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      
      // Get authentication details from the request
      final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;
      
      // Create new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );
      
      // Sign in with credential
      final userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      
      // Create user document if it's a new user
      if (userCredential.additionalUserInfo?.isNewUser ?? false) {
        await FirebaseFirestore.instance
            .collection("Users")
            .doc(userCredential.user!.email)
            .set({
          'email': userCredential.user!.email,
          'username': userCredential.user!.displayName,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
      
      _setLoading(false);
      
    // Navigate to homepage
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const Homepage()),
        );
      }
    } catch (e) {
      _setLoading(false);
      showStyledDialog(context, "Google sign-in failed: ${e.toString()}");
    }
    */
  }

  // Get user-friendly error message from Firebase error code
  String _getFirebaseErrorMessage(String errorCode) {
    switch (errorCode) {
      case 'user-not-found':
        return 'No user found with this email';
      case 'wrong-password':
        return 'Incorrect password';
      case 'email-already-in-use':
        return 'This email is already registered';
      case 'weak-password':
        return 'Password is too weak';
      case 'invalid-email':
        return 'Invalid email format';
      case 'user-disabled':
        return 'This account has been disabled';
      case 'operation-not-allowed':
        return 'Operation not allowed';
      case 'too-many-requests':
        return 'Too many attempts. Try again later';
      case 'network-request-failed':
        return 'Network error. Please check your connection';
      default:
        return 'Authentication error: $errorCode';
    }
  }

  // Create a user document in Firestore
  Future<void> _createUserDocument(
      UserCredential userCredential, String username) async {
    if (userCredential.user != null) {
      await FirebaseFirestore.instance
          .collection("Users")
          .doc(userCredential.user!.email)
          .set({
        'email': userCredential.user!.email,
        'username': username,
        'createdAt': FieldValue.serverTimestamp(),
        'emailVerified': false, // Set initial verification status
      });
    }
  }

  // Update user document when email is verified
  Future<void> _updateUserVerificationStatus(String email) async {
    await FirebaseFirestore.instance.collection("Users").doc(email).update({
      'emailVerified': true,
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Stack(
      children: [
        SizedBox(
          width: double.infinity,
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.only(
                top: 16,
                left: 16,
                right: 16,
                bottom: MediaQuery.of(context).viewInsets.bottom + 16,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildToggle(),
                  const SizedBox(height: 20),
                  if (_isLogin) _buildLoginForm() else _buildSignupForm(),
                ],
              ),
            ),
          ),
        ),
        if (_isLoading)
          Container(
            color: Colors.black.withOpacity(0.5),
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppThemes.getCardColor(isDarkMode),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                          AppThemes.getPrimaryColor(isDarkMode)),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "Please wait...",
                      style: TextStyle(
                        fontFamily: 'poppy',
                        fontWeight: FontWeight.w500,
                        color: AppThemes.getTextColor(isDarkMode),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildToggle() {
    final screenWidth = MediaQuery.of(context).size.width;
    final toggleWidth = screenWidth < 600 ? screenWidth * 0.6 : 250.0;
    final buttonWidth = screenWidth < 300 ? screenWidth * 0.4 : 120.0;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: toggleWidth,
      height: 50,
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[800] : Colors.grey[300],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Stack(
        children: [
          AnimatedAlign(
            duration: const Duration(milliseconds: 300),
            alignment: _isLogin ? Alignment.centerLeft : Alignment.centerRight,
            child: Container(
              width: buttonWidth,
              height: 50,
              decoration: BoxDecoration(
                color: AppThemes.getCardColor(isDarkMode),
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () {
                    setState(() {
                      _isLogin = true;
                      _isEmailVerification = false;
                    });
                  },
                  child: Text(
                    "Login",
                    style: TextStyle(
                      fontSize: screenWidth < 300 ? 16 : 20,
                      fontWeight: FontWeight.bold,
                      color: _isLogin
                          ? AppThemes.getPrimaryColor(isDarkMode)
                          : AppThemes.getSecondaryTextColor(isDarkMode),
                      fontFamily: 'poppy',
                    ),
                  ),
                ),
              ),
              Expanded(
                child: TextButton(
                  onPressed: () {
                    setState(() {
                      _isLogin = false;
                      _isEmailVerification = false;
                    });
                  },
                  child: Text(
                    "Sign up",
                    style: TextStyle(
                      fontSize: screenWidth < 300 ? 16 : 20,
                      fontWeight: FontWeight.bold,
                      color: _isLogin
                          ? AppThemes.getSecondaryTextColor(isDarkMode)
                          : AppThemes.getPrimaryColor(isDarkMode),
                      fontFamily: 'poppy',
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLoginForm() {
    final screenWidth = MediaQuery.of(context).size.width;
    final buttonWidth = screenWidth < 600 ? screenWidth * 0.8 : 500.0;
    final socialButtonWidth = screenWidth < 600 ? screenWidth * 0.7 : 300.0;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        // Email textfield
        Mytextfield(
          label: 'Email',
          obscureText: false,
          controller: _emailController,
        ),

        const SizedBox(height: 15),

        // Password textfield
        Mytextfield(
          label: 'Password',
          obscureText: true,
          controller: _passwordController,
        ),

        // Forgot password
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () {
              _showForgotPasswordDialog();
            },
            child: Text(
              'Forgot Password?',
              style: TextStyle(
                color: AppThemes.getPrimaryColor(isDarkMode),
                fontFamily: 'poppy',
                fontSize: 14,
              ),
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Login button
        ElevatedButton(
          onPressed: _login,
          style: ElevatedButton.styleFrom(
            minimumSize: Size(buttonWidth, 50),
            backgroundColor: AppThemes.getPrimaryColor(isDarkMode),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text(
            "Login",
            style: TextStyle(
              fontSize: screenWidth < 300 ? 18 : 25,
              fontWeight: FontWeight.bold,
              fontFamily: 'poppy',
            ),
          ),
        ),

        const SizedBox(height: 10),

        // Or divider
        Text(
          '───── OR ─────',
          style: TextStyle(
            fontSize: screenWidth < 300 ? 16 : 20,
            fontWeight: FontWeight.bold,
            fontFamily: 'poppy',
            color: AppThemes.getTextColor(isDarkMode),
          ),
        ),

        const SizedBox(height: 20),

        // Google login button
        ElevatedButton.icon(
          onPressed: _signInWithGoogle,
          style: ElevatedButton.styleFrom(
            minimumSize: Size(socialButtonWidth, 50),
            foregroundColor: AppThemes.getTextColor(isDarkMode),
            backgroundColor: isDarkMode ? Colors.grey[800] : Colors.grey[300],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          icon: const Icon(FontAwesomeIcons.google, size: 25),
          label: Text(
            "Login with Google",
            style: TextStyle(
              fontSize: screenWidth < 300 ? 16 : 20,
              fontWeight: FontWeight.bold,
              fontFamily: 'poppylight',
            ),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  // Show forgot password dialog
  void _showForgotPasswordDialog() {
    final resetEmailController = TextEditingController();
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppThemes.getCardColor(isDarkMode),
          title: Text(
            "Reset Password",
            style: TextStyle(
              fontFamily: 'poppy',
              fontWeight: FontWeight.bold,
              color: AppThemes.getTextColor(isDarkMode),
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Enter your email address and we'll send you a password reset link",
                style: TextStyle(
                  fontFamily: 'poppy',
                  color: AppThemes.getTextColor(isDarkMode),
                ),
              ),
              const SizedBox(height: 16),
              Mytextfield(
                label: 'Email',
                obscureText: false,
                controller: resetEmailController,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                "Cancel",
                style: TextStyle(
                  color: AppThemes.getSecondaryTextColor(isDarkMode),
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                final email = resetEmailController.text.trim();
                if (!_isValidEmail(email)) {
                  showStyledDialog(
                      context, "Please enter a valid email address");
                  return;
                }

                Navigator.of(context).pop();
                _setLoading(true);

                try {
                  await FirebaseAuth.instance
                      .sendPasswordResetEmail(email: email);
                  _setLoading(false);
                  showStyledDialog(
                      context, "Password reset link sent to your email");
                } on FirebaseAuthException catch (e) {
                  _setLoading(false);
                  String errorMessage = _getFirebaseErrorMessage(e.code);
                  showStyledDialog(context, errorMessage);
                } catch (e) {
                  _setLoading(false);
                  showStyledDialog(
                      context, "Failed to send password reset email");
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppThemes.getPrimaryColor(isDarkMode),
              ),
              child: const Text("Send Reset Link"),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSignupForm() {
    final screenWidth = MediaQuery.of(context).size.width;
    final buttonWidth = screenWidth < 600 ? screenWidth * 0.8 : 500.0;
    final socialButtonWidth = screenWidth < 600 ? screenWidth * 0.7 : 300.0;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        // Username textfield
        Mytextfield(
          label: 'Username',
          obscureText: false,
          controller: _usernameController,
        ),

        const SizedBox(height: 5),

        // Email textfield
        Mytextfield(
          label: 'Email',
          obscureText: false,
          controller: _emailController,
        ),

        const SizedBox(height: 5),

        // Password textfield
        Mytextfield(
          label: 'Password',
          obscureText: true,
          controller: _passwordController,
        ),

        const SizedBox(height: 5),

        // Confirm password textfield
        Mytextfield(
          label: 'Confirm Password',
          obscureText: true,
          controller: _confirmpwController,
        ),

        const SizedBox(height: 16),

        // Continue button
        ElevatedButton(
          onPressed: _createAccountWithEmailAndPassword,
          style: ElevatedButton.styleFrom(
            minimumSize: Size(buttonWidth, 50),
            backgroundColor: AppThemes.getPrimaryColor(isDarkMode),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text(
            "Sign Up",
            style: TextStyle(
              fontSize: screenWidth < 300 ? 18 : 20,
              fontWeight: FontWeight.bold,
              fontFamily: 'poppy',
            ),
          ),
        ),

        const SizedBox(height: 10),

        Text(
          '───── OR ─────',
          style: TextStyle(
            fontSize: screenWidth < 300 ? 16 : 20,
            fontWeight: FontWeight.bold,
            fontFamily: 'poppy',
            color: AppThemes.getTextColor(isDarkMode),
          ),
        ),

        const SizedBox(height: 20),

        // Google signup button
        ElevatedButton.icon(
          onPressed: _signInWithGoogle,
          style: ElevatedButton.styleFrom(
            minimumSize: Size(socialButtonWidth, 50),
            foregroundColor: AppThemes.getTextColor(isDarkMode),
            backgroundColor: isDarkMode ? Colors.grey[800] : Colors.grey[300],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          icon: const Icon(FontAwesomeIcons.google, size: 25),
          label: Text(
            "Sign up with Google",
            style: TextStyle(
              fontSize: screenWidth < 300 ? 16 : 20,
              fontWeight: FontWeight.bold,
              fontFamily: 'poppylight',
            ),
          ),
        ),

        const SizedBox(height: 20),
      ],
    );
  }
}
