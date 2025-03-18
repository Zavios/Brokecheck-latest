import 'package:flutter/material.dart';

class Tag extends StatelessWidget {
  const Tag(
      {this.tagLabel = "Dawwdaawdad",
      this.color = const Color.fromRGBO(110, 0, 252, .26),
      super.key});

  final String tagLabel;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Container(
        color: color,
        padding: EdgeInsetsDirectional.symmetric(horizontal: 8, vertical: 4),
        child: Text(tagLabel,
            style: TextStyle(
                color: Color.fromRGBO(110, 0, 252, 1),
                fontSize: 12,
                fontWeight: FontWeight.w400)),
      ),
    );
  }
}
