import 'package:flutter/material.dart';

class CustomTextField extends StatefulWidget {
  const CustomTextField({
    super.key,
    required this.label,
    required this.controller,
    required this.isPassword,
    required this.width,
    required this.height,
  });

  final String label;
  final TextEditingController controller;
  final bool isPassword;
  final double width;
  final double height;

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  @override
  Widget build(BuildContext context) {
    return Placeholder(
      color: Colors.transparent,
      child: SizedBox(
        width: widget.width,
        height: widget.height,
        child: TextFormField(
          obscureText: widget.isPassword,
          style: const TextStyle(
            color: Colors.black,
          ),
          decoration: InputDecoration(
            labelText: widget.label,
            border: const OutlineInputBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(10),
              ),
              borderSide: BorderSide(
                strokeAlign: BorderSide.strokeAlignOutside,
                width: 2,
              ),
            ),
          ),
          controller: widget.controller,
        ),
      ),
    );
  }
}
