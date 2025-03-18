import 'package:flutter/material.dart';

class Mybutton extends StatelessWidget {
  final String text;
  final void Function()? onTap;
  const Mybutton({super.key, required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(50),
        ),
        padding: const EdgeInsets.all(15),
        child: Center(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 22,
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontFamily: 'quickie',
            ),
          ),
        ),
      ),
    );
  }
}
