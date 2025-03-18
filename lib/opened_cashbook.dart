// ignore_for_file: deprecated_member_use

import 'package:brokecheck/app_themes.dart';
import 'package:brokecheck/cashbook.dart';
import 'package:brokecheck/donutchart.dart';
import 'package:brokecheck/entry.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Opendcashbook extends StatefulWidget {
  final Cashbook cashbook;

  const Opendcashbook({super.key, required this.cashbook});

  @override
  State<Opendcashbook> createState() => _OpendcashbookState();
}

class _OpendcashbookState extends State<Opendcashbook> {
  // Service to interact with transaction data
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Stream to get transactions for this cashbook
  Stream<QuerySnapshot> get _transactionsStream {
    return _firestore
        .collection('transactions')
        .where('cashbookId', isEqualTo: widget.cashbook.id)
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    // Get screen dimensions for responsive layout
    final Size screenSize = MediaQuery.of(context).size;
    final bool isSmallScreen = screenSize.width < 360;

    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final Color primaryColor = AppThemes.getPrimaryColor(isDarkMode);
    final Color secondaryTextColor =
        AppThemes.getSecondaryTextColor(isDarkMode);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.cashbook.name,
          overflow: TextOverflow.ellipsis,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(
              widget.cashbook.isFavorite
                  ? Icons.favorite
                  : Icons.favorite_border,
              color: widget.cashbook.isFavorite ? Colors.redAccent : null,
            ),
            onPressed: () {
              // Toggle favorite status
              final CashbookService cashbookService = CashbookService();
              cashbookService.toggleFavorite(widget.cashbook);
            },
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              // Show options menu
              showModalBottomSheet(
                context: context,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                backgroundColor: AppThemes.getCardColor(isDarkMode),
                builder: (context) =>
                    CashbookOptionsSheet(cashbook: widget.cashbook),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return RefreshIndicator(
              color: primaryColor,
              onRefresh: () async {
                // Implement refresh logic if needed
                await Future.delayed(const Duration(seconds: 1));
                setState(() {});
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight,
                  ),
                  child: Column(
                    children: [
                      // Balance card
                      Container(
                        width: double.infinity,
                        margin: EdgeInsets.symmetric(
                          horizontal: isSmallScreen ? 8 : 16,
                          vertical: isSmallScreen ? 8 : 16,
                        ),
                        padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
                        decoration: BoxDecoration(
                          gradient: AppThemes.getPrimaryGradient(isDarkMode),
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: primaryColor.withOpacity(0.2),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Current Balance",
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: isSmallScreen ? 14 : 16,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              NumberFormat.currency(
                                      locale: 'en_US',
                                      symbol: '\$',
                                      decimalDigits: 2)
                                  .format(widget.cashbook.balance),
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: isSmallScreen ? 24 : 32,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton.icon(
                                    icon: const Icon(Icons.remove, size: 16),
                                    label: FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: Text(
                                        "Withdraw",
                                        style: TextStyle(
                                          fontSize: isSmallScreen ? 12 : 14,
                                        ),
                                      ),
                                    ),
                                    onPressed: () {
                                      _showTransactionDialog(context,
                                          isDeposit: false);
                                    },
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: Colors.white,
                                      backgroundColor:
                                          Colors.white.withOpacity(0.2),
                                      padding: EdgeInsets.symmetric(
                                        vertical: isSmallScreen ? 8 : 12,
                                      ),
                                      side: const BorderSide(
                                          color: Colors.white60),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(width: isSmallScreen ? 6 : 10),
                                Expanded(
                                  child: OutlinedButton.icon(
                                    icon: const Icon(Icons.add, size: 16),
                                    label: FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: Text(
                                        "Deposit",
                                        style: TextStyle(
                                          fontSize: isSmallScreen ? 12 : 14,
                                        ),
                                      ),
                                    ),
                                    onPressed: () {
                                      _showTransactionDialog(context,
                                          isDeposit: true);
                                    },
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: Colors.white,
                                      backgroundColor:
                                          Colors.white.withOpacity(0.2),
                                      padding: EdgeInsets.symmetric(
                                        vertical: isSmallScreen ? 8 : 12,
                                      ),
                                      side: const BorderSide(
                                          color: Colors.white60),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Donut chart - adjust height based on screen size
                      SizedBox(
                        height: isSmallScreen ? 150 : 200,
                        child: const DonutChart(),
                      ),

                      // Transactions list
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: isSmallScreen ? 12 : 16,
                          vertical: isSmallScreen ? 4 : 8,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Recent Transactions",
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    fontSize: isSmallScreen ? 14 : null,
                                  ),
                            ),
                            TextButton(
                              onPressed: () {
                                // Navigate to full transaction history
                              },
                              child: Text(
                                "See All",
                                style: TextStyle(
                                  color: primaryColor,
                                  fontSize: isSmallScreen ? 12 : 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // List of transactions
                      StreamBuilder<QuerySnapshot>(
                        stream: _transactionsStream,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Center(
                              child: Padding(
                                padding: const EdgeInsets.all(24.0),
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      primaryColor),
                                ),
                              ),
                            );
                          }

                          if (!snapshot.hasData ||
                              snapshot.data!.docs.isEmpty) {
                            return Center(
                              child: Padding(
                                padding: const EdgeInsets.all(40.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.receipt_long,
                                      size: isSmallScreen ? 40 : 50,
                                      color:
                                          secondaryTextColor.withOpacity(0.5),
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      "No transactions yet",
                                      style: TextStyle(
                                        color: secondaryTextColor,
                                        fontSize: isSmallScreen ? 14 : 16,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      "Add your first transaction with the + button",
                                      style: TextStyle(
                                        color:
                                            secondaryTextColor.withOpacity(0.7),
                                        fontSize: isSmallScreen ? 12 : 14,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }

                          // For demonstration, show sample entries
                          // In a real app, you'd map the snapshot.data!.docs to Entry widgets
                          return ListView(
                            physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            padding: EdgeInsets.only(
                              bottom: isSmallScreen ? 60 : 80,
                              left: isSmallScreen ? 8 : 0,
                              right: isSmallScreen ? 8 : 0,
                            ),
                            children: [
                              Entry(
                                amount: 40,
                                title: "Salary",
                                entryDate: DateTime.now(),
                                entryTime: TimeOfDay.now(),
                              ),
                              Entry(
                                amount: -6,
                                title: "Coffee",
                                entryDate: DateTime.now()
                                    .subtract(const Duration(days: 1)),
                                entryTime: TimeOfDay.now(),
                              ),
                              Entry(
                                amount: 30,
                                title: "Freelance work",
                                entryDate: DateTime.now()
                                    .subtract(const Duration(days: 2)),
                                entryTime: TimeOfDay.now(),
                              ),
                              Entry(
                                amount: -15,
                                title: "Lunch",
                                entryDate: DateTime.now()
                                    .subtract(const Duration(days: 2)),
                                entryTime: TimeOfDay.now(),
                              ),
                              Entry(
                                amount: -25,
                                title: "Books",
                                entryDate: DateTime.now()
                                    .subtract(const Duration(days: 3)),
                                entryTime: TimeOfDay.now(),
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Show add transaction dialog
          _showTransactionDialog(context, isDeposit: true);
        },
        backgroundColor: primaryColor,
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showTransactionDialog(BuildContext context, {required bool isDeposit}) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final Color primaryColor = AppThemes.getPrimaryColor(isDarkMode);
    final TextEditingController amountController = TextEditingController();
    final TextEditingController descriptionController = TextEditingController();
    final Size screenSize = MediaQuery.of(context).size;
    final bool isSmallScreen = screenSize.width < 360;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppThemes.getCardColor(isDarkMode),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: isSmallScreen ? 12 : 16,
            right: isSmallScreen ? 12 : 16,
            top: 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                isDeposit ? "Add Deposit" : "Add Withdrawal",
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontSize: isSmallScreen ? 18 : 20,
                    ),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: amountController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: "Amount",
                  prefixIcon: Icon(isDeposit ? Icons.add : Icons.remove),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                decoration: InputDecoration(
                  labelText: "Description",
                  prefixIcon: const Icon(Icons.description),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  // Save transaction
                  if (amountController.text.isNotEmpty) {
                    final double amount = double.parse(amountController.text);
                    final double actualAmount = isDeposit ? amount : -amount;

                    // Update cashbook balance
                    final CashbookService cashbookService = CashbookService();
                    cashbookService.updateBalance(
                        widget.cashbook.id, actualAmount);

                    // Add transaction record
                    _firestore.collection('transactions').add({
                      'cashbookId': widget.cashbook.id,
                      'amount': actualAmount,
                      'description': descriptionController.text,
                      'timestamp': Timestamp.now(),
                    });

                    Navigator.pop(context);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  "Save",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }
}
