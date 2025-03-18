// ignore_for_file: unused_import, use_build_context_synchronously, deprecated_member_use, unused_local_variable

import 'package:brokecheck/app_themes.dart';
import 'package:brokecheck/opened_cashbook.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class Cashbook {
  final String id;
  final String name;
  final int iconCodePoint;
  final bool isFavorite;
  final double balance;
  final DateTime createdAt;

  Cashbook({
    required this.id,
    required this.name,
    required this.iconCodePoint,
    this.isFavorite = false,
    this.balance = 0.0,
    required this.createdAt,
  });

  factory Cashbook.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Cashbook(
      id: doc.id,
      name: data['name'] ?? '',
      iconCodePoint: data['icon'] ?? Icons.account_balance_wallet.codePoint,
      isFavorite: data['isFavorite'] ?? false,
      balance: (data['balance'] ?? 0.0).toDouble(),
      createdAt: (data['created_at'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'icon': iconCodePoint,
      'isFavorite': isFavorite,
      'balance': balance,
      'created_at': Timestamp.fromDate(createdAt),
    };
  }

  Cashbook copyWith({
    String? id,
    String? name,
    int? iconCodePoint,
    bool? isFavorite,
    double? balance,
    DateTime? createdAt,
  }) {
    return Cashbook(
      id: id ?? this.id,
      name: name ?? this.name,
      iconCodePoint: iconCodePoint ?? this.iconCodePoint,
      isFavorite: isFavorite ?? this.isFavorite,
      balance: balance ?? this.balance,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class CashbookService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Reference to the cashbook collection
  CollectionReference get cashbooksCollection =>
      _firestore.collection('cashbook data');

  // Get all cashbooks for current user
  Stream<List<Cashbook>> getCashbooks() {
    return cashbooksCollection
        .where('userId', isEqualTo: currentUser?.uid)
        .orderBy('created_at', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Cashbook.fromFirestore(doc)).toList());
  }

  // Get favorite cashbooks for current user
  Stream<List<Cashbook>> getFavoriteCashbooks() {
    return cashbooksCollection
        .where('userId', isEqualTo: currentUser?.uid)
        .where('isFavorite', isEqualTo: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Cashbook.fromFirestore(doc)).toList());
  }

  // Add a new cashbook
  Future<void> addCashbook({
    required String name,
    required int iconCodePoint,
    required bool isFavorite,
  }) async {
    if (currentUser == null) return;

    await cashbooksCollection.add({
      'name': name,
      'icon': iconCodePoint,
      'isFavorite': isFavorite,
      'balance': 0.0,
      'created_at': Timestamp.now(),
      'userId': currentUser!.uid,
    });
  }

  // Update a cashbook
  Future<void> updateCashbook(Cashbook cashbook) async {
    await cashbooksCollection.doc(cashbook.id).update(cashbook.toMap());
  }

  // Toggle favorite status
  Future<void> toggleFavorite(Cashbook cashbook) async {
    await cashbooksCollection.doc(cashbook.id).update({
      'isFavorite': !cashbook.isFavorite,
    });
  }

  // Update balance
  Future<void> updateBalance(String cashbookId, double amount) async {
    // Get current cashbook
    DocumentSnapshot doc = await cashbooksCollection.doc(cashbookId).get();
    Cashbook cashbook = Cashbook.fromFirestore(doc);

    // Update balance
    double newBalance = cashbook.balance + amount;
    await cashbooksCollection.doc(cashbookId).update({
      'balance': newBalance,
    });
  }

  // Delete cashbook
  Future<void> deleteCashbook(String cashbookId) async {
    await cashbooksCollection.doc(cashbookId).delete();
  }
}

// Updated Modal with Favorite Option
void showAddCashbookModal(BuildContext context) {
  final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppThemes.getCardColor(isDarkMode),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      return DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) {
          return GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: AddCashbookModal(scrollController: scrollController),
          );
        },
      );
    },
  );
}

class AddCashbookModal extends StatefulWidget {
  final ScrollController scrollController;

  const AddCashbookModal({super.key, required this.scrollController});

  @override
  State<AddCashbookModal> createState() => _AddCashbookModalState();
}

class _AddCashbookModalState extends State<AddCashbookModal> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  int? selectedIconIndex;
  bool isFavorite = false;
  final CashbookService _cashbookService = CashbookService();

  // List of different payment-related icons
  final List<IconData> _icons = [
    Icons.account_balance_wallet,
    Icons.credit_card,
    Icons.monetization_on,
    Icons.attach_money,
    Icons.payments,
    Icons.savings,
    Icons.currency_exchange,
    Icons.store,
  ];

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() {}); // Update UI when text field focus changes
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final Color primaryColor = AppThemes.getPrimaryColor(isDarkMode);
    AppThemes.getTextColor(isDarkMode);
    final Color secondaryTextColor =
        AppThemes.getSecondaryTextColor(isDarkMode);
    final Color backgroundColor = AppThemes.getBackgroundColor(isDarkMode);
    final Color cardColor = AppThemes.getCardColor(isDarkMode);

    return Padding(
      padding: MediaQuery.of(context).viewInsets,
      child: ListView(
        controller: widget.scrollController,
        shrinkWrap: true,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        children: [
          // Drag Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: secondaryTextColor,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 15),

          // Title
          Text(
            "Make a new cashbook",
            style: Theme.of(context).textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),

          // Divider Below Title
          const SizedBox(height: 10),
          Divider(thickness: 1, color: secondaryTextColor.withOpacity(0.3)),
          const SizedBox(height: 20),

          // Cashbook Name TextField
          TextField(
            controller: _controller,
            focusNode: _focusNode,
            cursorColor: primaryColor,
            style: Theme.of(context).textTheme.bodyMedium,
            decoration: InputDecoration(
              labelText: "Cashbook Name",
              labelStyle: TextStyle(
                color: _focusNode.hasFocus ? primaryColor : secondaryTextColor,
                fontFamily: 'poppy',
              ),
              floatingLabelStyle: TextStyle(
                color: primaryColor,
                fontFamily: 'poppy',
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: primaryColor),
                borderRadius: BorderRadius.circular(10),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide:
                    BorderSide(color: secondaryTextColor.withOpacity(0.5)),
                borderRadius: BorderRadius.circular(10),
              ),
              prefixIcon: Icon(Icons.edit, color: secondaryTextColor),
              fillColor: cardColor,
            ),
          ),
          const SizedBox(height: 30),

          // Choose Icon Section
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "Choose an icon",
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: secondaryTextColor,
                  ),
            ),
          ),
          const SizedBox(height: 10),

          // Icon Selection Grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
            ),
            itemCount: _icons.length,
            itemBuilder: (context, index) {
              bool isSelected = selectedIconIndex == index;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    selectedIconIndex = index;
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected
                        ? primaryColor.withOpacity(0.2)
                        : isDarkMode
                            ? Colors.grey[800]
                            : Colors.grey[200],
                    border: isSelected
                        ? Border.all(color: primaryColor, width: 2)
                        : null,
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: primaryColor.withOpacity(0.3),
                              blurRadius: 5,
                              spreadRadius: 1,
                            )
                          ]
                        : null,
                  ),
                  child: Icon(
                    _icons[index],
                    color: isSelected ? primaryColor : secondaryTextColor,
                    size: 28,
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 20),

          // Add to Favorites Option
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.grey[800] : Colors.grey[100],
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: isFavorite ? Colors.redAccent : secondaryTextColor,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      "Add to Favorites",
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: secondaryTextColor,
                          ),
                    ),
                  ],
                ),
                Switch(
                  value: isFavorite,
                  onChanged: (value) {
                    setState(() {
                      isFavorite = value;
                    });
                  },
                  activeColor: primaryColor,
                  activeTrackColor: primaryColor.withOpacity(0.5),
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),

          // Create Button
          ElevatedButton(
            onPressed: _controller.text.trim().isEmpty ||
                    selectedIconIndex == null
                ? null // Disable button if input is empty or no icon selected
                : () {
                    _saveCashbook();
                    Navigator.pop(context);
                  },
            style: Theme.of(context).elevatedButtonTheme.style,
            child: Text(
              "Create",
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                  ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  void _saveCashbook() async {
    // Get the selected icon index and name
    final selectedIcon = _icons[selectedIconIndex ?? 0];
    final iconData = selectedIcon.codePoint;
    final cashbookName = _controller.text.trim();

    // Save the cashbook data using the service
    await _cashbookService.addCashbook(
      name: cashbookName,
      iconCodePoint: iconData,
      isFavorite: isFavorite,
    );
  }
}

// Widget to display favorite cashbooks
class FavoriteCashbooksWidget extends StatelessWidget {
  const FavoriteCashbooksWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final CashbookService cashbookService = CashbookService();
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final Color primaryColor = AppThemes.getPrimaryColor(isDarkMode);
    final Color textColor = AppThemes.getTextColor(isDarkMode);
    final Color secondaryTextColor =
        AppThemes.getSecondaryTextColor(isDarkMode);

    return StreamBuilder<List<Cashbook>>(
      stream: cashbookService.getFavoriteCashbooks(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.favorite_border,
                  size: 40,
                  color: secondaryTextColor.withOpacity(0.5),
                ),
                const SizedBox(height: 10),
                Text(
                  "No favorite cashbooks yet",
                  style: Theme.of(context).textTheme.labelMedium,
                ),
              ],
            ),
          );
        }

        final favorites = snapshot.data!;

        return ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: favorites.length,
          padding: const EdgeInsets.symmetric(horizontal: 15),
          itemBuilder: (context, index) {
            final cashbook = favorites[index];
            return Container(
              width: 180,
              margin: const EdgeInsets.only(right: 15),
              decoration: BoxDecoration(
                gradient: AppThemes.getPrimaryGradient(isDarkMode),
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // Favorite Icon
                  Positioned(
                    right: 10,
                    top: 10,
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.8),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.favorite,
                        color: Colors.redAccent,
                        size: 18,
                      ),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.all(15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 3,
                                    offset: const Offset(0, 1),
                                  ),
                                ],
                              ),
                              child: Icon(
                                IconData(
                                  cashbook.iconCodePoint,
                                  fontFamily: 'MaterialIcons',
                                ),
                                color: primaryColor,
                                size: 16,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                cashbook.name,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      color: Colors.white,
                                    ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 15),
                        Text(
                          NumberFormat.currency(
                            locale: 'en_US',
                            symbol: cashbook.balance >= 0 ? '+' : '-',
                            decimalDigits: 0,
                          ).format(cashbook.balance.abs()),
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontSize: 28,
                                    color: Colors.white,
                                  ),
                        ),
                        const Spacer(),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                icon: const Icon(Icons.remove, size: 14),
                                label: const Text(
                                  "Withdraw",
                                  style: TextStyle(fontSize: 11),
                                ),
                                onPressed: () {
                                  // Show withdraw dialog
                                },
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  backgroundColor:
                                      Colors.white.withOpacity(0.2),
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 8, horizontal: 5),
                                  side: const BorderSide(color: Colors.white60),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: OutlinedButton.icon(
                                icon: const Icon(Icons.add, size: 14),
                                label: const Text(
                                  "Deposit",
                                  style: TextStyle(fontSize: 11),
                                ),
                                onPressed: () {
                                  // Show deposit dialog
                                },
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  backgroundColor:
                                      Colors.white.withOpacity(0.2),
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 8, horizontal: 5),
                                  side: const BorderSide(color: Colors.white60),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

// Widget to display all cashbooks
class CashbooksListWidget extends StatelessWidget {
  const CashbooksListWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final CashbookService cashbookService = CashbookService();
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final Color primaryColor = AppThemes.getPrimaryColor(isDarkMode);
    final Color textColor = AppThemes.getTextColor(isDarkMode);
    final Color secondaryTextColor =
        AppThemes.getSecondaryTextColor(isDarkMode);
    final Color cardColor = AppThemes.getCardColor(isDarkMode);

    return StreamBuilder<List<Cashbook>>(
      stream: cashbookService.getCashbooks(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.account_balance_wallet_outlined,
                  size: 50,
                  color: secondaryTextColor.withOpacity(0.5),
                ),
                const SizedBox(height: 20),
                Text(
                  "No cashbooks yet",
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: secondaryTextColor,
                      ),
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text("Add Cashbook"),
                  onPressed: () => showAddCashbookModal(context),
                  style: Theme.of(context).elevatedButtonTheme.style,
                ),
              ],
            ),
          );
        }

        final cashbooks = snapshot.data!;

        return ListView.builder(
          itemCount: cashbooks.length,
          padding: const EdgeInsets.only(top: 10, bottom: 20),
          itemBuilder: (context, index) {
            final cashbook = cashbooks[index];
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(15),
                onTap: () {
                  // Navigate to cashbook details
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Opendcashbook(cashbook: cashbook),
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: primaryColor.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        IconData(
                          cashbook.iconCodePoint,
                          fontFamily: 'MaterialIcons',
                        ),
                        color: primaryColor,
                        size: 24,
                      ),
                    ),
                    title: Text(
                      cashbook.name,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(
                          DateFormat('MMM dd, yyyy').format(cashbook.createdAt),
                          style: Theme.of(context).textTheme.labelMedium,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          NumberFormat.currency(
                            locale: 'en_US',
                            symbol: '\$',
                            decimalDigits: 0,
                          ).format(cashbook.balance),
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: cashbook.balance >= 0
                                        ? primaryColor
                                        : Colors.red[isDarkMode ? 300 : 700],
                                  ),
                        ),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (cashbook.isFavorite)
                          Container(
                            padding: const EdgeInsets.all(3),
                            decoration: BoxDecoration(
                              color: isDarkMode
                                  ? Colors.red[900]?.withOpacity(0.3)
                                  : Colors.red[50],
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.favorite,
                              color: Colors.redAccent,
                              size: 16,
                            ),
                          ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon:
                              Icon(Icons.more_vert, color: secondaryTextColor),
                          onPressed: () {
                            showModalBottomSheet(
                              context: context,
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(20)),
                              ),
                              backgroundColor: cardColor,
                              builder: (context) =>
                                  CashbookOptionsSheet(cashbook: cashbook),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

// Bottom sheet for cashbook options
class CashbookOptionsSheet extends StatelessWidget {
  final Cashbook cashbook;
  final CashbookService _cashbookService = CashbookService();

  CashbookOptionsSheet({super.key, required this.cashbook});

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final Color primaryColor = AppThemes.getPrimaryColor(isDarkMode);
    final Color secondaryTextColor =
        AppThemes.getSecondaryTextColor(isDarkMode);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: secondaryTextColor.withOpacity(0.3),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(height: 20),

          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isDarkMode
                    ? Colors.red[900]?.withOpacity(0.3)
                    : Colors.red[50],
                shape: BoxShape.circle,
              ),
              child: Icon(
                cashbook.isFavorite ? Icons.favorite : Icons.favorite_border,
                color: Colors.redAccent,
              ),
            ),
            title: Text(
              cashbook.isFavorite
                  ? "Remove from Favorites"
                  : "Add to Favorites",
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            onTap: () async {
              await _cashbookService.toggleFavorite(cashbook);
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isDarkMode
                    ? Colors.blue[900]?.withOpacity(0.3)
                    : Colors.blue[50],
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.edit, color: Colors.blue),
            ),
            title: Text(
              "Edit Cashbook",
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            onTap: () {
              Navigator.pop(context);
              // Show edit dialog
            },
          ),
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isDarkMode
                    ? Colors.red[900]?.withOpacity(0.3)
                    : Colors.red[50],
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.delete, color: Colors.red),
            ),
            title: Text(
              "Delete Cashbook",
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            onTap: () {
              Navigator.pop(context);
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  backgroundColor: AppThemes.getCardColor(isDarkMode),
                  title: Text(
                    "Delete Cashbook",
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  content: Text(
                    "Are you sure you want to delete ${cashbook.name}?",
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  actions: [
                    TextButton(
                      child: Text(
                        "Cancel",
                        style: TextStyle(color: secondaryTextColor),
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                    TextButton(
                      child: const Text(
                        "Delete",
                        style: TextStyle(color: Colors.red),
                      ),
                      onPressed: () async {
                        await _cashbookService.deleteCashbook(cashbook.id);
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
