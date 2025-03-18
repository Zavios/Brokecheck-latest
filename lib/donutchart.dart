// ignore_for_file: depend_on_referenced_packages, deprecated_member_use

import 'package:brokecheck/customarc.dart';
import 'package:brokecheck/graphlabels.dart';
import 'package:flutter/material.dart';
import 'package:vector_math/vector_math.dart' as vector_math;

import 'dart:math' show cos, sin, pi, min;

class DonutChart extends StatefulWidget {
  const DonutChart({
    super.key,
    this.perc1 = 10,
    this.perc2 = 40,
    this.perc3 = 25,
    this.perc4 = 25,
    this.color1 = const Color.fromRGBO(52, 120, 247, 1),
    this.color2 = const Color.fromRGBO(115, 92, 216, 1),
    this.color3 = const Color.fromRGBO(254, 168, 0, 1),
    this.color4 = const Color.fromRGBO(54, 198, 84, 1),
    this.icon1 = const Icon(
      Icons.fastfood,
      color: Colors.white,
    ),
    this.icon2 = const Icon(
      Icons.drive_eta,
      color: Colors.white,
    ),
    this.icon3 = const Icon(
      Icons.bolt_rounded,
      color: Colors.white,
    ),
    this.icon4 = const Icon(
      Icons.category_rounded,
      color: Colors.white,
    ),
    this.title1 = "Food",
    this.title2 = "Travel",
    this.title3 = "Utility",
    this.title4 = "Others",
    this.strokeWidth = 20,
    this.gapDegrees = 15,
    this.labelStyle,
  });

  final int perc1;
  final int perc2;
  final int perc3;
  final int perc4;
  final Color color1;
  final Color color2;
  final Color color3;
  final Color color4;
  final Icon icon1;
  final Icon icon2;
  final Icon icon3;
  final Icon icon4;
  final String title1;
  final String title2;
  final String title3;
  final String title4;
  final double strokeWidth;
  final double gapDegrees; // Gap between arcs in degrees
  final TextStyle? labelStyle;

  @override
  State<DonutChart> createState() => _DonutChartState();
}

class _DonutChartState extends State<DonutChart> {
  @override
  Widget build(BuildContext context) {
    // Get theme properties
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final primaryColor = Theme.of(context).primaryColor;
    final textTheme = Theme.of(context).textTheme;

    // Use screen size for responsiveness
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 360;

    // Calculate responsive radius based on screen width
    final double chartRadius = min(screenSize.width * 0.28, 120.0);
    final double adaptiveStrokeWidth = min(widget.strokeWidth, chartRadius / 4);

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(chartRadius * 0.15),
                constraints: BoxConstraints(
                  maxWidth: constraints.maxWidth,
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox.fromSize(
                      size: Size.fromRadius(chartRadius),
                      child: CustomPaint(
                        painter: _DonutChartPainter(
                          strokeWidth: adaptiveStrokeWidth,
                          perc1: widget.perc1,
                          perc2: widget.perc2,
                          perc3: widget.perc3,
                          perc4: widget.perc4,
                          color1: widget.color1,
                          color2: widget.color2,
                          color3: widget.color3,
                          color4: widget.color4,
                          gapDegrees: widget.gapDegrees,
                          labelStyle: widget.labelStyle ??
                              textTheme.labelMedium?.copyWith(
                                color: Colors.white,
                                fontSize: isSmallScreen ? 12 : 16,
                                fontWeight: FontWeight.bold,
                              ) ??
                              const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                          isDarkMode: isDarkMode,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {}, // Add function on click to swap the details
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 12,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Spends",
                                  style: textTheme.labelMedium?.copyWith(
                                    fontSize: isSmallScreen ? 12 : 16,
                                  ),
                                ),
                                Icon(
                                  Icons.arrow_drop_down,
                                  color: primaryColor,
                                  size: isSmallScreen ? 18 : 24,
                                ),
                              ],
                            ),
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                "1,000,000",
                                style: textTheme.titleLarge?.copyWith(
                                  fontSize: isSmallScreen ? 20 : 28,
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
              const SizedBox(height: 5),
              Text(
                'Net Balance: 1,234',
                style: textTheme.titleMedium?.copyWith(
                  fontSize: isSmallScreen ? 16 : 20,
                ),
              ),
              const SizedBox(height: 10),
              LayoutBuilder(
                builder: (context, constraints) {
                  return GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: constraints.maxWidth > 500 ? 4 : 2,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                    childAspectRatio: isSmallScreen ? 1.3 : 1.5,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    children: [
                      Graphlabels(
                        amount: 8,
                        title: widget.title1,
                        color: widget.color1,
                        icon: widget.icon1,
                        percentage: widget.perc1,
                      ),
                      Graphlabels(
                        color: widget.color2,
                        amount: 8,
                        icon: widget.icon2,
                        title: widget.title2,
                        percentage: widget.perc2,
                      ),
                      Graphlabels(
                        amount: 9,
                        color: widget.color3,
                        icon: widget.icon3,
                        title: widget.title3,
                        percentage: widget.perc3,
                      ),
                      Graphlabels(
                        percentage: widget.perc4,
                        amount: 8,
                        color: widget.color4,
                        icon: widget.icon4,
                        title: widget.title4,
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class _DonutChartPainter extends CustomPainter {
  const _DonutChartPainter({
    required this.strokeWidth,
    required this.perc1,
    required this.perc2,
    required this.perc3,
    required this.perc4,
    required this.color1,
    required this.color2,
    required this.color3,
    required this.color4,
    required this.gapDegrees,
    required this.labelStyle,
    required this.isDarkMode,
  });

  final double strokeWidth;
  final int perc1;
  final int perc2;
  final int perc3;
  final int perc4;
  final Color color1;
  final Color color2;
  final Color color3;
  final Color color4;
  final double gapDegrees;
  final TextStyle labelStyle;
  final bool isDarkMode;

  @override
  void paint(Canvas canvas, Size size) {
    // Set center point at the center of the container
    final Offset center = Offset(size.width / 2, size.height / 2);
    final double radius = size.width / 2;

    // Calculate gaps in radians
    final double gapRadians = vector_math.radians(gapDegrees);

    // Calculate total gap space
    final int numGaps = 4; // Number of gaps between segments
    final double totalGapRadians = gapRadians * numGaps;

    // Calculate total percentage and angles
    final double total = (perc1 + perc2 + perc3 + perc4).toDouble();
    final double availableAngle = 2 * pi - totalGapRadians;

    // Calculate segment angles including gaps
    double perc1Radians = (perc1 / total) * availableAngle;
    double perc2Radians = (perc2 / total) * availableAngle;
    double perc3Radians = (perc3 / total) * availableAngle;
    double perc4Radians = (perc4 / total) * availableAngle;

    // Start angle (top of the circle, -90 degrees)
    double startAngle = vector_math.radians(-90);

    // Create paints for each segment
    Paint paint1 = Paint()
      ..color = color1
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    Paint paint2 = Paint()
      ..color = color2
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    Paint paint3 = Paint()
      ..color = color3
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    Paint paint4 = Paint()
      ..color = color4
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    final List<CustomArc> customarcs = [
      CustomArc(
          color: color1,
          paint: paint1,
          percetage: perc1,
          percetageRadian: perc1Radians),
      CustomArc(
          color: color2,
          paint: paint2,
          percetage: perc2,
          percetageRadian: perc2Radians),
      CustomArc(
          color: color3,
          paint: paint3,
          percetage: perc3,
          percetageRadian: perc3Radians),
      CustomArc(
          color: color4,
          paint: paint4,
          percetage: perc4,
          percetageRadian: perc4Radians),
    ];

    // Responsible for creating the arcs and percentage labels
    for (var ca in customarcs) {
      canvas.drawArc(
          Rect.fromCircle(center: center, radius: radius - strokeWidth / 2),
          startAngle,
          ca.percetageRadian,
          false,
          ca.paint);

      // Only draw percentage labels if there's enough space (show for larger percentages)
      if (ca.percetage >= 10 && radius > 40) {
        _drawPercentage(
            canvas: canvas,
            center: center,
            radius: radius,
            startAngle: startAngle,
            sweepAngle: ca.percetageRadian,
            percentage: ca.percetage,
            color: ca.color);
      }

      startAngle += ca.percetageRadian + gapRadians;
    }
  }

  void _drawPercentage({
    required Canvas canvas,
    required Offset center,
    required double radius,
    required double startAngle,
    required double sweepAngle,
    required int percentage,
    required Color color,
  }) {
    // Skip if percentage is too small to show clearly
    if (percentage < 10 || radius < 40) return;

    // Calculate the angle at the middle of the arc
    final double midAngle = startAngle + (sweepAngle / 2);

    // Position for the percentage text - outside the stroke
    // Scale the label distance based on the radius size
    final double labelRadius = radius * (radius < 60 ? 0.9 : 1.1);
    final double x = center.dx + labelRadius * cos(midAngle);
    final double y = center.dy + labelRadius * sin(midAngle);

    // Percentage text
    final String displayText = '$percentage%';

    // Adjust text size based on chart size
    final double textSize =
        radius < 60 ? labelStyle.fontSize! * 0.8 : labelStyle.fontSize!;

    // Create text painter
    final TextSpan span = TextSpan(
      text: displayText,
      style: labelStyle.copyWith(
        color: color,
        fontSize: textSize,
      ),
    );

    final TextPainter tp = TextPainter(
      text: span,
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );

    // Layout the text
    tp.layout();

    // Calculate background size based on text size
    final double padding = radius < 60 ? 8 : 12;

    // Glassmorphic background
    final Rect textBgRect = Rect.fromCenter(
      center: Offset(x, y),
      width: tp.width + padding,
      height: tp.height + padding * 0.6,
    );

    // Create glassmorphic effect
    final RRect glassBg =
        RRect.fromRectAndRadius(textBgRect, Radius.circular(padding * 0.5));

    // Draw blur effect
    canvas.saveLayer(textBgRect, Paint());

    // Draw background with opacity based on theme
    canvas.drawRRect(
        glassBg,
        Paint()
          ..color =
              (isDarkMode ? Colors.black : Colors.white).withOpacity(0.7));

    // Add light border
    canvas.drawRRect(
      glassBg,
      Paint()
        ..color = (isDarkMode ? Colors.white : Colors.black).withOpacity(0.2)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.5,
    );

    canvas.restore();

    // Draw the text centered on the calculated position
    tp.paint(
      canvas,
      Offset(x - tp.width / 2, y - tp.height / 2),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
