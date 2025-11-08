import 'package:flutter/material.dart';
import 'package:taxitaxi_driver/widgets/cab_text.dart';

import '../helpers/style.dart';

class CabButton extends StatelessWidget {
  final String text;
  final void Function() func;
  final double? width;
  final double? height;
  final double? textSize;
  final bool isLoading;
  final Color? color;
  final Color? textColor;
  const CabButton(
      {Key? key,
      required this.text,
      required this.func,
      this.height,
      this.width,
      this.textSize,
      required this.isLoading,
      this.color,
      this.textColor})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? () {} : func,
      child: Container(
          height: height ?? 52,
          width: width,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            color: color ?? primaryColor,
          ),
          child: isLoading
              ? const Center(
                  child: CircularProgressIndicator(
                      strokeWidth: 1.5, color: Colors.black),
                )
              : CabText(text,
                  color: textColor ?? Colors.black, size: textSize)),
    );
  }
}
