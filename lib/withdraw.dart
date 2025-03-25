// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Withdraw extends StatefulWidget {
  final Map<String, dynamic>? cashbookData;

  const Withdraw({super.key, this.cashbookData});

  @override
  State<Withdraw> createState() => _WithdrawState();
}

class _WithdrawState extends State<Withdraw> {
  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();
  int? selectedIndex; // For tracking selected payment mode
  int? selectedCategoryIndex; // For tracking selected category

  // Controllers for input fields
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  final List<String> paymentModes = ["Cash", "Online", "Card"];
  final List<String> categories = [
    "Essentials",
    "Transportation",
    "Food & Dining",
    "Shopping",
    "Entertainment",
    "Health & Wellness",
    "Education",
    "Debt & Loans",
    "Savings & Investments",
    "Travel",
    "Others"
  ];
  bool _isProcessing = false;

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime() async {
    TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedTime,
    );

    if (picked != null) {
      setState(() {
        selectedTime = picked;
      });
    }
  }

  // Method to save withdrawal to Firestore
  Future<void> _saveWithdrawal({bool addMore = false}) async {
    // Validate required fields
    if (_amountController.text.isEmpty ||
        !widget.cashbookData!.containsKey('id')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter an amount')),
      );
      return;
    }

    if (selectedCategoryIndex == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a category')),
      );
      return;
    }

    // Get amount as a double
    final double amount = double.tryParse(_amountController.text) ?? 0;
    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid amount')),
      );
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      final cashbookId = widget.cashbookData!['id'];
      final currentBalance = widget.cashbookData!['balance'] ?? 0;
      final currentDebit = widget.cashbookData!['debit'] ?? 0.0;
      final currentCredit = widget.cashbookData!['credit'] ?? 0.0;
      print("");
      print(currentCredit);
      print(currentDebit);
      print(currentBalance);

      // Create a combined date/time
      final DateTime combinedDateTime = DateTime(
        selectedDate.year,
        selectedDate.month,
        selectedDate.day,
        selectedTime.hour,
        selectedTime.minute,
      );

      // 1. Add transaction record

      // await FirebaseFirestore.instance.collection('transactions').add({
      //   'cashbookId': cashbookId,
      //   'amount': -amount, // Negative for withdrawal
      //   'category': categories[selectedCategoryIndex!],
      //   'description': _descriptionController.text,
      //   'date': Timestamp.fromDate(combinedDateTime),
      //   'paymentMode':
      //       selectedIndex != null ? paymentModes[selectedIndex!] : 'Cash',
      //   'type': 'withdrawal',
      //   'createdAt': FieldValue.serverTimestamp(),
      // });

      await FirebaseFirestore.instance.collection('Entries').add({
        //?Try this
        'CashbookID': cashbookId,
        'Amount': -amount, // Negative for withdrawal
        'category': categories[selectedCategoryIndex!],
        'Description': _descriptionController.text,
        'date': Timestamp.fromDate(combinedDateTime),
        'paymentMode':
            selectedIndex != null ? paymentModes[selectedIndex!] : 'Cash',
        'type': 'withdrawal',
        'Creation_Date': FieldValue.serverTimestamp(),
      });
      // 2. Update cashbook balance
      // await FirebaseFirestore.instance
      //     .collection('cashbook data')
      //     .doc(cashbookId)
      //     .update({
      //   'balance': currentBalance - amount,
      //   'lastTransactionDate': Timestamp.fromDate(DateTime.now()),
      // });
      final double newDebit = currentDebit + amount;
      final double newBalance = currentBalance - amount;

      await FirebaseFirestore.instance
          .collection('Cashbooks')
          .doc(cashbookId)
          .update({
        'Total_Credit': currentCredit,
        'Total_Debit': newDebit,
        'Total_Amount': newBalance, // Directly update with new balance
        'LastTransactionDate': FieldValue.serverTimestamp(),
      });

      if (!addMore) {
        // Navigator.pop(context, true); // Return success
        Navigator.pop(context, {'result': true, 'newBalance': newBalance});
      } else {
        // Reset form for adding more
        _amountController.clear();
        _descriptionController.clear();
        setState(() {
          selectedCategoryIndex = null;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Withdrawal saved successfully')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // ignore: unused_local_variable
    final isDark = theme.brightness == Brightness.dark;

    // Check if cashbook data is available
    if (widget.cashbookData == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: const Center(child: Text('No cashbook selected')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Withdraw from Cashbook",
          style: theme.appBarTheme.titleTextStyle,
        ),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.chevron_left,
            size: 40,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(2.0),
          child: Container(
            color: theme.dividerTheme.color,
            height: 1.0,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Selected Cashbook Info
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.account_balance_wallet,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.cashbookData!['name'] ?? 'Cashbook',
                          style: theme.textTheme.titleMedium,
                        ),
                        Text(
                          'Current Balance: ${widget.cashbookData!['balance']}',
                          style: theme.textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Amount Input
            _buildInputField(
              "Amount",
              theme,
              controller: _amountController,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),

            // Category Selection
            Text(
              'Category',
              style: theme.textTheme.labelMedium,
            ),
            const SizedBox(height: 10),

            // Category Chips
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: List.generate(categories.length, (index) {
                return ChoiceChip(
                  label: Text(
                    categories[index],
                    style: TextStyle(
                      color: selectedCategoryIndex == index
                          ? theme.colorScheme.onPrimary
                          : theme.colorScheme.primary,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  selected: selectedCategoryIndex == index,
                  onSelected: (selected) {
                    setState(() {
                      selectedCategoryIndex = selected ? index : null;
                    });
                  },
                  selectedColor: theme.colorScheme.primary,
                  backgroundColor: theme.colorScheme.primary.withOpacity(0.2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                );
              }),
            ),
            const SizedBox(height: 20),

            // Description Input
            _buildInputField("Description", theme,
                controller: _descriptionController),
            const SizedBox(height: 20),

            // Date & Time Pickers
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Date Picker
                _buildDateTimePicker(
                  icon: Icons.calendar_month,
                  value:
                      "${selectedDate.day}/${selectedDate.month}/${selectedDate.year}",
                  onTap: _selectDate,
                  theme: theme,
                ),

                // Time Picker
                _buildDateTimePicker(
                  icon: Icons.access_time,
                  value: selectedTime.format(context),
                  onTap: _selectTime,
                  theme: theme,
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Payment Mode Label
            Text(
              'Payment Mode',
              style: theme.textTheme.labelMedium,
            ),
            const SizedBox(height: 10),

            // Payment Mode Selection
            Wrap(
              spacing: 10,
              children: List.generate(paymentModes.length, (index) {
                return ChoiceChip(
                  label: Text(
                    paymentModes[index],
                    style: TextStyle(
                      color: selectedIndex == index
                          ? theme.colorScheme.onPrimary
                          : theme.colorScheme.primary,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  selected: selectedIndex == index,
                  onSelected: (selected) {
                    setState(() {
                      selectedIndex = selected ? index : null;
                    });
                  },
                  selectedColor: theme.colorScheme.primary,
                  backgroundColor: theme.colorScheme.primary.withOpacity(0.2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                );
              }),
            ),
            const SizedBox(height: 40),

            // Save Buttons
            Center(
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  _buildSaveButton(
                    icon: Icons.check,
                    label: "Save",
                    onPressed: _isProcessing ? null : () => _saveWithdrawal(),
                    theme: theme,
                    isLoading: _isProcessing,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to build input fields
  Widget _buildInputField(
    String label,
    ThemeData theme, {
    TextEditingController? controller,
    TextInputType? keyboardType,
  }) {
    return SizedBox(
      height: 60,
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: theme.textTheme.bodyMedium,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: theme.inputDecorationTheme.labelStyle,
          focusedBorder: theme.inputDecorationTheme.focusedBorder,
          enabledBorder: theme.inputDecorationTheme.enabledBorder,
          border: theme.inputDecorationTheme.border,
          filled: theme.inputDecorationTheme.filled,
          fillColor: theme.inputDecorationTheme.fillColor,
          floatingLabelStyle: TextStyle(
            color: theme.colorScheme.primary,
            fontFamily: 'poppy',
          ),
        ),
      ),
    );
  }

  // Helper method to build date/time pickers with dropdown arrow
  Widget _buildDateTimePicker({
    required IconData icon,
    required String value,
    required VoidCallback onTap,
    required ThemeData theme,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, color: theme.colorScheme.secondary, size: 20),
          const SizedBox(width: 8),
          Text(
            value,
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(width: 4),
          Icon(
            Icons.arrow_drop_down,
            color: theme.colorScheme.secondary,
            size: 20,
          ),
        ],
      ),
    );
  }

  // Helper method to build save buttons
  Widget _buildSaveButton({
    required IconData icon,
    required String label,
    required VoidCallback? onPressed,
    required ThemeData theme,
    bool isLoading = false,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(350, 60),
        foregroundColor: theme.colorScheme.onPrimary,
        backgroundColor: theme.colorScheme.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      icon: isLoading
          ? SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                color: theme.colorScheme.onPrimary,
                strokeWidth: 2,
              ),
            )
          : Icon(icon, size: 35, color: theme.colorScheme.onPrimary),
      label: Text(
        label,
        style: TextStyle(
          fontSize: 20,
          fontFamily: 'poppy',
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
