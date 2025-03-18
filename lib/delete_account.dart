// ignore_for_file: use_build_context_synchronously, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:brokecheck/theme_provider.dart';

class DeleteAccountPage extends StatefulWidget {
  const DeleteAccountPage({super.key});

  @override
  State<DeleteAccountPage> createState() => _DeleteAccountPageState();
}

class _DeleteAccountPageState extends State<DeleteAccountPage> {
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  // Show error snackbar
  void _showErrorSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error, color: Colors.white),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  fontFamily: 'Poppy',
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
              ),
            ),
          ],
        ),
        backgroundColor: Theme.of(context).colorScheme.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  // Delete account functionality
  Future<void> _deleteAccount(BuildContext context) async {
    if (_passwordController.text.isEmpty) {
      _showErrorSnackbar(context, "Please enter your password to confirm.");
      return;
    }

    setState(() => _isLoading = true);

    final user = FirebaseAuth.instance.currentUser;

    try {
      // Re-authenticate user
      final credential = EmailAuthProvider.credential(
        email: user!.email!,
        password: _passwordController.text,
      );
      await user.reauthenticateWithCredential(credential);

      // Delete user data from Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .delete();

      // Delete user account
      await user.delete();

      setState(() => _isLoading = false);

      // Clear password field
      _passwordController.clear();

      // Navigate to login page
      Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
    } on FirebaseAuthException catch (e) {
      setState(() => _isLoading = false);

      String errorMessage = "An error occurred. Please try again.";

      switch (e.code) {
        case 'wrong-password':
          errorMessage = "The password is incorrect.";
          break;
        case 'requires-recent-login':
          errorMessage =
              "This operation requires recent authentication. Please log in again.";
          break;
      }

      // Show error snackbar
      _showErrorSnackbar(context, errorMessage);
    }
  }

  // Show confirmation dialog
  void _showConfirmationDialog() {
    final isDarkMode =
        Provider.of<ThemeProvider>(context, listen: false).isDarkMode;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDarkMode ? Colors.grey[850] : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        title: Row(
          children: [
            Icon(
              Icons.warning,
              color: Colors.red,
              size: 28,
            ),
            const SizedBox(width: 10),
            Text(
              'Final Confirmation',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontFamily: 'Poppy',
                color: Theme.of(context).colorScheme.error,
              ),
            ),
          ],
        ),
        content: Text(
          'Are you absolutely sure you want to delete your account? This action cannot be undone.',
          style: TextStyle(
            fontFamily: 'PoppyLight',
            color: isDarkMode ? Colors.white70 : Colors.black87,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancel',
              style: TextStyle(
                fontFamily: 'Poppy',
                color: isDarkMode ? Colors.white70 : Colors.grey[700],
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _deleteAccount(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Delete Account',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontFamily: 'Poppy',
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Delete Account",
          style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Poppy'),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).primaryColor,
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Warning icon
                  Center(
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 24),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.delete_forever,
                        color: Theme.of(context).colorScheme.error,
                        size: 64,
                      ),
                    ),
                  ),

                  // Warning title
                  Center(
                    child: Text(
                      "Delete Your Account",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Poppy',
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Warning description
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: themeProvider.isDarkMode
                          ? Colors.red.withOpacity(0.1)
                          : Colors.red.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.red.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Warning",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Poppy',
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Deleting your account is permanent and irreversible. This action will:",
                          style: TextStyle(
                            fontFamily: 'PoppyLight',
                            fontSize: 15,
                            color: themeProvider.isDarkMode
                                ? Colors.white
                                : Colors.black,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildWarningItem(
                          "Remove all your personal information",
                          themeProvider.isDarkMode,
                        ),
                        _buildWarningItem(
                          "Delete all your financial data and history",
                          themeProvider.isDarkMode,
                        ),
                        _buildWarningItem(
                          "Remove access to all your saved information",
                          themeProvider.isDarkMode,
                        ),
                        _buildWarningItem(
                          "Cancel any active subscriptions",
                          themeProvider.isDarkMode,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Password confirmation
                  Text(
                    "Enter your password to confirm:",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Poppy',
                      color: themeProvider.isDarkMode
                          ? Colors.white
                          : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _passwordController,
                    obscureText: !_isPasswordVisible,
                    decoration: InputDecoration(
                      labelText: "Password",
                      prefixIcon: Icon(
                        Icons.lock_outline,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isPasswordVisible
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                        onPressed: () {
                          setState(() {
                            _isPasswordVisible = !_isPasswordVisible;
                          });
                        },
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Delete button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed:
                          _isLoading ? null : () => _showConfirmationDialog(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.error,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: themeProvider.isDarkMode
                            ? Colors.grey[700]
                            : Colors.grey[300],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: _isLoading
                          ? SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              "Delete Account",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Poppy',
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Cancel button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          color: themeProvider.isDarkMode
                              ? Colors.grey[600]!
                              : Colors.grey[400]!,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        "Cancel",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Poppy',
                          color: themeProvider.isDarkMode
                              ? Colors.white
                              : Colors.black,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildWarningItem(String text, bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.remove_circle,
            size: 16,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontFamily: 'PoppyLight',
                fontSize: 14,
                color: isDarkMode ? Colors.red[300] : Colors.red[700],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
