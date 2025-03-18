// ignore_for_file: deprecated_member_use, avoid_print

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Deposit extends StatefulWidget {
  final Map<String, dynamic>? cashbookData;

  const Deposit({super.key, this.cashbookData});

  @override
  State<Deposit> createState() => _DepositState();
}

class _DepositState extends State<Deposit> {
  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();
  int? selectedPaymentIndex; // For tracking selected payment mode
  int? selectedCategoryIndex; // For tracking selected category
  final TextEditingController amountController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  final List<String> paymentModes = ["Cash", "Online", "Card"];

  bool isProcessing = false;

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

  // Function to save deposit transaction to Firestore
  Future<void> _saveDeposit({bool addMore = false}) async {
    // Validate inputs
    if (amountController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter an amount')),
      );
      return;
    }

    if (selectedPaymentIndex == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a payment mode')),
      );
      return;
    }

    if (widget.cashbookData == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cashbook data not available')),
      );
      return;
    }

    setState(() {
      isProcessing = true;
    });

    try {
      // Get the amount as a double value
      final double amount = double.parse(amountController.text);
      final String cashbookId = widget.cashbookData!['id'] ?? '';

      // Create a timestamp for the transaction
      final DateTime transactionDateTime = DateTime(
        selectedDate.year,
        selectedDate.month,
        selectedDate.day,
        selectedTime.hour,
        selectedTime.minute,
      );

      // Create transaction data
      final transactionData = {
        'amount': amount,
        'description': descriptionController.text,
        'paymentMode': paymentModes[selectedPaymentIndex!],
        'type': 'deposit',
        'timestamp': Timestamp.fromDate(transactionDateTime),
        'cashbookId': cashbookId,
      };

      // Add transaction to transactions collection
      await FirebaseFirestore.instance
          .collection('transactions')
          .add(transactionData);

      // Update cashbook balance
      final DocumentReference cashbookRef = FirebaseFirestore.instance
          .collection('cashbook data')
          .doc(cashbookId);

      // Get current cashbook data
      final DocumentSnapshot cashbookDoc = await cashbookRef.get();
      final currentData = cashbookDoc.data() as Map<String, dynamic>?;

      if (currentData != null) {
        final double currentBalance = (currentData['balance'] ?? 0).toDouble();
        final double newBalance = currentBalance + amount;

        // Update the balance
        await cashbookRef.update({
          'balance': newBalance,
          'updatedAt': Timestamp.now(),
        });
      }

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Deposit saved successfully')),
        );
      }

      // Clear form if adding more, otherwise navigate back
      if (addMore) {
        _resetForm();
      } else {
        if (mounted) {
          Navigator.pop(context);
        }
      }
    } catch (e) {
      print('Error saving deposit: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isProcessing = false;
        });
      }
    }
  }

  // Reset form fields
  void _resetForm() {
    amountController.clear();
    descriptionController.clear();
    setState(() {
      selectedDate = DateTime.now();
      selectedTime = TimeOfDay.now();
      selectedPaymentIndex = null;
      selectedCategoryIndex = null;
    });
  }

  @override
  void dispose() {
    amountController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Deposit to Cashbook",
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
      body: isProcessing
          ? Center(
              child:
                  CircularProgressIndicator(color: theme.colorScheme.primary))
          : SingleChildScrollView(
              padding:
                  const EdgeInsets.symmetric(horizontal: 25.0, vertical: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Amount Input
                  _buildInputField(
                    "Amount",
                    theme,
                    controller: amountController,
                    keyboardType: TextInputType.number,
                  ),

                  const SizedBox(height: 20),

                  // Description Input
                  _buildInputField(
                    "Description",
                    theme,
                    controller: descriptionController,
                  ),
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
                            color: selectedPaymentIndex == index
                                ? theme.colorScheme.onPrimary
                                : theme.colorScheme.primary,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        selected: selectedPaymentIndex == index,
                        onSelected: (selected) {
                          setState(() {
                            selectedPaymentIndex = selected ? index : null;
                          });
                        },
                        selectedColor: theme.colorScheme.primary,
                        backgroundColor:
                            theme.colorScheme.primary.withOpacity(0.2),
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
                          onPressed: () {
                            _saveDeposit(addMore: false);
                          },
                          theme: theme,
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
    TextInputType keyboardType = TextInputType.text,
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
    required VoidCallback onPressed,
    required ThemeData theme,
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
      icon: Icon(icon, size: 35, color: theme.colorScheme.onPrimary),
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
