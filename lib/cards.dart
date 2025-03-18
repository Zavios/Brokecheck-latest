// ignore_for_file: deprecated_member_use

import 'dart:convert';
import 'package:brokecheck/app_themes.dart';
import 'package:brokecheck/card_component.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Card data model with JSON serialization
class CardData {
  final String cardNumber;
  final String expiryDate;
  final String? backgroundAsset;
  final String? bankLogoAsset;
  final String? networkLogoAsset;

  CardData({
    required this.cardNumber,
    required this.expiryDate,
    this.backgroundAsset,
    this.bankLogoAsset,
    this.networkLogoAsset,
  });

  // Convert CardData to JSON
  Map<String, dynamic> toJson() {
    return {
      'cardNumber': cardNumber,
      'expiryDate': expiryDate,
      'backgroundAsset': backgroundAsset,
      'bankLogoAsset': bankLogoAsset,
      'networkLogoAsset': networkLogoAsset,
    };
  }

  // Create CardData from JSON
  factory CardData.fromJson(Map<String, dynamic> json) {
    return CardData(
      cardNumber: json['cardNumber'],
      expiryDate: json['expiryDate'],
      backgroundAsset: json['backgroundAsset'],
      bankLogoAsset: json['bankLogoAsset'],
      networkLogoAsset: json['networkLogoAsset'],
    );
  }
}

// Card storage helper
class CardStorage {
  static const String _cardsKey = 'saved_cards';

  // Save cards to SharedPreferences
  static Future<bool> saveCards(List<CardData> cards) async {
    final prefs = await SharedPreferences.getInstance();
    final cardsJson = cards.map((card) => card.toJson()).toList();
    return prefs.setString(_cardsKey, jsonEncode(cardsJson));
  }

  // Load cards from SharedPreferences
  static Future<List<CardData>> loadCards() async {
    final prefs = await SharedPreferences.getInstance();
    final cardsString = prefs.getString(_cardsKey);

    if (cardsString == null || cardsString.isEmpty) {
      return [];
    }

    try {
      final cardsJson = jsonDecode(cardsString) as List;
      return cardsJson
          .map((json) => CardData.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      // ignore: avoid_print
      print('Error loading cards: $e');
      return [];
    }
  }
}

class CardPage extends StatefulWidget {
  const CardPage({super.key});

  @override
  State<CardPage> createState() => _CardPageState();
}

class _CardPageState extends State<CardPage> {
  final List<CardData> _cards = [];

  // Form controllers
  final TextEditingController _cardNumberController = TextEditingController();
  final TextEditingController _expiryDateController = TextEditingController();

  // Selected assets
  String? _selectedBankLogo;
  String? _selectedCardBg;
  String? _selectedCardType;

  // Lists of available assets
  List<String> _bankLogos = [];
  List<String> _cardBgs = [];
  List<String> _cardTypes = [];

  bool _isAddCardPanelOpen = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    await _loadAssets();
    await _loadSavedCards();
    setState(() {
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _cardNumberController.dispose();
    _expiryDateController.dispose();
    super.dispose();
  }

  // Load saved cards from storage
  Future<void> _loadSavedCards() async {
    final savedCards = await CardStorage.loadCards();
    if (savedCards.isNotEmpty) {
      setState(() {
        _cards.clear();
        _cards.addAll(savedCards);
      });
    }
  }

  // Load available assets from the asset directories
  Future<void> _loadAssets() async {
    // In a real app, you'd load these dynamically
    // For this example, we'll use placeholder data
    _bankLogos = [
      'images/BankLogos/SBI.svg',
      'images/BankLogos/HDFC.svg',
      'images/BankLogos/IDBI.svg',
      'images/BankLogos/Axis Bank.svg',
    ];

    _cardBgs = [
      'images/CardBG/Green.svg',
      'images/CardBG/Blue.svg',
      'images/CardBG/Abstract.svg',
      'images/CardBG/Silver.svg',
    ];

    _cardTypes = [
      'images/GlobalNetwork/Visa.svg',
      'images/GlobalNetwork/Mastercard.svg',
      'images/GlobalNetwork/Maestro.svg',
      'images/GlobalNetwork/Contactless.svg',
    ];

    setState(() {
      // Set defaults
      _selectedBankLogo = _bankLogos.first;
      _selectedCardBg = _cardBgs.first;
      _selectedCardType = _cardTypes.first;
    });
  }

  void _toggleAddCardPanel() {
    setState(() {
      _isAddCardPanelOpen = !_isAddCardPanelOpen;
    });
  }

  void _addNewCard() {
    if (_cardNumberController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please enter a card number',
            style: TextStyle(
              fontFamily: 'quickie',
              color: Colors.white,
            ),
          ),
          backgroundColor: AppThemes.getErrorColor(
              Theme.of(context).brightness == Brightness.dark),
        ),
      );
      return;
    }

    final newCard = CardData(
      cardNumber: _cardNumberController.text,
      expiryDate: _expiryDateController.text.isEmpty
          ? 'xx/xx'
          : _expiryDateController.text,
      backgroundAsset: _selectedCardBg,
      bankLogoAsset: _selectedBankLogo,
      networkLogoAsset: _selectedCardType,
    );

    setState(() {
      _cards.add(newCard);
      // Reset form
      _cardNumberController.clear();
      _expiryDateController.clear();
    });

    // Save cards to persistent storage
    CardStorage.saveCards(_cards);

    // Close the add card panel
    _toggleAddCardPanel();
  }

  void _deleteCard(int index) {
    setState(() {
      _cards.removeAt(index);
    });

    // Save updated cards list to storage
    CardStorage.saveCards(_cards);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Card deleted',
          style: TextStyle(
            fontFamily: 'quickie',
            color: Colors.white,
          ),
        ),
        backgroundColor: AppThemes.getErrorColor(
            Theme.of(context).brightness == Brightness.dark),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: AppThemes.getBackgroundColor(isDarkMode),
      body: SafeArea(
        child: _isLoading
            ? _buildLoadingIndicator()
            : Stack(
                children: [
                  // Header with plain text
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'My Cards',
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: AppThemes.getTextColor(isDarkMode),
                                  ),
                        ),
                        const SizedBox(height: 8),
                        Divider(
                          color: AppThemes.getSecondaryTextColor(isDarkMode)
                              .withOpacity(0.3),
                          thickness: 1,
                        ),
                      ],
                    ),
                  ),

                  // Card list (moved down to accommodate header)
                  Padding(
                    padding: const EdgeInsets.only(top: 90),
                    child: _buildCardList(),
                  ),

                  // Add card panel
                  _isAddCardPanelOpen ? _buildAddCardPanel() : Container(),

                  // Floating Action Button
                  _buildFloatingActionButton(),
                ],
              ),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = AppThemes.getPrimaryColor(isDarkMode);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
          ),
          const SizedBox(height: 16),
          Text(
            'Loading cards...',
            style: TextStyle(
              fontSize: 16,
              fontFamily: 'quickie',
              color: AppThemes.getTextColor(isDarkMode),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardList() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Opacity(
      opacity: _isAddCardPanelOpen ? 0.3 : 1.0,
      child: AbsorbPointer(
        absorbing: _isAddCardPanelOpen,
        child: _cards.isEmpty
            ? _buildEmptyState()
            : ListView.builder(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                itemCount: _cards.length,
                itemBuilder: (context, index) {
                  final cardData = _cards[index];
                  return Dismissible(
                    key: Key('card_${index}_${cardData.cardNumber}'),
                    background: Container(
                      color: AppThemes.getErrorColor(isDarkMode),
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 20),
                      child: const Icon(
                        Icons.delete,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                    direction: DismissDirection.endToStart,
                    onDismissed: (direction) {
                      _deleteCard(index);
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Hero(
                        tag: 'card_${index}_${cardData.cardNumber}',
                        child: MyCard(
                          cardNumber: cardData.cardNumber,
                          expiryDate: cardData.expiryDate,
                          backgroundAsset: cardData.backgroundAsset,
                          bankLogoAsset: cardData.bankLogoAsset,
                          networkLogoAsset: cardData.networkLogoAsset,
                          onTap: () {
                            // Handle card tap
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Card ${index + 1} tapped',
                                  style: const TextStyle(
                                    fontFamily: 'quickie',
                                  ),
                                ),
                                backgroundColor:
                                    AppThemes.getPrimaryColor(isDarkMode),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }

  Widget _buildEmptyState() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.credit_card,
            size: 80,
            color: AppThemes.getSecondaryTextColor(isDarkMode),
          ),
          const SizedBox(height: 16),
          Text(
            'No cards added yet',
            style: TextStyle(
              fontSize: 20,
              fontFamily: 'poppy',
              fontWeight: FontWeight.w600,
              color: AppThemes.getTextColor(isDarkMode),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap the + button to add a new card',
            style: TextStyle(
              fontSize: 16,
              fontFamily: 'quickie',
              color: AppThemes.getSecondaryTextColor(isDarkMode),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddCardPanel() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final cardColor = AppThemes.getCardColor(isDarkMode);
    final primaryColor = AppThemes.getPrimaryColor(isDarkMode);
    final secondaryTextColor = AppThemes.getSecondaryTextColor(isDarkMode);

    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      height: 650,
      child: Container(
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(28),
            topRight: Radius.circular(28),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 15,
              spreadRadius: 2,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Column(
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 60,
              height: 5,
              decoration: BoxDecoration(
                color: secondaryTextColor.withOpacity(0.5),
                borderRadius: BorderRadius.circular(2.5),
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      children: [
                        Icon(
                          Icons.credit_card_rounded,
                          size: 28,
                          color: primaryColor,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Add New Card',
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: AppThemes.getTextColor(isDarkMode),
                                  ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Divider(
                      color: secondaryTextColor.withOpacity(0.3),
                      thickness: 1,
                    ),
                    const SizedBox(height: 16),

                    // Card Number
                    Text(
                      'Card Number',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: AppThemes.getTextColor(isDarkMode),
                      ),
                    ),
                    const SizedBox(height: 8),
                    MyTextField(
                      controller: _cardNumberController,
                      hintText: 'XXXX XXXX XXXX XXXX',
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(16),
                        CardNumberFormatter(),
                      ],
                      prefixIcon: Icon(Icons.numbers, color: primaryColor),
                    ),
                    const SizedBox(height: 20),

                    // Expiry Date
                    Text(
                      'Expiry Date',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: AppThemes.getTextColor(isDarkMode),
                      ),
                    ),
                    const SizedBox(height: 8),
                    MyTextField(
                      controller: _expiryDateController,
                      hintText: 'MM/YY',
                      keyboardType: TextInputType.datetime,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(4),
                        ExpiryDateFormatter(),
                      ],
                      prefixIcon: Icon(Icons.date_range, color: primaryColor),
                    ),
                    const SizedBox(height: 24),

                    // Bank Logo Selection
                    Text(
                      'Bank Logo',
                      style: TextStyle(
                        fontSize: 16,
                        fontFamily: 'poppy',
                        fontWeight: FontWeight.w500,
                        color: AppThemes.getTextColor(isDarkMode),
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildAssetSelector(
                      _bankLogos,
                      _selectedBankLogo,
                      (value) => setState(() => _selectedBankLogo = value),
                    ),
                    const SizedBox(height: 24),

                    Divider(
                      color: secondaryTextColor.withOpacity(0.3),
                      thickness: 1,
                    ),
                    const SizedBox(height: 16),

                    // Card Background Selection
                    Text(
                      'Card Background',
                      style: TextStyle(
                        fontSize: 16,
                        fontFamily: 'poppy',
                        fontWeight: FontWeight.w500,
                        color: AppThemes.getTextColor(isDarkMode),
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildAssetSelector(
                      _cardBgs,
                      _selectedCardBg,
                      (value) => setState(() => _selectedCardBg = value),
                      isBackground: true,
                    ),
                    const SizedBox(height: 24),

                    Divider(
                      color: secondaryTextColor.withOpacity(0.3),
                      thickness: 1,
                    ),
                    const SizedBox(height: 16),

                    // Card Type Selection
                    Text(
                      'Card Type',
                      style: TextStyle(
                        fontSize: 16,
                        fontFamily: 'poppy',
                        fontWeight: FontWeight.w500,
                        color: AppThemes.getTextColor(isDarkMode),
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildAssetSelector(
                      _cardTypes,
                      _selectedCardType,
                      (value) => setState(() => _selectedCardType = value),
                    ),
                    const SizedBox(height: 32),

                    // Add Button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _addNewCard,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: Colors.white,
                          elevation: 4,
                          shadowColor: primaryColor.withOpacity(0.4),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text(
                          'Add Card',
                          style: TextStyle(
                            fontSize: 18,
                            fontFamily: 'poppy',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
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

  Widget _buildAssetSelector(
      List<String> options, String? selectedValue, Function(String?) onChanged,
      {bool isBackground = false}) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = AppThemes.getPrimaryColor(isDarkMode);

    return SizedBox(
      height: isBackground ? 80 : 64,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: options.length,
        itemBuilder: (context, index) {
          final option = options[index];
          final isSelected = option == selectedValue;

          return GestureDetector(
            onTap: () => onChanged(option),
            child: Container(
              margin: const EdgeInsets.only(right: 16),
              width: isBackground ? 130 : 70,
              height: isBackground ? 80 : 64,
              decoration: BoxDecoration(
                border: Border.all(
                  color: isSelected
                      ? primaryColor
                      : AppThemes.getSecondaryTextColor(isDarkMode)
                          .withOpacity(0.3),
                  width: isSelected ? 2.5 : 1,
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: primaryColor.withOpacity(0.3),
                          blurRadius: 8,
                          spreadRadius: 1,
                        ),
                      ]
                    : null,
              ),
              padding: const EdgeInsets.all(8),
              child: Center(
                child: SvgPicture.asset(
                  option,
                  placeholderBuilder: (context) => Center(
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = AppThemes.getPrimaryColor(isDarkMode);

    return Positioned(
      right: 24,
      bottom: 24,
      child: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: primaryColor.withOpacity(0.4),
              blurRadius: 12,
              spreadRadius: 2,
              offset: const Offset(0, 4),
            ),
          ],
          borderRadius: BorderRadius.circular(30),
        ),
        child: FloatingActionButton.extended(
          onPressed: _toggleAddCardPanel,
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 8,
          isExtended: !_isAddCardPanelOpen,
          label: !_isAddCardPanelOpen
              ? const Text(
                  'Add Card',
                  style: TextStyle(
                    fontFamily: 'poppy',
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                )
              : const SizedBox.shrink(),
          icon: Icon(_isAddCardPanelOpen ? Icons.close : Icons.add, size: 24),
        ),
      ),
    );
  }
}

// You'll need to make sure these formatters are defined
class CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    var text = newValue.text;

    if (newValue.selection.baseOffset == 0) {
      return newValue;
    }

    var buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      buffer.write(text[i]);
      var nonZeroIndex = i + 1;
      if (nonZeroIndex % 4 == 0 && nonZeroIndex != text.length) {
        buffer.write(' ');
      }
    }

    var string = buffer.toString();
    return newValue.copyWith(
      text: string,
      selection: TextSelection.collapsed(offset: string.length),
    );
  }
}

class ExpiryDateFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    var text = newValue.text;

    if (newValue.selection.baseOffset == 0) {
      return newValue;
    }

    var buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      buffer.write(text[i]);
      var nonZeroIndex = i + 1;
      if (nonZeroIndex % 2 == 0 && nonZeroIndex != text.length) {
        buffer.write('/');
      }
    }

    var string = buffer.toString();
    return newValue.copyWith(
      text: string,
      selection: TextSelection.collapsed(offset: string.length),
    );
  }
}

class MyTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final TextInputType keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final Widget? prefixIcon;

  const MyTextField({
    super.key,
    required this.controller,
    required this.hintText,
    this.keyboardType = TextInputType.text,
    this.inputFormatters,
    this.prefixIcon,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = AppThemes.getPrimaryColor(isDarkMode);
    final textColor = AppThemes.getTextColor(isDarkMode);
    final secondaryTextColor = AppThemes.getSecondaryTextColor(isDarkMode);

    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      cursorColor: primaryColor,
      style: TextStyle(
        color: textColor,
        fontSize: 16,
        fontFamily: 'quickie',
      ),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(
          color: secondaryTextColor.withOpacity(0.7),
          fontSize: 16,
          fontFamily: 'quickie',
        ),
        prefixIcon: prefixIcon,
        filled: true,
        fillColor: isDarkMode ? Colors.grey[850] : Colors.grey[200],
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: secondaryTextColor.withOpacity(0.3),
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: primaryColor,
            width: 2,
          ),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }
}
