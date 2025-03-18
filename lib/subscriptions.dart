// ignore_for_file: use_build_context_synchronously, avoid_print, deprecated_member_use, unnecessary_to_list_in_spreads

import 'package:brokecheck/mytextfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SubscriptionsPage extends StatefulWidget {
  const SubscriptionsPage({super.key});

  @override
  State<SubscriptionsPage> createState() => _SubscriptionsPageState();
}

class _SubscriptionsPageState extends State<SubscriptionsPage> {
  // Create a list for subscriptions
  List<Map<String, dynamic>> subscriptions = [];
  bool _isLoading = true;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Define a map of subscription services and their logos
  final Map<String, String> subscriptionLogos = {
    'Netflix': 'images/logos/netflix_logo.png',
    'Prime Video': 'images/logos/primevideos.jpg',
    'Prime': 'images/logos/prime.png',
    'Jiohotstar': 'images/logos/jio-hotstar.webp',
    'Spotify': 'images/logos/Spotify.png',
    'YouTube Premium': 'images/logos/YTPremium.webp',
    'Apple Music': 'images/logos/applemusic.jpg',
    'HBO Max': 'images/logos/hbomax.jpg',
    'Hulu': 'images/logos/hulu.jpg',
    'Apple TV+': 'images/logos/Apple-TV-1.webp',
    'Adobe Creative Cloud': 'images/logos/AdobeCreativeCloud.jpeg',
    'Xbox Game Pass': 'images/logos/XboxGamePass.jpg',
    'PlayStation Plus': 'images/logos/Playstation.webp',
    'Other': 'images/logos/Others.webp',
  };

  @override
  void initState() {
    super.initState();
    _loadSubscriptionsFromDatabase();
  }

  // Update _saveSubscriptionsToDatabase method for clarity and better structure
  Future<void> _saveSubscriptionsToDatabase() async {
    try {
      final User? currentUser = _auth.currentUser;

      if (currentUser != null) {
        final String userId = currentUser.uid;

        // Create a user document reference
        final userDocRef = _firestore.collection('users').doc(userId);

        // Update only the subscriptions field for this specific user
        await userDocRef.set({
          'subscriptions': subscriptions,
          'lastUpdated': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));

        print('Subscriptions saved successfully for user: $userId');
      } else {
        print('Error: No user is currently logged in');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Please log in to save your subscriptions'),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      }
    } catch (e) {
      print('Error saving subscriptions: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save subscriptions: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

// Update _loadSubscriptionsFromDatabase method for better error handling
  Future<void> _loadSubscriptionsFromDatabase() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final User? currentUser = _auth.currentUser;

      if (currentUser != null) {
        final String userId = currentUser.uid;
        final DocumentSnapshot userDoc =
            await _firestore.collection('users').doc(userId).get();

        if (userDoc.exists) {
          final userData = userDoc.data() as Map<String, dynamic>;

          if (userData.containsKey('subscriptions')) {
            final List<dynamic> userSubscriptions = userData['subscriptions'];

            setState(() {
              subscriptions =
                  List<Map<String, dynamic>>.from(userSubscriptions);
            });

            print(
                'Loaded ${subscriptions.length} subscriptions for user: $userId');
          } else {
            // Initialize with empty list if no subscriptions found
            setState(() {
              subscriptions = [];
            });
            print('No subscriptions found for user: $userId');
          }
        } else {
          // Create user document if it doesn't exist yet
          await _firestore.collection('users').doc(userId).set({
            'email': currentUser.email,
            'createdAt': FieldValue.serverTimestamp(),
            'subscriptions': [],
          });

          setState(() {
            subscriptions = [];
          });
          print('Created new user document for: $userId');
        }
      } else {
        // Handle the case when no user is logged in
        print('Error: No user is currently logged in');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Please log in to view your subscriptions'),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      }
    } catch (e) {
      print('Error loading subscriptions: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load subscriptions: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Your Subscriptions',
          style: theme.textTheme.titleLarge,
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: theme.primaryColor,
              ),
            )
          : subscriptions.isEmpty
              ? _buildEmptyState()
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total Monthly Spending',
                            style: theme.textTheme.labelMedium,
                          ),
                          Text(
                            '₹${(_calculateTotalSpending() / 100).toStringAsFixed(2)}',
                            style: theme.textTheme.titleMedium,
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      ListView.separated(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: subscriptions.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 12),
                        itemBuilder: (context, index) => SubscriptionItem(
                          subscription: subscriptions[index],
                          onDelete: () => _deleteSubscription(index),
                          onEdit: () => _showSubscriptionBottomSheet(index),
                          logoPath: _getLogoPath(subscriptions[index]['title']),
                        ),
                      ),
                    ],
                  ),
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _showSubscriptionBottomSheet();
        },
        icon: Icon(
          Icons.add,
          size: 24,
          color: isDark ? Colors.white : Colors.black,
        ),
        label: Text(
          "Add Subscription",
          style: TextStyle(
            fontSize: 14,
            fontFamily: 'poppylight',
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
        backgroundColor: theme.primaryColor.withOpacity(0.7),
      ),
    );
  }

  // Helper method to get the logo path based on subscription title
  String _getLogoPath(String title) {
    return subscriptionLogos[title] ?? subscriptionLogos['Other']!;
  }

  Widget _buildEmptyState() {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.subscriptions_outlined,
            size: 80,
            color: theme.colorScheme.secondary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No subscriptions yet',
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Tap the "Add Subscription" button to add one',
            style: theme.textTheme.labelMedium,
          ),
        ],
      ),
    );
  }

  int _calculateTotalSpending() {
    int total = 0;
    for (var subscription in subscriptions) {
      total += subscription['amount'] as int;
    }
    return total;
  }

  void _deleteSubscription(int index) {
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          backgroundColor: theme.cardTheme.color,
          title: Text(
            'Confirm Deletion',
            style: theme.textTheme.titleMedium,
          ),
          content: Text(
            'Are you sure you want to delete "${subscriptions[index]['title']}" subscription?',
            style: theme.textTheme.bodyMedium,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: theme.textButtonTheme.style
                        ?.copyWith(
                          foregroundColor: MaterialStateProperty.all(
                              theme.colorScheme.secondary),
                        )
                        .textStyle
                        ?.resolve({}) ??
                    TextStyle(color: theme.colorScheme.secondary),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  subscriptions.removeAt(index);
                });

                // Save updated subscriptions to database
                _saveSubscriptionsToDatabase();

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Subscription deleted'),
                    backgroundColor: theme.colorScheme.error,
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.error,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Delete',
                style: TextStyle(
                  color: theme.colorScheme.onError,
                  fontFamily: 'poppy',
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showSubscriptionBottomSheet([int? editIndex]) {
    final TextEditingController titleController = TextEditingController();
    final TextEditingController amountController = TextEditingController();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    DateTime purchaseDate = DateTime.now();
    DateTime renewDate = DateTime.now().add(const Duration(days: 30));
    String subscriptionType = 'Monthly Subscription';
    String selectedService = editIndex != null
        ? subscriptions[editIndex]['title']
        : subscriptionLogos.keys.first;

    // If editing, pre-fill the fields
    if (editIndex != null) {
      final subscription = subscriptions[editIndex];
      titleController.text = subscription['title'];
      amountController.text = (subscription['amount'] / 100).toString();
      selectedService = subscription['title'];

      // Parse dates
      try {
        purchaseDate =
            DateFormat('d MMM y').parse(subscription['purchaseDate']);
        renewDate = DateFormat('d MMM y').parse(subscription['renewDate']);
      } catch (e) {
        // Use default dates if parsing fails
      }

      subscriptionType = subscription['type'];
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(builder: (context, setModalState) {
          return Container(
            height: MediaQuery.of(context).size.height * 0.85,
            decoration: BoxDecoration(
              color: theme.cardTheme.color,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  editIndex != null ? 'Edit Subscription' : 'Add Subscription',
                  style: theme.textTheme.titleLarge,
                ),
                const SizedBox(height: 24),

                // Subscription service dropdown
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                        color: theme.dividerTheme.color ??
                            Colors.grey.withOpacity(0.3)),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: selectedService,
                      isExpanded: true,
                      icon: const Icon(Icons.keyboard_arrow_down),
                      style: theme.textTheme.bodyMedium,
                      dropdownColor: theme.cardTheme.color,
                      items: [
                        ...subscriptionLogos.keys.map((String serviceName) {
                          return DropdownMenuItem<String>(
                            value: serviceName,
                            child: Row(
                              children: [
                                Image.asset(
                                  subscriptionLogos[serviceName]!,
                                  width: 24,
                                  height: 24,
                                  errorBuilder: (context, error, stackTrace) {
                                    return const Icon(Icons.subscriptions,
                                        size: 24);
                                  },
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  serviceName,
                                  style: theme.textTheme.bodyMedium,
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ],
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          setModalState(() {
                            selectedService = newValue;
                            titleController.text = newValue;
                          });
                        }
                      },
                      hint: Text(
                        'Select Service',
                        style: theme.textTheme.labelMedium,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Title field using Mytextfield
                Mytextfield(
                  label: 'Subscription Name',
                  obscureText: false,
                  controller: titleController,
                ),
                const SizedBox(height: 16),
                Mytextfield(
                  label: 'Amount (₹)',
                  obscureText: false,
                  controller: amountController,
                ),

                const SizedBox(height: 16),

                // Subscription type dropdown
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                        color: theme.dividerTheme.color ??
                            Colors.grey.withOpacity(0.3)),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: subscriptionType,
                      isExpanded: true,
                      icon: const Icon(Icons.keyboard_arrow_down),
                      style: theme.textTheme.bodyMedium,
                      dropdownColor: theme.cardTheme.color,
                      items: [
                        'Monthly Subscription',
                        'Annual Subscription',
                        'Custom Subscription'
                      ].map((String type) {
                        return DropdownMenuItem<String>(
                          value: type,
                          child: Text(
                            type,
                            style: theme.textTheme.bodyMedium,
                          ),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          setModalState(() {
                            subscriptionType = newValue;
                            // Set renew date based on subscription type
                            if (newValue == 'Monthly Subscription') {
                              renewDate =
                                  purchaseDate.add(const Duration(days: 30));
                            } else if (newValue == 'Annual Subscription') {
                              renewDate = DateTime(
                                purchaseDate.year + 1,
                                purchaseDate.month,
                                purchaseDate.day,
                              );
                            }
                          });
                        }
                      },
                      hint: Text(
                        'Subscription Type',
                        style: theme.textTheme.labelMedium,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Purchase date picker
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                        color: theme.dividerTheme.color ??
                            Colors.grey.withOpacity(0.3)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Purchase Date',
                              style: theme.textTheme.labelMedium,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              DateFormat('d MMM y').format(purchaseDate),
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          final DateTime? pickedDate = await showDatePicker(
                              context: context,
                              initialDate: purchaseDate,
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2101),
                              // Replace the existing showDatePicker builder with this:
                              builder: (context, child) {
                                return Theme(
                                  data: Theme.of(context).copyWith(
                                    colorScheme: isDark
                                        ? ColorScheme.dark(
                                            primary: theme.primaryColor,
                                            onPrimary: Colors.white,
                                            surface: theme.cardTheme.color ??
                                                Colors.grey[900]!,
                                            onSurface: Colors.white,
                                          )
                                        : ColorScheme.light(
                                            primary: theme.primaryColor,
                                            onPrimary: Colors.black,
                                            onSurface: theme.textTheme.bodyLarge
                                                    ?.color ??
                                                Colors.black,
                                          ),
                                    textButtonTheme: TextButtonThemeData(
                                      style: TextButton.styleFrom(
                                        foregroundColor:
                                            theme.colorScheme.secondary,
                                        textStyle: const TextStyle(
                                          fontFamily: 'poppy',
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ),
                                  child: child!,
                                );
                              });
                          if (pickedDate != null &&
                              pickedDate != purchaseDate) {
                            setModalState(() {
                              purchaseDate = pickedDate;
                              // Update renew date based on subscription type
                              if (subscriptionType == 'Monthly Subscription') {
                                renewDate =
                                    purchaseDate.add(const Duration(days: 30));
                              } else if (subscriptionType ==
                                  'Annual Subscription') {
                                renewDate = DateTime(
                                  purchaseDate.year + 1,
                                  purchaseDate.month,
                                  purchaseDate.day,
                                );
                              }
                            });
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.primaryColor.withOpacity(0.7),
                          foregroundColor: isDark ? Colors.white : Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                        ),
                        child: Text(
                          'Select Date',
                          style: TextStyle(
                            fontFamily: 'poppy',
                            fontSize: 14,
                            color: isDark ? Colors.white : Colors.black,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Renew date picker
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                        color: theme.dividerTheme.color ??
                            Colors.grey.withOpacity(0.3)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Renewal Date',
                              style: theme.textTheme.labelMedium,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              DateFormat('d MMM y').format(renewDate),
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          final DateTime? pickedDate = await showDatePicker(
                              context: context,
                              initialDate: renewDate,
                              firstDate: DateTime.now(),
                              lastDate: DateTime(2101),
                              builder: (context, child) {
                                return Theme(
                                  data: Theme.of(context).copyWith(
                                    colorScheme: isDark
                                        ? ColorScheme.dark(
                                            primary: theme.primaryColor,
                                            onPrimary: Colors.white,
                                            surface: theme.cardTheme.color ??
                                                Colors.grey[900]!,
                                            onSurface: Colors.white,
                                          )
                                        : ColorScheme.light(
                                            primary: theme.primaryColor,
                                            onPrimary: Colors.black,
                                            onSurface: theme.textTheme.bodyLarge
                                                    ?.color ??
                                                Colors.black,
                                          ),
                                    textButtonTheme: TextButtonThemeData(
                                      style: TextButton.styleFrom(
                                        foregroundColor:
                                            theme.colorScheme.secondary,
                                        textStyle: const TextStyle(
                                          fontFamily: 'poppy',
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ),
                                  child: child!,
                                );
                              });
                          if (pickedDate != null) {
                            setModalState(() {
                              renewDate = pickedDate;
                            });
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.primaryColor.withOpacity(0.7),
                          foregroundColor: isDark ? Colors.white : Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                        ),
                        child: Text(
                          'Select Date',
                          style: TextStyle(
                            fontFamily: 'poppy',
                            fontSize: 14,
                            color: isDark ? Colors.white : Colors.black,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                // Submit button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      // Validate inputs
                      if (titleController.text.isEmpty ||
                          amountController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content:
                                const Text('Please fill all required fields'),
                            backgroundColor: theme.colorScheme.error,
                          ),
                        );
                        return;
                      }

                      // Parse amount as cents
                      int amountInCents;
                      try {
                        amountInCents =
                            (double.parse(amountController.text) * 100).round();
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('Please enter a valid amount'),
                            backgroundColor: theme.colorScheme.error,
                          ),
                        );
                        return;
                      }

                      // Create subscription data
                      final Map<String, dynamic> subscription = {
                        'title': titleController.text,
                        'renewDate': DateFormat('d MMM y').format(renewDate),
                        'type': subscriptionType,
                        'purchaseDate':
                            DateFormat('d MMM y').format(purchaseDate),
                        'amount': amountInCents,
                        'image': "images/pfp.jpg", // Default image
                      };

                      setState(() {
                        if (editIndex != null) {
                          // Update existing subscription
                          subscriptions[editIndex] = subscription;
                        } else {
                          // Add new subscription
                          subscriptions.add(subscription);
                        }
                      });

                      // Save to database
                      _saveSubscriptionsToDatabase();

                      Navigator.pop(context);

                      // Show success message
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            editIndex != null
                                ? 'Subscription updated successfully'
                                : 'Subscription added successfully',
                          ),
                          backgroundColor: theme.colorScheme.primary,
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                    style: theme.elevatedButtonTheme.style?.copyWith(
                      backgroundColor:
                          MaterialStateProperty.all(theme.primaryColor),
                    ),
                    child: Text(
                      editIndex != null
                          ? 'Update Subscription'
                          : 'Add Subscription',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'poppy',
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        });
      },
    );
  }
}

class SubscriptionItem extends StatefulWidget {
  final Map<String, dynamic> subscription;
  final VoidCallback onDelete;
  final VoidCallback onEdit;
  final String logoPath;

  const SubscriptionItem({
    super.key,
    required this.subscription,
    required this.onDelete,
    required this.onEdit,
    required this.logoPath,
  });

  @override
  State<SubscriptionItem> createState() => _SubscriptionItemState();
}

class _SubscriptionItemState extends State<SubscriptionItem> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Slidable(
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          const SizedBox(width: 5),
          SlidableAction(
            borderRadius: BorderRadius.circular(15),
            onPressed: (context) => widget.onEdit(),
            backgroundColor: theme.colorScheme.secondary,
            foregroundColor: isDark ? Colors.black : Colors.white,
            icon: Icons.edit,
          ),
          const SizedBox(width: 5),
          SlidableAction(
            onPressed: (context) => widget.onDelete(),
            borderRadius: BorderRadius.circular(15),
            backgroundColor: theme.colorScheme.error,
            foregroundColor: theme.colorScheme.onError,
            icon: Icons.delete,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Container(
          decoration: BoxDecoration(
            color: theme.cardTheme.color,
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: ExpansionPanelList(
            expandedHeaderPadding: EdgeInsets.zero,
            expansionCallback: (index, isExpanded) {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            children: [
              ExpansionPanel(
                backgroundColor: theme.cardTheme.color,
                isExpanded: _isExpanded,
                canTapOnHeader: true,
                headerBuilder: (context, isExpanded) {
                  return ListTile(
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                    leading: CircleAvatar(
                      backgroundImage: AssetImage(widget.logoPath),
                      radius: 25,
                      backgroundColor:
                          Colors.white, // For logos with transparency
                    ),
                    title: Text(
                      widget.subscription['title'],
                      style: theme.textTheme.titleMedium,
                    ),
                    subtitle: Text(
                      'Renews on: ${widget.subscription['renewDate']}',
                      style: theme.textTheme.labelMedium,
                    ),
                    trailing: Text(
                      '₹${(widget.subscription['amount'] / 100).toStringAsFixed(2)}',
                      style: theme.textTheme.titleMedium,
                    ),
                  );
                },
                body: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Divider(height: 1, color: theme.dividerTheme.color),
                      const SizedBox(height: 10),
                      Text(
                        widget.subscription['type'],
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Purchased on',
                            style: theme.textTheme.labelMedium,
                          ),
                          Text(
                            widget.subscription['purchaseDate'],
                            style: theme.textTheme.labelMedium,
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Renews on',
                            style: theme.textTheme.labelMedium,
                          ),
                          Text(
                            widget.subscription['renewDate'],
                            style: theme.textTheme.labelMedium,
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
      ),
    );
  }
}
