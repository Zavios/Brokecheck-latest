// ignore_for_file: deprecated_member_use
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'theme_provider.dart';
import 'app_themes.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Current logged in user
  final User? currentUser = FirebaseAuth.instance.currentUser;
  bool _fingerprintEnabled = false;

  @override
  void initState() {
    super.initState();
    _loadFingerprintSettings();
  }

  // Load fingerprint settings from SharedPreferences
  Future<void> _loadFingerprintSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _fingerprintEnabled = prefs.getBool('fingerprint_enabled') ?? false;
    });
  }

  // Save fingerprint settings to SharedPreferences
  Future<void> _saveFingerprintSettings(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('fingerprint_enabled', value);
    setState(() {
      _fingerprintEnabled = value;
    });
  }

  // Future to fetch user details
  Future<DocumentSnapshot<Map<String, dynamic>>> getUserDetails() async {
    return await FirebaseFirestore.instance
        .collection("Users")
        .doc(currentUser!.email)
        .get();
  }

  // Logout method
  void logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    if (context.mounted) {
      Navigator.pushNamedAndRemoveUntil(
          context, '/getstarted', (route) => false);
    }
  }

  // Generate avatar with first letter of username
  Widget buildAvatar(String username, ThemeData theme) {
    return CircleAvatar(
      radius: 35,
      backgroundColor: theme.primaryColor,
      child: Center(
        child: Text(
          username.isNotEmpty ? username[0].toUpperCase() : "?",
          style: theme.textTheme.titleLarge?.copyWith(
            fontSize: 30,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    final theme = Theme.of(context);

    return Scaffold(
      // Use gradient for the entire scaffold background
      appBar: AppBar(
        title: Text(
          "Settings",
          style: theme.appBarTheme.titleTextStyle,
        ),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.chevron_left, size: 40),
        ),
        backgroundColor: Colors.transparent, // Make appbar transparent
        elevation: 0, // Remove app bar shadow
      ),
      extendBodyBehindAppBar: true, // Extend body behind appbar
      body: Container(
        // Gradient background for the entire screen
        decoration: BoxDecoration(
          gradient: AppThemes.getPrimaryGradient(isDark),
        ),
        child: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          future: getUserDetails(),
          builder: (context, snapshot) {
            String username = "Guest";
            if (snapshot.hasData && snapshot.data!.exists) {
              username = snapshot.data!['username'];
            }

            return Column(
              children: [
                // Add safe area padding for the app bar
                const SizedBox(height: kToolbarHeight + 40),

                // Profile section (now on gradient background)
                Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                  child: Row(
                    children: [
                      buildAvatar(username, theme),
                      const SizedBox(width: 15),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (snapshot.connectionState ==
                              ConnectionState.waiting)
                            Text(
                              "Loading...",
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontSize: 22,
                                color: Colors.white,
                              ),
                            )
                          else if (snapshot.hasError)
                            Text(
                              "Error",
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontSize: 22,
                                color: Colors.red,
                              ),
                            )
                          else
                            Text(
                              username,
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontSize: 22,
                                color: Colors.white,
                              ),
                            ),
                          Text(
                            currentUser?.email ?? "No email",
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontSize: 14,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),

                // Main content with rounded corners
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: theme.scaffoldBackgroundColor,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(25),
                        topRight: Radius.circular(25),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(isDark ? 0.2 : 0.1),
                          spreadRadius: 1,
                          blurRadius: 10,
                          offset: const Offset(0, -3),
                        ),
                      ],
                    ),
                    padding:
                        const EdgeInsets.only(top: 25, left: 20, right: 20),
                    child: ListView(
                      padding: const EdgeInsets.only(bottom: 20),
                      children: [
                        sectionTitle("App Settings", theme),
                        const SizedBox(height: 15),
                        settingsTile(
                          context,
                          Icons.lock_outline,
                          "Security",
                          () => Navigator.pushNamed(context, '/security'),
                          theme,
                        ),
                        const SizedBox(height: 12),
                        buildFingerprintToggle(context, theme),
                        const SizedBox(height: 12),
                        buildThemeToggle(context, themeProvider, theme),
                        const SizedBox(height: 12),
                        settingsTile(
                          context,
                          Icons.info_outline,
                          "About BrokeCheck",
                          () => Navigator.pushNamed(context, '/about'),
                          theme,
                        ),
                        const SizedBox(height: 12),
                        settingsTile(
                          context,
                          Icons.delete_outline,
                          "Delete Account",
                          () => Navigator.pushNamed(context, '/delete_account'),
                          theme,
                        ),
                        const SizedBox(height: 60),
                        logoutButton(context, theme),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget buildFingerprintToggle(BuildContext context, ThemeData theme) {
    return Card(
      margin: EdgeInsets.zero,
      shape: theme.cardTheme.shape,
      child: SwitchListTile(
        title: Text(
          "Fingerprint Authentication",
          style: theme.textTheme.bodyMedium?.copyWith(
            fontSize: 16,
          ),
        ),
        subtitle: Text(
          "Require fingerprint to open app",
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
          ),
        ),
        value: _fingerprintEnabled,
        onChanged: (bool value) {
          if (value) {
            _showBiometricInfoDialog(context, theme);
          } else {
            _saveFingerprintSettings(value);
          }
        },
        secondary: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: theme.primaryColor.withOpacity(0.2),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            Icons.fingerprint,
            color: theme.primaryColor,
            size: 22,
          ),
        ),
        activeColor: theme.primaryColor,
      ),
    );
  }

  void _showBiometricInfoDialog(BuildContext context, ThemeData theme) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.cardTheme.color,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          "Enable Fingerprint",
          style: theme.textTheme.titleLarge?.copyWith(
            fontSize: 20,
          ),
        ),
        content: Text(
          "This will require fingerprint authentication every time you open the app. You can disable this feature at any time in Settings.",
          style: theme.textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              "Cancel",
              style: theme.textButtonTheme.style?.textStyle
                  ?.resolve({WidgetState.pressed})?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _saveFingerprintSettings(true);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              "Enable",
              style: theme.textTheme.labelLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildThemeToggle(
      BuildContext context, ThemeProvider themeProvider, ThemeData theme) {
    final isDark = themeProvider.isDarkMode;
    return Card(
      margin: EdgeInsets.zero,
      shape: theme.cardTheme.shape,
      child: SwitchListTile(
        title: Text(
          "Dark Theme",
          style: theme.textTheme.bodyMedium?.copyWith(
            fontSize: 16,
          ),
        ),
        value: isDark,
        onChanged: (_) {
          themeProvider.toggleTheme();
        },
        secondary: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: theme.primaryColor.withOpacity(0.2),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            isDark ? Icons.dark_mode : Icons.light_mode,
            color: theme.primaryColor,
            size: 22,
          ),
        ),
        activeColor: theme.primaryColor,
      ),
    );
  }

  Widget settingsTile(
    BuildContext context,
    IconData icon,
    String title,
    VoidCallback onTap,
    ThemeData theme,
  ) {
    return Card(
      margin: EdgeInsets.zero,
      shape: theme.cardTheme.shape,
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: theme.primaryColor.withOpacity(0.2),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: theme.primaryColor,
            size: 22,
          ),
        ),
        title: Text(
          title,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: theme.primaryColor,
        ),
        onTap: onTap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
      ),
    );
  }

  Widget logoutButton(BuildContext context, ThemeData theme) {
    return Center(
      child: Container(
        width: 200,
        height: 50,
        decoration: BoxDecoration(
          gradient:
              AppThemes.dangerGradient, // Use danger gradient from AppThemes
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: Colors.red.withOpacity(0.3),
              spreadRadius: 1,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _showLogoutDialog(context),
            borderRadius: BorderRadius.circular(25),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.logout,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Text(
                  "Logout",
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget sectionTitle(String title, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0, bottom: 8.0),
      child: Text(
        title,
        style: theme.textTheme.titleMedium?.copyWith(
          fontSize: 18,
          color: theme.primaryColor,
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.cardTheme.color,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          "Logout",
          style: theme.textTheme.titleLarge?.copyWith(
            fontSize: 20,
          ),
        ),
        content: Text(
          "Are you sure you want to logout?",
          style: theme.textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              "Cancel",
              style: theme.textButtonTheme.style?.textStyle
                  ?.resolve({WidgetState.pressed})?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              logout(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              "Logout",
              style: theme.textTheme.labelLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
