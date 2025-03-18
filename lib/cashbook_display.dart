// ignore_for_file: deprecated_member_use

import 'package:brokecheck/app_themes.dart';
import 'package:brokecheck/cashbook.dart';
import 'package:brokecheck/opened_cashbook.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';

class CashbooksSection extends StatefulWidget {
  const CashbooksSection({super.key});

  @override
  State<CashbooksSection> createState() => _CashbooksSectionState();
}

class _CashbooksSectionState extends State<CashbooksSection> {
  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final bool isSmallScreen = screenSize.width < 600;
    final double horizontalPadding = isSmallScreen ? 12.0 : 24.0;
    final brightness = Theme.of(context).brightness;
    final bool isDarkMode = brightness == Brightness.dark;
    final theme = Theme.of(context);

    return Column(
      children: [
        // Divider before Cashbooks section
        Container(
          height: 1,
          color: AppThemes.getSecondaryTextColor(isDarkMode).withOpacity(0.5),
          margin: EdgeInsets.symmetric(horizontal: horizontalPadding),
        ),

        const SizedBox(height: 24),
        // Cashbook section
        Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Cashbooks',
                style: TextStyle(
                  fontSize: isSmallScreen ? 16 : 18,
                  fontFamily: 'poppy',
                  fontWeight: FontWeight.bold,
                  color: AppThemes.getTextColor(isDarkMode),
                ),
              ),
              Row(
                children: [
                  IconButton(
                    onPressed: () {
                      // Show filter dialog
                      _showFilterDialog(context);
                    },
                    icon: const Icon(Icons.filter_list),
                    iconSize: isSmallScreen ? 24 : 30,
                    color: AppThemes.getPrimaryColor(isDarkMode),
                    tooltip: 'Filter cashbooks',
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: () {
                      // Show search dialog
                      _showSearchDialog(context);
                    },
                    icon: const Icon(Icons.search),
                    iconSize: isSmallScreen ? 24 : 30,
                    color: AppThemes.getPrimaryColor(isDarkMode),
                    tooltip: 'Search cashbooks',
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('cashbook data')
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              final cashbooks = snapshot.data!.docs;
              return cashbooks.isEmpty
                  ? _buildEmptyCashbooksList(isDarkMode, theme)
                  : Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: horizontalPadding),
                      child: ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: cashbooks.length,
                        itemBuilder: (context, index) {
                          final cashbookData =
                              cashbooks[index].data() as Map<String, dynamic>;
                          final docId = cashbooks[index].id;
                          return CashbookListItem(
                            cashbookData: cashbookData,
                            isSmallScreen: isSmallScreen,
                            docId: docId,
                            onFavoriteToggle: () =>
                                _toggleFavorite(docId, cashbookData),
                            isDarkMode: isDarkMode,
                          );
                        },
                      ),
                    );
            } else if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Column(
                    children: [
                      Icon(Icons.error_outline,
                          size: 40, color: AppThemes.getErrorColor(isDarkMode)),
                      const SizedBox(height: 8),
                      Text(
                        'Error loading cashbooks',
                        style: TextStyle(
                          color: AppThemes.getErrorColor(isDarkMode),
                          fontSize: 16,
                          fontFamily: 'poppylight',
                        ),
                      ),
                    ],
                  ),
                ),
              );
            } else {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 32.0),
                  child: CircularProgressIndicator(
                    color: AppThemes.getPrimaryColor(isDarkMode),
                  ),
                ),
              );
            }
          },
        ),
      ],
    );
  }

  Widget _buildEmptyCashbooksList(bool isDarkMode, ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 32.0),
        child: Column(
          children: [
            Icon(
              Icons.account_balance_wallet_outlined,
              size: 60,
              color: AppThemes.getSecondaryTextColor(isDarkMode),
            ),
            SizedBox(height: 16),
            Text(
              'No cashbooks found',
              style: TextStyle(
                fontSize: 18,
                fontFamily: 'poppy',
                fontWeight: FontWeight.bold,
                color: AppThemes.getSecondaryTextColor(isDarkMode),
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Tap the "Add Cashbook" button to create one',
              style: TextStyle(
                fontSize: 14,
                fontFamily: 'poppylight',
                color: AppThemes.getSecondaryTextColor(isDarkMode),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Add method to toggle favorite status
  Future<void> _toggleFavorite(
      String docId, Map<String, dynamic> cashbookData) async {
    final bool currentStatus = cashbookData['isFavorite'] ?? false;

    await FirebaseFirestore.instance
        .collection('cashbook data')
        .doc(docId)
        .update({'isFavorite': !currentStatus});
  }

  void _showFilterDialog(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final bool isDarkMode = brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(20),
        color: AppThemes.getCardColor(isDarkMode),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Filter Cashbooks',
              style: TextStyle(
                fontSize: 18,
                fontFamily: 'poppy',
                fontWeight: FontWeight.bold,
                color: AppThemes.getTextColor(isDarkMode),
              ),
            ),
            SizedBox(height: 20),
            // Filter options would go here
            ListTile(
              leading: Icon(Icons.sort_by_alpha,
                  color: AppThemes.getPrimaryColor(isDarkMode)),
              title: Text('Sort by name',
                  style: TextStyle(
                    fontFamily: 'poppylight',
                    color: AppThemes.getTextColor(isDarkMode),
                  )),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: Icon(Icons.date_range,
                  color: AppThemes.getPrimaryColor(isDarkMode)),
              title: Text('Sort by date',
                  style: TextStyle(
                    fontFamily: 'poppylight',
                    color: AppThemes.getTextColor(isDarkMode),
                  )),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: Icon(Icons.attach_money,
                  color: AppThemes.getPrimaryColor(isDarkMode)),
              title: Text('Sort by amount',
                  style: TextStyle(
                    fontFamily: 'poppylight',
                    color: AppThemes.getTextColor(isDarkMode),
                  )),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  void _showSearchDialog(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final bool isDarkMode = brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        backgroundColor: AppThemes.getCardColor(isDarkMode),
        title: Text(
          'Search Cashbooks',
          style: TextStyle(
            fontFamily: 'poppy',
            fontWeight: FontWeight.bold,
            color: AppThemes.getTextColor(isDarkMode),
          ),
        ),
        content: TextField(
          decoration: InputDecoration(
            hintText: 'Enter cashbook name',
            prefixIcon: Icon(Icons.search,
                color: AppThemes.getPrimaryColor(isDarkMode)),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          autofocus: true,
          style: TextStyle(
            fontFamily: 'poppylight',
            color: AppThemes.getTextColor(isDarkMode),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style:
                  TextStyle(color: AppThemes.getSecondaryTextColor(isDarkMode)),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppThemes.getPrimaryColor(isDarkMode),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              'Search',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

class CashbookListItem extends StatelessWidget {
  final Map<String, dynamic> cashbookData;
  final bool isSmallScreen;
  final String docId;
  final VoidCallback onFavoriteToggle;
  final bool isDarkMode;

  const CashbookListItem({
    super.key,
    required this.cashbookData,
    this.isSmallScreen = false,
    required this.docId,
    required this.onFavoriteToggle,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    final iconData = IconData(
      cashbookData['icon'] ?? Icons.account_balance_wallet.codePoint,
      fontFamily: 'MaterialIcons',
    );
    final cashbookName = cashbookData['name'] ?? 'Unnamed Cashbook';
    final createdAt = cashbookData['created_at'];
    final formattedDate = createdAt != null
        ? DateFormat('MMM d, yyyy').format(createdAt.toDate())
        : 'N/A';
    final isFavorite = cashbookData['isFavorite'] ?? false;
    final balance = cashbookData['balance'] ?? 0;
    final formattedBalance = balance > 0 ? '+$balance' : '$balance';
    final balanceColor = balance >= 0
        ? isDarkMode
            ? Colors.green[300]
            : const Color.fromARGB(255, 15, 94, 18) // Green for positive
        : isDarkMode
            ? Colors.red[300]
            : Colors.red[700]; // Red for negative

    return Slidable(
      // Slidable actions
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        extentRatio: 0.7, // Make the sliding area larger
        children: [
          // Favorite action
          Flexible(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2.0),
              child: SlidableAction(
                onPressed: (context) {
                  // Toggle favorite status
                  onFavoriteToggle();
                },
                borderRadius: BorderRadius.circular(15),
                padding: EdgeInsets.zero, // Remove default padding
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                icon: isFavorite ? Icons.favorite : Icons.favorite_border,
                label: isFavorite ? 'Unfavorite' : 'Favorite',
              ),
            ),
          ),

          // Delete action
          Flexible(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: SlidableAction(
                onPressed: (context) {
                  // Show delete confirmation
                  _showDeleteConfirmation(context);
                },
                borderRadius: BorderRadius.circular(15),
                padding: EdgeInsets.zero, // Remove default padding
                backgroundColor: AppThemes.getErrorColor(isDarkMode),
                foregroundColor: Colors.white,
                icon: Icons.delete,
                label: 'Delete',
              ),
            ),
          ),
        ],
      ),

      child: Card(
        elevation: 1.5, // Reduced elevation for a more subtle look
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
              color:
                  AppThemes.getSecondaryTextColor(isDarkMode).withOpacity(0.2),
              width: 1), // Added border with theme color
        ),
        color: AppThemes.getCardColor(isDarkMode),
        child: InkWell(
          onTap: () {
            // Navigate to cashbook details with the docId
            final cashbook = Cashbook(
              id: docId,
              name: cashbookData['name'] ?? 'Unnamed Cashbook',
              balance: cashbookData['balance'] ?? 0.0,
              isFavorite: cashbookData['isFavorite'] ?? false,
              iconCodePoint: cashbookData['icon'] ??
                  Icons.account_balance_wallet.codePoint,
              createdAt: cashbookData['created_at'] != null
                  ? cashbookData['created_at'].toDate()
                  : DateTime.now(),
              // Include any other properties your Cashbook class requires
            );

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => Opendcashbook(cashbook: cashbook),
              ),
            );
          },
          borderRadius: BorderRadius.circular(16),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppThemes.getPrimaryColor(isDarkMode)
                            .withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(iconData,
                          color: AppThemes.getPrimaryColor(isDarkMode),
                          size: isSmallScreen ? 24 : 32),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            cashbookName,
                            style: TextStyle(
                              fontSize: isSmallScreen ? 14 : 16,
                              fontFamily: 'poppy',
                              fontWeight: FontWeight.bold,
                              color: AppThemes.getTextColor(isDarkMode),
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(Icons.calendar_today,
                                  size: 12,
                                  color: AppThemes.getSecondaryTextColor(
                                      isDarkMode)),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  formattedDate,
                                  style: TextStyle(
                                    fontSize: isSmallScreen ? 12 : 14,
                                    fontFamily: 'poppylight',
                                    color: AppThemes.getSecondaryTextColor(
                                        isDarkMode),
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Replaced heart icon with centered amount display
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: balanceColor?.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        formattedBalance,
                        style: TextStyle(
                          fontSize: isSmallScreen ? 14 : 16,
                          fontFamily: 'poppy',
                          fontWeight: FontWeight.bold,
                          color: balanceColor,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
              // Add a bottom divider within the card
              Container(
                height: 1,
                color: AppThemes.getSecondaryTextColor(isDarkMode)
                    .withOpacity(0.2),
                margin: const EdgeInsets.symmetric(horizontal: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final bool isDarkMode = brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppThemes.getCardColor(isDarkMode),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          'Delete Cashbook',
          style: TextStyle(
            fontFamily: 'poppy',
            fontWeight: FontWeight.bold,
            color: AppThemes.getTextColor(isDarkMode),
          ),
        ),
        content: Text(
          'Are you sure you want to delete "${cashbookData['name']}"? This action cannot be undone.',
          style: TextStyle(
            fontFamily: 'poppylight',
            color: AppThemes.getTextColor(isDarkMode),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style:
                  TextStyle(color: AppThemes.getSecondaryTextColor(isDarkMode)),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              // Delete the cashbook
              FirebaseFirestore.instance
                  .collection('cashbook data')
                  .doc(docId)
                  .delete();
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppThemes.getErrorColor(isDarkMode),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
