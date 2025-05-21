import 'package:flutter/material.dart';

class CustomTextField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final IconData prefixIcon;
  final bool obscureText;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.prefixIcon,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.validator,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool _obscureText = true;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      obscureText: widget.obscureText ? _obscureText : false,
      keyboardType: widget.keyboardType,
      validator: widget.validator,
      style: const TextStyle(fontSize: 16),
      decoration: InputDecoration(
        hintText: widget.hintText,
        prefixIcon: Icon(widget.prefixIcon, color: Theme.of(context).primaryColor),
        suffixIcon: widget.obscureText
            ? IconButton(
                icon: Icon(
                  _obscureText ? Icons.visibility_off : Icons.visibility,
                  color: Colors.grey,
                ),
                onPressed: () {
                  setState(() {
                    _obscureText = !_obscureText;
                  });
                },
              )
            : null,
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(width: 3, color: Colors.blueGrey),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(width: 2, color: Colors.lightBlue),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(width: 2, color: Colors.lightBlue),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(width: 1, color: Colors.red),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
    );
  }
}