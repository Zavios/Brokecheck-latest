// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Use theme colors from the app theme
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Get colors from theme
    final primaryColor = theme.primaryColor;
    final backgroundColor = theme.scaffoldBackgroundColor;
    final cardColor = theme.cardTheme.color ?? Colors.white;
    final textColor = theme.textTheme.bodyLarge?.color ?? Colors.black;
    final secondaryTextColor =
        theme.textTheme.labelMedium?.color ?? Colors.grey;

    // Get gradient from AppThemes
    final headerGradient = LinearGradient(
      colors: [primaryColor, Theme.of(context).colorScheme.secondary],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(
          'About',
          style: theme.appBarTheme.titleTextStyle,
        ),
        backgroundColor: primaryColor,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              // Share app functionality
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with logo
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 40),
              decoration: BoxDecoration(
                gradient: headerGradient,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(40),
                  bottomRight: Radius.circular(40),
                ),
              ),
              child: Column(
                children: [
                  // Logo without background
                  Image.asset(
                    'images/Brokecheck Logo.png',
                    height: 80,
                    width: 80,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'BrokeCheck',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontSize: 28,
                      letterSpacing: 1.2,
                      fontFamily: 'quickie',
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: 50,
                    height: 4,
                    decoration: BoxDecoration(
                      color: textColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ],
              ),
            ),

            // Welcome text
            Container(
              padding: const EdgeInsets.all(24),
              child: Text(
                'Welcome to BrokeCheck – your personal expense tracker designed to help you manage your finances effortlessly. Whether you\'re budgeting for the month, tracking daily expenses, or saving for a goal, BrokeCheck gives you the tools you need to stay on top of your money.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontSize: 16,
                  height: 1.5,
                ),
              ),
            ),

            // Features section
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.lightbulb,
                          color: theme.colorScheme.secondary, size: 24),
                      const SizedBox(width: 10),
                      Text(
                        'Key Features',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontSize: 20,
                          color: primaryColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildFeatureItem(
                    context,
                    Icons.add_chart,
                    'Simple Expense Tracking',
                    'Quickly log your expenses with an intuitive interface.',
                    theme,
                  ),
                  _buildFeatureItem(
                    context,
                    Icons.insights,
                    'Detailed Insights',
                    'Get a clear view of your spending habits with interactive charts and reports.',
                    theme,
                  ),
                  _buildFeatureItem(
                    context,
                    Icons.account_balance,
                    'Budget Management',
                    'Set monthly budgets and track your progress in real time.',
                    theme,
                  ),
                  _buildFeatureItem(
                    context,
                    Icons.category,
                    'Smart Categories',
                    'Automatically categorize your expenses for better organization.',
                    theme,
                  ),
                  _buildFeatureItem(
                    context,
                    Icons.notifications_active,
                    'Reminders & Notifications',
                    'Never miss a bill or go over budget with timely alerts.',
                    theme,
                  ),
                ],
              ),
            ),

            // Call to action
            Container(
              margin: const EdgeInsets.all(24),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: headerGradient,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: primaryColor.withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  'Take control of your money and build better financial habits with BrokeCheck!',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    height: 1.5,
                  ),
                ),
              ),
            ),

            // Version info and buttons
            Center(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 32.0),
                child: Column(
                  children: [
                    Text(
                      'Version 1.0.0',
                      style: TextStyle(
                        color: secondaryTextColor,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildIconButton(
                          context,
                          Icons.email,
                          'Contact',
                          theme,
                        ),
                        const SizedBox(width: 16),
                        _buildIconButton(
                          context,
                          Icons.star,
                          'Rate App',
                          theme,
                        ),
                        const SizedBox(width: 16),
                        _buildIconButton(
                          context,
                          Icons.privacy_tip,
                          'Privacy',
                          theme,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem(
    BuildContext context,
    IconData icon,
    String title,
    String description,
    ThemeData theme,
  ) {
    final secondaryColor = theme.colorScheme.secondary;
    final textTheme = theme.textTheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: secondaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: secondaryColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: textTheme.titleMedium?.copyWith(
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: textTheme.bodyMedium?.copyWith(
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIconButton(
    BuildContext context,
    IconData icon,
    String label,
    ThemeData theme,
  ) {
    final primaryColor = theme.primaryColor;
    final textTheme = theme.textTheme;

    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(15),
          ),
          child: IconButton(
            icon: Icon(icon, color: primaryColor),
            onPressed: () {
              // Action functionality
            },
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: textTheme.labelMedium?.copyWith(
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
