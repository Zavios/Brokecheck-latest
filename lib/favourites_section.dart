// ignore_for_file: deprecated_member_use

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FavoritesSection extends StatelessWidget {
  const FavoritesSection({super.key});

  @override
  Widget build(BuildContext context) {
    // Get theme values
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).primaryColor;
    final textTheme = Theme.of(context).textTheme;
    final FirebaseAuth auth = FirebaseAuth.instance; //? Is this the correct way
    final User? currentUser = auth.currentUser; //? Is this the correct way

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                'Your Favourites',
                style: textTheme.titleMedium?.copyWith(
                  fontSize: 20,
                  color: isDarkMode ? Colors.white70 : Colors.black54,
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.star, color: Colors.amber, size: 20),
            ],
          ),
        ),
        SizedBox(
          height: 190, // Reduced height to avoid overflow
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                // .collection('cashbook data')
                // .where('isFavorite', isEqualTo: true)
                // .where('userId', isEqualTo: currentUser?.uid)
                // .snapshots(),
                .collection('Cashbooks') //?Try this
                .where('If_Fav', isEqualTo: true)
                .where('UserID', isEqualTo: currentUser?.uid)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(
                    color: primaryColor,
                  ),
                );
              }

              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    'Error loading favorites',
                    style: textTheme.bodyMedium?.copyWith(
                      color: Colors.red,
                    ),
                  ),
                );
              }

              final favoriteCashbooks = snapshot.data?.docs ?? [];

              if (favoriteCashbooks.isEmpty) {
                return _buildEmptyFavorites(context);
              }

              return Stack(
                children: [
                  PageView.builder(
                    itemCount: favoriteCashbooks.length,
                    controller: PageController(viewportFraction: 0.95),
                    itemBuilder: (context, index) {
                      // Include document ID in the data
                      final cashbookDoc = favoriteCashbooks[index];
                      final cashbookData = {
                        ...cashbookDoc.data() as Map<String, dynamic>,
                        'id': cashbookDoc.id, // Add document ID
                      };

                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: _buildFullScreenFavoriteCard(
                          context,
                          cashbookData,
                        ),
                      );
                    },
                  ),
                  // Page indicator at bottom
                  Positioned(
                    bottom: 5,
                    left: 0,
                    right: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        favoriteCashbooks.length,
                        (index) => Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: index == 0
                                ? primaryColor
                                : (isDarkMode
                                    ? Colors.grey.shade700
                                    : Colors.grey.shade400),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyFavorites(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(vertical: 12), // Reduced padding
      decoration: BoxDecoration(
        color: isDarkMode
            ? Colors.grey.shade800.withOpacity(0.3)
            : Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min, // Keep column size minimal
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.star_border,
              size: 42, // Reduced from 48
              color: isDarkMode ? Colors.grey.shade500 : Colors.grey,
            ),
            const SizedBox(height: 8), // Reduced space
            Text(
              'No favorites yet',
              style: textTheme.bodyLarge?.copyWith(
                fontSize: 16, // Reduced from 18
                color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Add cashbooks to favorites to see them here',
              style: textTheme.bodyMedium?.copyWith(
                fontSize: 13, // Reduced from 14
                color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFullScreenFavoriteCard(
      BuildContext context, Map<String, dynamic> cashbookData) {
    // final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    // final textTheme = Theme.of(context).textTheme;

    // final cashbookName = cashbookData['name'] ?? 'Unnamed Cashbook';
    // final balance = cashbookData['balance'] ?? 0;
    // final formattedBalance = balance > 0 ? '+$balance' : '$balance';
    // final balanceColor = balance >= 0
    //     ? isDarkMode
    //         ? const Color(0xFF66BB6A)
    //         : const Color.fromARGB(255, 15, 94, 18) // Green for positive
    //     : isDarkMode
    //         ? Colors.red[400]
    //         : Colors.red[700]; // Red for negative

    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textTheme = Theme.of(context).textTheme;

    final cashbookName = cashbookData['Cashbook_Name'] ?? 'Unnamed Cashbook';
    final balance = cashbookData['Total_Amount'] ?? 0.0;
    final formattedBalance = balance > 0 ? '+$balance' : '$balance';
    final balanceColor = balance >= 0
        ? isDarkMode
            ? const Color(0xFF66BB6A)
            : const Color.fromARGB(255, 15, 94, 18) // Green for positive
        : isDarkMode
            ? Colors.red[400]
            : Colors.red[700]; // Red for negative

    return Container(
      margin: const EdgeInsets.only(bottom: 15, top: 5),
      decoration: BoxDecoration(
        color: isDarkMode
            ? const Color(0xFF1E3A2B) // Darker green for dark mode
            : Colors.greenAccent[100],
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDarkMode ? 0.2 : 0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card header with name and options
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    cashbookName,
                    style: textTheme.titleMedium?.copyWith(
                      fontSize: 18,
                      color: isDarkMode ? Colors.white : Colors.black87,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
                Icon(
                  Icons.more_vert,
                  color: isDarkMode ? Colors.white70 : Colors.black54,
                  size: 22,
                ),
              ],
            ),
          ),

          // Balance amount
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Text(
              formattedBalance,
              style: textTheme.titleLarge?.copyWith(
                fontSize: 42,
                color: balanceColor,
              ),
            ),
          ),

          const Spacer(flex: 1),

          // Action buttons
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 12.0),
            child: SizedBox(
              height: 36, // Fixed height for button container
              child: Row(
                children: [
                  Expanded(
                    child: _buildActionButton(
                      context: context,
                      label: "Withdraw",
                      icon: Icons.remove,
                      onPressed: () async {
                        // Navigate to Withdraw screen with cashbook data
                        final result = await Navigator.pushNamed(
                          context,
                          '/withdraw',
                          arguments: cashbookData,
                        );

                        // Refresh if needed (optional)
                        if (result == true) {
                          // You could add additional refresh logic here if needed
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: _buildActionButton(
                      context: context,
                      label: "Deposit",
                      icon: Icons.add,
                      onPressed: () {
                        Navigator.pushNamed(
                          context,
                          '/deposit',
                          arguments: cashbookData,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required BuildContext context,
    required String label,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return SizedBox(
      height: 36,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isDarkMode
              ? const Color(0xFF2E7D32) // Dark theme primary color
              : const Color.fromARGB(255, 30, 30, 30),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
          minimumSize: Size.zero, // Allow button to be smaller than default
          tapTargetSize:
              MaterialTapTargetSize.shrinkWrap, // Reduce the tap target size
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 14),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.white,
                  fontFamily: 'poppy',
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
