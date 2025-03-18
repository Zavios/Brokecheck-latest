// ignore_for_file: unused_import, deprecated_member_use

import 'package:brokecheck/app_themes.dart';
import 'package:brokecheck/cards.dart';
import 'package:brokecheck/cashbook.dart';
import 'package:brokecheck/cashbook_display.dart';
import 'package:brokecheck/favourites_section.dart';
import 'package:brokecheck/subscriptions.dart';
import 'package:brokecheck/themes.dart'; // Import your theme file
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:brokecheck/customnavbar.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Homepage extends StatefulWidget {
  const Homepage({
    super.key,
  });

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  int _selectedIndex = 0;
  // Add cache variables
  String? _cachedUsername;
  String? _cachedFirstLetter;
  bool _isLoading = true;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // Current logged in user
  final User? currentUser = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    // Load user details once when the widget initializes
    _loadUserDetails();
  }

  // Method to load user details and cache them
  Future<void> _loadUserDetails() async {
    try {
      if (currentUser == null || currentUser!.email == null) {
        _cachedUsername = "Guest";
        _cachedFirstLetter = "G";
      } else {
        DocumentSnapshot<Map<String, dynamic>> userDoc = await FirebaseFirestore
            .instance
            .collection("Users")
            .doc(currentUser!.email)
            .get();

        if (userDoc.exists) {
          Map<String, dynamic>? userData = userDoc.data();
          _cachedUsername = userData?['username'] ?? "Guest";
          _cachedFirstLetter = _cachedUsername!.isNotEmpty
              ? _cachedUsername![0].toUpperCase()
              : "G";
        } else {
          _cachedUsername = "Guest";
          _cachedFirstLetter = "G";
        }
      }
    } catch (e) {
      _cachedUsername = "Guest";
      _cachedFirstLetter = "G";
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // List of pages to display based on the selected index
  final List<Widget> _pages = [
    const HomeContent(),
    const SubscriptionsPage(),
    const CardPage()
  ];

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final bool isSmallScreen = screenSize.width < 600;
    final brightness = Theme.of(context).brightness;
    final bool isDarkMode = brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: isSmallScreen ? 70 : 80,
        titleSpacing: 16.0, // Added spacing between leading and title
        title: _isLoading
            ? Text(
                "Loading...",
                style: TextStyle(
                  fontSize: 25,
                  fontFamily: 'poppy',
                  fontWeight: FontWeight.bold,
                  color: AppThemes.getPrimaryColor(isDarkMode),
                ),
              )
            : Text(
                _cachedUsername!,
                style: TextStyle(
                  fontSize: isSmallScreen ? 22 : 25,
                  fontFamily: 'poppy',
                  fontWeight: FontWeight.bold,
                  color: AppThemes.getPrimaryColor(isDarkMode),
                ),
                overflow: TextOverflow.ellipsis,
              ),
        actions: <Widget>[
          IconButton(
            onPressed: () {
              Navigator.pushNamed(context, '/settings');
            },
            icon: Icon(
              Icons.settings,
              size: isSmallScreen ? 24 : 30,
              color: AppThemes.getTextColor(isDarkMode).withOpacity(0.7),
            ),
            padding: EdgeInsets.all(isSmallScreen ? 8.0 : 12.0),
          )
        ],
        leadingWidth:
            isSmallScreen ? 60 : 70, // Control width of leading section
        leading: Padding(
          padding:
              EdgeInsets.only(left: 16.0), // Add left padding to the avatar
          child: _isLoading
              ? Center(
                  child: CircularProgressIndicator(
                    color: AppThemes.getPrimaryColor(isDarkMode),
                  ),
                )
              : Hero(
                  tag: 'profilePicture',
                  child: CircleAvatar(
                    backgroundColor: AppThemes.getPrimaryColor(isDarkMode),
                    child: Text(
                      _cachedFirstLetter!,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      // Display the selected page
      body: SafeArea(
        child: _pages[_selectedIndex],
      ),
      bottomNavigationBar: CustomNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),

      // Floating Action Button for the entire Scaffold
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton.extended(
              onPressed: () {
                showAddCashbookModal(context);
              },
              icon: Icon(
                Icons.add,
                size: 28,
                color: isDarkMode ? Colors.white : Colors.black,
              ),
              label: Text(
                "Add Cashbook",
                style: TextStyle(
                  fontSize: isSmallScreen ? 14 : 16,
                  fontFamily: 'poppylight',
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
              ),
              backgroundColor:
                  AppThemes.getPrimaryColor(isDarkMode).withOpacity(0.7),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}

class HomeContent extends StatefulWidget {
  const HomeContent({super.key});

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final bool isSmallScreen = screenSize.width < 600;
    final double horizontalPadding = isSmallScreen ? 12.0 : 24.0;
    final brightness = Theme.of(context).brightness;
    final bool isDarkMode = brightness == Brightness.dark;

    return RefreshIndicator(
      onRefresh: () async {
        setState(() {});
        await Future.delayed(const Duration(milliseconds: 800));
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0),
          child: Column(
            children: [
              Container(
                height: 1,
                color: AppThemes.getSecondaryTextColor(isDarkMode)
                    .withOpacity(0.5),
                margin: EdgeInsets.symmetric(horizontal: horizontalPadding / 2),
              ),
              const SizedBox(height: 16),

              // Use the FavoritesSection widget
              const FavoritesSection(),
              const SizedBox(height: 16),

              // Use the CashbooksSection widget
              const CashbooksSection(),
            ],
          ),
        ),
      ),
    );
  }
}
