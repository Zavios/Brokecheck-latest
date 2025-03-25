// ignore_for_file: non_constant_identifier_names

import 'package:flutter/material.dart';
// import 'donutchart.dart' show DonutChart;

class Graphlabels extends StatefulWidget {
  const Graphlabels({
    super.key,
    required this.icon,
    required this.amount,
    required this.percentage,
    required this.title,
    required this.color,
  });

  final Icon icon;
  final double amount;
  final int percentage;
  final String title;
  final Color color;

  @override
  State<Graphlabels> createState() => _GraphlabelsState();
}

class _GraphlabelsState extends State<Graphlabels> {
  TextStyle t1 = TextStyle(fontSize: 12, fontWeight: FontWeight.w400);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final primaryColor = Theme.of(context).primaryColor;
    final textTheme = Theme.of(context).textTheme;

    // Use screen size for responsiveness
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 360;

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 100,
        width: 160,
        color: isDarkMode ? Colors.black : Colors.white,
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Rs. ${widget.amount}",
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                ),
                Text(
                  "${widget.percentage}%",
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
                )
              ],
            ),
            const Spacer(),
            Row(
              children: [
                Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(1100)),
                        color: widget.color),
                    height: 40,
                    width: 40,
                    // color: Colors.amber,
                    child: widget.icon),
                const SizedBox(
                  width: 8,
                ),
                Expanded(
                  child: Text(
                    widget.title,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    softWrap: true,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  Icon get_formated_icon(IconData icon) {
    return Icon(
      icon,
      size: 20,
      color: Colors.white,
    );
  }
}
