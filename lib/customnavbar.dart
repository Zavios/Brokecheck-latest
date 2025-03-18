// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'dart:ui';

class CustomNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  const CustomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
  });

  @override
  Widget build(BuildContext context) {
    // Get theme data
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Enhanced colors
    final backgroundColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final primaryColor = theme.colorScheme.primary;
    final iconColor = isDark ? Colors.white60 : Colors.black54;
    final selectedIconColor = primaryColor;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Container(
          height: 70,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(35),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.3 : 0.08),
                blurRadius: 12,
                spreadRadius: isDark ? 1 : 0,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(35),
            child: Stack(
              children: [
                // Background blur effect for modern look
                if (!isDark)
                  BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),

                // Navigation bar
                NavigationBar(
                  height: 70,
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  indicatorColor: Colors
                      .transparent, // Changed to transparent to remove pill indicator
                  indicatorShape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  selectedIndex: selectedIndex,
                  onDestinationSelected: onItemTapped,
                  labelBehavior:
                      NavigationDestinationLabelBehavior.onlyShowSelected,
                  animationDuration: const Duration(milliseconds: 400),
                  destinations: [
                    _buildNavItem(
                      Icons.home_rounded,
                      'Home',
                      iconColor,
                      selectedIconColor,
                      selectedIndex == 0,
                    ),
                    _buildNavItem(
                      Icons.subscriptions_rounded,
                      'Subscriptions',
                      iconColor,
                      selectedIconColor,
                      selectedIndex == 1,
                    ),
                    _buildNavItem(
                      Icons.credit_card_rounded,
                      'Cards',
                      iconColor,
                      selectedIconColor,
                      selectedIndex == 2,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  NavigationDestination _buildNavItem(IconData icon, String label,
      Color iconColor, Color selectedIconColor, bool isSelected) {
    return NavigationDestination(
      icon: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isSelected
              ? selectedIconColor.withOpacity(0.1)
              : Colors.transparent,
        ),
        child: Icon(
          icon,
          size: 26,
          color: iconColor,
        ),
      ),
      selectedIcon: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: selectedIconColor.withOpacity(0.15),
        ),
        child: Icon(
          icon,
          size: 28,
          color: selectedIconColor,
        ),
      ),
      label: label,
    );
  }
}
