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
  bool isDebit;
  Map<String, dynamic> donutMap;
  double donutAmount;
  String donutLabel;

  Opendcashbook(
      {super.key,
      required this.cashbook,
      this.isDebit = true,
      this.donutMap = const {},
      this.donutAmount = 0,
      this.donutLabel = "Debit"});

  @override
  State<Opendcashbook> createState() => _OpendcashbookState();
}

class _OpendcashbookState extends State<Opendcashbook> {
  // Service to interact with transaction data
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Stream to get transactions for this cashbook
  Stream<QuerySnapshot> get _transactionsStream {
    return _firestore
        // .collection('transactions')
        // .where("cashbookId", isEqualTo: widget.cashbook.id)
        // // .orderBy('timestamp', descending: true)
        // .snapshots();
        .collection('Entries') //?Try this
        .where("CashbookID", isEqualTo: widget.cashbook.id)
        // .orderBy('timestamp', descending: true)
        .snapshots();
  }

  Future<Map<String, double>> getCategoryWiseSpending() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('Entries') //! Maybe BS
        .where("CashbookID", isEqualTo: widget.cashbook.id)
        .where("type", isEqualTo: "withdrawal") // Only withdrawals
        .get();

    Map<String, double> categorySpending = {};

    for (var doc in querySnapshot.docs) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

      String category = data['Category'] ?? 'Uncategorized';
      double amount = (data['Amount'] is int)
          ? (data['Amount'] as int).toDouble()
          : (data['Amount'] ?? 0.0);

      // Accumulate spending per category
      categorySpending[category] = (categorySpending[category] ?? 0.0) + amount;
    }

    // Sort the map by values in descending order
    var sortedEntries = categorySpending.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Map.fromEntries(sortedEntries); // Convert back to a Map
  }

  @override
  void initState() {
    super.initState();
    // Initialize with debit data
    widget.donutMap = widget.cashbook.debitCategoryMap;
    widget.donutAmount = widget.cashbook.debit;
    widget.donutLabel = "Debit";
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
    // widget.donutMap = widget.cashbook.debitCategoryMap;
    // widget.donutAmount = widget.cashbook.debit;

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
              setState(() {
                //* To change state for the Favorite toggle
                cashbookService.toggleFavorite(widget.cashbook);
                widget.cashbook.isFavorite = !widget.cashbook.isFavorite;
              });
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

                      GestureDetector(
                        onTap: () {
                          widget.isDebit = !widget.isDebit;
                          if (widget.isDebit == true) {
                            setState(() {
                              widget.donutMap =
                                  widget.cashbook.debitCategoryMap;
                              widget.donutAmount = widget.cashbook.debit;
                              widget.donutLabel = "Debit";
                            });
                          }
                          if (widget.isDebit == false) {
                            setState(() {
                              widget.donutMap =
                                  widget.cashbook.creditCategoryMap;
                              widget.donutAmount = widget.cashbook.credit;
                              widget.donutLabel = "Credit";
                            });
                          }
                        },
                        // child: getChart(widget.cashbook.debitCategoryMap,
                        //     widget.cashbook.debit),
                        child: getChart(widget.donutMap, widget.donutAmount,
                            widget.donutLabel),
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
                              // ignore: unrelated_type_equality_checks
                              snapshot.data!.docs.isEmpty ||
                              snapshot.data == Null) {
                            print(widget.cashbook.id);
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

                          // if (snapshot.hasData) {}
                          // Padding(
                          //   padding: EdgeInsets.symmetric(
                          //     horizontal: isSmallScreen ? 12 : 16,
                          //     vertical: isSmallScreen ? 4 : 8,
                          //   ),
                          //   child: Row(
                          //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          //     children: [
                          //       Text(
                          //         "Recent Transactions",
                          //         style: Theme.of(context)
                          //             .textTheme
                          //             .titleMedium
                          //             ?.copyWith(
                          //               fontSize: isSmallScreen ? 14 : null,
                          //             ),
                          //       ),
                          //       TextButton(
                          //         onPressed: () {
                          //           // Navigate to full transaction history
                          //         },
                          //         child: Text(
                          //           "See All",
                          //           style: TextStyle(
                          //             color: primaryColor,
                          //             fontSize: isSmallScreen ? 12 : 14,
                          //           ),
                          //         ),
                          //       ),
                          //     ],
                          //   ),
                          // );
                          // For demonstration, show sample entries
                          // In a real app, you'd map the snapshot.data!.docs to Entry widgets

                          final entries = snapshot.data!.docs;
                          return ListView.builder(
                            padding: EdgeInsets.only(
                              bottom: isSmallScreen ? 60 : 80,
                              left: isSmallScreen ? 8 : 0,
                              right: isSmallScreen ? 8 : 0,
                            ),
                            itemCount: entries.length,
                            physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemBuilder: (context, index) {
                              final doc = snapshot.data!.docs[index];
                              final data = doc.data() as Map<String, dynamic>;
                              return Entry(
                                  amount: (data['Amount'] as num).toDouble(),
                                  title: widget.cashbook.id,
                                  entryDate: DateTime.now(),
                                  entryTime: TimeOfDay.now());
                            },
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
      bottomNavigationBar: BottomAppBar(
        child: Row(
          children: [
            Expanded(
                child: ElevatedButton(
                    onPressed: () async {
                      // Create a non-null map with the required data
                      Map<String, dynamic> cashbookData = {
                        'id': widget.cashbook.id,
                        'balance': widget.cashbook.balance,
                        'debit': widget.cashbook.debit,
                        'credit': widget.cashbook.credit,
                        'debitCategoryMap': widget.cashbook.debitCategoryMap,
                      };

                      final result = await Navigator.pushNamed(
                        context,
                        '/withdraw',
                        arguments: cashbookData,
                      );
                      if (result is Map && result['result'] == true) {
                        setState(() {
                          widget.cashbook.balance = result['newBalance'];
                          widget.cashbook.debit = result['newDebit'];
                          widget.cashbook.debitCategoryMap =
                              result['newCategoryMap'];
                        });
                      }
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.remove,
                          color: Colors.white,
                        ),
                        SizedBox(
                          width: isSmallScreen ? 4 : 8,
                        ),
                        Text("Withdraw"),
                      ],
                    ))),
            SizedBox(
              width: isSmallScreen ? 4 : 8,
            ),
            Expanded(
                child: ElevatedButton(
                    onPressed: () async {
                      // Create a non-null map with the required data
                      Map<String, dynamic> cashbookData = {
                        'id': widget.cashbook.id,
                        'balance': widget.cashbook.balance,
                        'debit': widget.cashbook.debit,
                        'credit': widget.cashbook.credit,
                        'creditCategoryMap': widget.cashbook.creditCategoryMap,
                      };

                      final result = await Navigator.pushNamed(
                        context,
                        '/deposit',
                        arguments: cashbookData,
                      );
                      if (result is Map && result['result'] == true) {
                        setState(() {
                          widget.cashbook.balance = result['newBalance'];
                          widget.cashbook.credit = result['newCredit'];
                        });
                      }
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add,
                          color: Colors.white,
                        ),
                        SizedBox(
                          width: isSmallScreen ? 4 : 8,
                        ),
                        Text("Deposit"),
                      ],
                    ))),
          ],
        ),
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
                    // _firestore.collection('transactions').add({
                    //   'cashbookId': widget.cashbook.id,
                    //   'amount': actualAmount,
                    //   'description': descriptionController.text,
                    //   'timestamp': Timestamp.now(),
                    // });
                    _firestore.collection('Entries').add({
                      'CashbookID': widget.cashbook.id, //?Try this
                      'Total_Amount': actualAmount,
                      'Description': descriptionController.text,
                      'Creation_Date': Timestamp.now(),
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

  Map<String, dynamic> transformCategoryMap(Map<String, dynamic> categoryMap) {
    // If categoryMap is empty, return default values
    if (categoryMap.isEmpty) {
      return {
        'sorted string list': ['Others'],
        'sorted amount list': [0.0],
        'sorted percentage list': [100]
      };
    }

    // Sort the categoryMap by values in descending order
    var sortedEntries = categoryMap.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    // Calculate total amount with safe zero handling
    double totalAmount = sortedEntries.fold(0.0, (sum, entry) {
      // Ensure we're using a double and handling potential null/invalid values
      return sum + (entry.value is num ? entry.value.toDouble() : 0.0);
    });

    // Prevent division by zero
    if (totalAmount <= 0) {
      return {
        'sorted string list': [
          'Transportion',
          'Essentials',
          'Food & Dining',
          'Others'
        ],
        'sorted amount list': [0.0, 0.0, 0.0, 0.0],
        'sorted percentage list': [0, 0, 0, 0]
      };
    }

    // Prepare lists for top 3 categories and others
    List<String> sortedStringList = [];
    List<double> sortedAmountList = [];
    List<int> sortedPercentageList = [];

    // Process top 3 categories
    for (int i = 0; i < min(3, sortedEntries.length); i++) {
      sortedStringList.add(sortedEntries[i].key);

      // Safely convert to double
      double entryValue = sortedEntries[i].value is num
          ? sortedEntries[i].value.toDouble()
          : 0.0;

      sortedAmountList.add(entryValue);

      // Safely calculate percentage
      int percentage = ((entryValue / totalAmount) * 100).round();
      sortedPercentageList.add(percentage);
    }

    // Add 'Others' category
    if (sortedEntries.length > 3) {
      sortedStringList.add('Others');

      // Calculate the sum of remaining categories
      double remainingAmount = sortedEntries.skip(3).fold(0.0, (sum, entry) {
        return sum + (entry.value is num ? entry.value.toDouble() : 0.0);
      });

      sortedAmountList.add(remainingAmount);

      // Calculate remaining percentage
      int remainingPercentage =
          100 - sortedPercentageList.reduce((a, b) => a + b);
      sortedPercentageList.add(remainingPercentage);
    }

    // Ensure percentage list adds up to 100
    int currentSum = sortedPercentageList.reduce((a, b) => a + b);
    if (currentSum != 100) {
      // Adjust the last entry to make sure total is 100%
      sortedPercentageList[sortedPercentageList.length - 1] +=
          (100 - currentSum);
    }

    return {
      'sorted string list': sortedStringList,
      'sorted amount list': sortedAmountList,
      'sorted percentage list': sortedPercentageList
    };
  }

// Utility function to get minimum of two numbers
  int min(int a, int b) => a < b ? a : b;

  Widget getChart(
      Map<String, dynamic> catMap, double debitAmount, String donutType) {
    Map<String, dynamic> formattedMap = transformCategoryMap(catMap);
    print(catMap);
    print(formattedMap);
    if (debitAmount > 0) {
      return DonutChart(
        labelList: formattedMap['sorted string list'],
        amountList: formattedMap['sorted amount list'],
        percentageList: formattedMap['sorted percentage list'],
        centreAmount: debitAmount,
        centreLabel: donutType,
      );
    }
    return SizedBox(
      child: Container(
        color: Colors.red,
        height: 0.0001,
      ),
    );
  }
}
