import 'package:brokecheck/mybutton.dart';
import 'package:flutter/material.dart';
import 'package:brokecheck/login.dart';

class GetStartedPage extends StatelessWidget {
  const GetStartedPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Get screen dimensions
    final Size screenSize = MediaQuery.of(context).size;
    final double screenHeight = screenSize.height;
    final double screenWidth = screenSize.width;

    // Calculate responsive sizes
    final double logoSize =
        screenWidth * 0.35; // Increased to 35% of screen width
    final double maxLogoSize = 180; // Increased max size
    final double titleFontSize = screenWidth * 0.12;
    final double maxTitleFontSize = 50;
    final double sloganFontSize = screenWidth * 0.04;
    final double maxSloganFontSize = 20;
    final double buttonHeight = 60; // Increased button height

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("images/bg5.jpg"),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Center(
            // Centering the entire content
            child: Column(
              mainAxisAlignment:
                  MainAxisAlignment.center, // Center content vertically
              children: [
                // Logo and text section - takes most of the space
                Expanded(
                  flex: 3, // Give more space to the logo and text
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment
                          .center, // Center within this section
                      children: [
                        // Logo Image
                        Image.asset(
                          "images/Brokecheck Logo.png",
                          height:
                              logoSize > maxLogoSize ? maxLogoSize : logoSize,
                          width:
                              logoSize > maxLogoSize ? maxLogoSize : logoSize,
                        ),
                        SizedBox(
                            height: screenHeight * 0.03), // Increased spacing

                        // Slogan and App Name
                        Text(
                          "BROKECHECK",
                          style: TextStyle(
                            fontSize: titleFontSize > maxTitleFontSize
                                ? maxTitleFontSize
                                : titleFontSize,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'quickie',
                          ),
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          "WHERE BROKE MEETS BALANCE",
                          style: TextStyle(
                            fontSize: sloganFontSize > maxSloganFontSize
                                ? maxSloganFontSize
                                : sloganFontSize,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'quickie',
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),

                // Button section - takes less space but stays at bottom
                Expanded(
                  flex: 1, // Less space for button section
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.23,
                      ),
                      child: SizedBox(
                        width: double.infinity,
                        height: buttonHeight, // Using your defined buttonHeight
                        child: Mybutton(
                          text: "Get Started",
                          onTap: () {
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              builder: (context) => const LoginSignupModal(),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
