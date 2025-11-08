import 'package:flutter/material.dart';

class CabText extends StatelessWidget {
  final String text;
  final double? size;
  final FontWeight? weight;
  final Color? color;
  final TextAlign? align;
  final int? maxLines;
  final double? spacing;

  const CabText(this.text,
      {Key? key,
      this.size,
      this.weight,
      this.color,
      this.align,
      this.maxLines,
      this.spacing})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: align,
      style: TextStyle(
          letterSpacing: spacing ?? 1.3,
          color: color ?? const Color(0xFF080808),
          fontWeight: weight ?? FontWeight.w400,
          fontSize: size ?? 17),
    );
  }
}
