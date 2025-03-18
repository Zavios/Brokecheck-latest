// card_components.dart
// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:brokecheck/app_themes.dart';

// Custom formatter for card number (XXXX XXXX XXXX XXXX)
class CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    // Remove all previous spaces
    String text = newValue.text.replaceAll(' ', '');

    // Add spaces after every 4 characters
    final buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      buffer.write(text[i]);
      if ((i + 1) % 4 == 0 && i != text.length - 1) {
        buffer.write(' ');
      }
    }

    final formattedText = buffer.toString();

    return newValue.copyWith(
      text: formattedText,
      selection: TextSelection.collapsed(offset: formattedText.length),
    );
  }
}

// Custom formatter for expiry date (MM/YY)
class ExpiryDateFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    // Remove all previous slashes
    String text = newValue.text.replaceAll('/', '');

    if (text.length > 2) {
      // Format as MM/YY
      final buffer = StringBuffer();
      buffer.write(text.substring(0, 2));
      buffer.write('/');
      buffer.write(text.substring(2));

      final formattedText = buffer.toString();

      return newValue.copyWith(
        text: formattedText,
        selection: TextSelection.collapsed(offset: formattedText.length),
      );
    }

    return newValue;
  }
}

// Custom TextField widget
class MyTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final TextInputType keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final Widget? prefixIcon;
  final bool obscureText;

  const MyTextField({
    super.key,
    required this.controller,
    required this.hintText,
    this.keyboardType = TextInputType.text,
    this.inputFormatters,
    this.prefixIcon,
    this.obscureText = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = AppThemes.getPrimaryColor(isDarkMode);
    final textColor = AppThemes.getTextColor(isDarkMode);
    final backgroundColor = AppThemes.getCardColor(isDarkMode);

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppThemes.getSecondaryTextColor(isDarkMode).withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        obscureText: obscureText,
        style: TextStyle(
          fontSize: 16,
          fontFamily: 'poppy',
          color: textColor,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(
            color: AppThemes.getSecondaryTextColor(isDarkMode),
            fontFamily: 'quickie',
          ),
          prefixIcon: prefixIcon,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          border: InputBorder.none,
          focusedBorder: InputBorder.none,
          enabledBorder: InputBorder.none,
          errorBorder: InputBorder.none,
          disabledBorder: InputBorder.none,
        ),
        cursorColor: primaryColor,
      ),
    );
  }
}

// Data model for card information
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
}

class MyCard extends StatelessWidget {
  final String cardNumber;
  final String expiryDate;
  final String? backgroundAsset;
  final String? bankLogoAsset;
  final String? networkLogoAsset;
  final VoidCallback onTap;

  const MyCard({
    super.key,
    required this.cardNumber,
    required this.expiryDate,
    this.backgroundAsset,
    this.bankLogoAsset,
    this.networkLogoAsset,
    required this.onTap,
  });

  String _formatCardNumber(String number) {
    // Show last 4 digits, mask the rest
    if (number.length > 4) {
      final visiblePart = number.substring(number.length - 4);
      final maskedPart =
          number.substring(0, number.length - 4).replaceAll(RegExp(r'\d'), '•');

      // Format with spaces every 4 characters
      final formattedMasked = maskedPart.replaceAll(' ', '');
      final buffer = StringBuffer();
      for (int i = 0; i < formattedMasked.length; i++) {
        buffer.write(formattedMasked[i]);
        if ((i + 1) % 4 == 0 && i != formattedMasked.length - 1) {
          buffer.write(' ');
        }
      }

      return '${buffer.toString()} $visiblePart';
    }
    return number;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 220,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              // Card Background
              if (backgroundAsset != null)
                Positioned.fill(
                  child: SvgPicture.asset(
                    backgroundAsset!,
                    fit: BoxFit.cover,
                    placeholderBuilder: (context) => Container(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.grey[800]
                          : Colors.grey[300],
                    ),
                  ),
                )
              else
                Container(
                  decoration: BoxDecoration(
                    gradient: AppThemes.getPrimaryGradient(
                        Theme.of(context).brightness == Brightness.dark),
                  ),
                ),

              // Card content
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Bank Logo
                    if (bankLogoAsset != null)
                      SizedBox(
                        height: 40,
                        child: SvgPicture.asset(
                          bankLogoAsset!,
                          placeholderBuilder: (context) => Container(
                            width: 60,
                            height: 40,
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                    ? Colors.grey[800]
                                    : Colors.grey[300],
                          ),
                        ),
                      ),

                    const Spacer(),

                    // Card Number
                    Text(
                      _formatCardNumber(cardNumber),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontFamily: 'poppy',
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Expiry Date
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'VALID THRU',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 10,
                                fontFamily: 'quickie',
                                letterSpacing: 1,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              expiryDate,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontFamily: 'quickie',
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),

                        // Network Logo
                        if (networkLogoAsset != null)
                          SizedBox(
                            height: 34,
                            child: SvgPicture.asset(
                              networkLogoAsset!,
                              placeholderBuilder: (context) => Container(
                                width: 50,
                                height: 30,
                                color: Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? Colors.grey[800]
                                    : Colors.grey[300],
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
        ),
      ),
    );
  }
}
