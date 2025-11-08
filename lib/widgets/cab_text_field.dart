import 'package:flutter/material.dart';
import 'package:taxitaxi_driver/helpers/methods.dart';

import '../helpers/style.dart';
import 'cab_text.dart';

class CabTextField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final bool isPassword;
  final FocusNode? node;
  final FocusNode? nextNode;
  final TextInputType? type;
  final TextInputAction? action;
  final bool? isEnabled;
  final Widget? suffixIcon;
  final void Function()? onSubmit;
  final void Function(String?)? func;
  final String? headerText;
  final Widget? icon;
  const CabTextField(
      {Key? key,
      required this.controller,
      required this.hintText,
      required this.isPassword,
      this.node,
      this.func,
      this.nextNode,
      this.type,
      this.action,
      this.isEnabled,
      this.headerText,
      this.suffixIcon,
      this.onSubmit,
      this.icon})
      : super(key: key);

  @override
  State<CabTextField> createState() => _CabTextFieldState();
}

class _CabTextFieldState extends State<CabTextField> {
  bool isHidden = true;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        widget.headerText != null
            ? Padding(
                padding: const EdgeInsets.only(bottom: 12, left: 2),
                child: CabText(widget.headerText!))
            : const SizedBox(),
        TextFormField(
          onEditingComplete: widget.onSubmit,
          controller: widget.controller,
          focusNode: widget.node,
          autovalidateMode: widget.suffixIcon == null
              ? AutovalidateMode.onUserInteraction
              : AutovalidateMode.disabled,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return '${widget.hintText.capitalize()} is Required';
            }
            if (value.length < 8 && widget.isPassword) {
              return '${widget.hintText.capitalize()} is too Short';
            }
            return null;
          },
          onFieldSubmitted: (_) {
            if (widget.nextNode != null) {
              FocusScope.of(context).requestFocus(widget.nextNode);
            } else {
              FocusScope.of(context).unfocus();
            }
          },
          cursorColor: const Color(0xFF080808),
          cursorWidth: 1.5,
          cursorHeight: 16,
          obscureText: widget.isPassword && isHidden,
          enabled: widget.isEnabled ?? true,
          textInputAction: widget.action,
          keyboardType: widget.type,
          style: const TextStyle(fontSize: 14, height: 1),
          decoration: InputDecoration(
              // fillColor: widget.isEnabled != null
              //     ? iconColor.withOpacity(.25)
              //     : backgroundColor,
              prefixIcon: widget.icon,
              suffixIcon: widget.isPassword
                  ? GestureDetector(
                      onTap: () {
                        isHidden = !isHidden;
                        setState(() {});
                      },
                      child: Icon(
                          isHidden ? Icons.visibility_off : Icons.visibility,
                          color: primaryColor),
                    )
                  : widget.suffixIcon,
              hintText: widget.hintText,
              hintStyle: const TextStyle(
                  fontSize: 14,
                  height: 1,
                  fontWeight: FontWeight.w300,
                  color: Colors.grey),
              errorBorder: errorBorder,
              focusedBorder: border,
              enabledBorder: border,
              focusedErrorBorder: errorBorder,
              border: border),
        ),
      ],
    );
  }
}
