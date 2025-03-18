// ignore_for_file: non_constant_identifier_names

import 'package:brokecheck/app_themes.dart';
import 'package:brokecheck/tag.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Entry extends StatelessWidget {
  const Entry({
    super.key,
    required this.amount,
    required this.title,
    this.description,
    this.tags,
    required this.entryDate,
    required this.entryTime,
    this.bgColor,
    this.dividerColor,
  });

  final double amount;
  final String title;
  final String? description;
  final List<Tag>? tags;
  final DateTime entryDate;
  final TimeOfDay entryTime;
  final Color? bgColor;
  final Color? dividerColor;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Use AppThemes for consistent theming
    final backgroundColor = bgColor ?? AppThemes.getCardColor(isDark);
    final divColor = dividerColor ??
        (isDark ? const Color(0xFF424242) : const Color(0xFFE0E0E0));
    final textColor = AppThemes.getTextColor(isDark);
    final secondaryTextColor = AppThemes.getSecondaryTextColor(isDark);

    // Get border radius from theme or use default
    final borderRadius =
        Theme.of(context).cardTheme.shape is RoundedRectangleBorder
            ? (Theme.of(context).cardTheme.shape as RoundedRectangleBorder)
                .borderRadius
            : BorderRadius.circular(10);

    return LayoutBuilder(builder: (context, constraints) {
      // Adjust text sizes based on available width
      final double titleSize = constraints.maxWidth < 300 ? 16.0 : 18.0;
      final double amountSize = constraints.maxWidth < 300 ? 20.0 : 24.0;
      final double descriptionSize = constraints.maxWidth < 300 ? 14.0 : 16.0;

      // Format date and time in a more readable way
      final String formattedDate = DateFormat('MMM dd, yyyy').format(entryDate);
      final String formattedTime = entryTime.format(context);

      return Card(
        shape: RoundedRectangleBorder(borderRadius: borderRadius),
        color: backgroundColor,
        elevation: 2,
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 0),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: titleSize,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                        fontFamily: 'poppy',
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Row(
                    children: [
                      // Add a small icon to indicate transaction type
                      Icon(
                        amount > 0 ? Icons.arrow_downward : Icons.arrow_upward,
                        size: 14,
                        color: which_color(amount, isDark),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        NumberFormat.currency(
                          locale: 'en_US',
                          symbol: '\$',
                          decimalDigits: 2,
                        ).format(amount.abs()),
                        style: TextStyle(
                          fontSize: amountSize,
                          fontWeight: FontWeight.bold,
                          color: which_color(amount, isDark),
                          fontFamily: 'poppy',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 4),
              SizedBox(
                width: double.infinity,
                child: Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children: tags ?? [Tag(tagLabel: "Cash")],
                ),
              ),
              if (description != null && description!.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  description!,
                  style: TextStyle(
                    color: secondaryTextColor,
                    fontSize: descriptionSize,
                    fontFamily: 'quickie',
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
              ],
              const SizedBox(height: 8),
              Divider(
                color: divColor,
                height: 1,
                thickness: 1,
              ),
              const SizedBox(height: 6),
              Text(
                '$formattedDate at $formattedTime',
                style: TextStyle(
                  fontSize: 12,
                  color: secondaryTextColor,
                  fontFamily: 'quickie',
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      );
    });
  }

  Color which_color(double number, bool isDark) {
    if (number < 0) {
      return AppThemes.getErrorColor(isDark);
    }
    return isDark
        ? const Color(0xFF66BB6A)
        : const Color(0xFF4CAF50); // Using success colors from theme
  }
}
