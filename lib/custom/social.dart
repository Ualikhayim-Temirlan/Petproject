import 'package:flutter/material.dart';

class SocialButton extends StatelessWidget {
  final String iconPath;
  final VoidCallback onPressed;

  const SocialButton({
    super.key,
    required this.iconPath,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Image.asset(
            iconPath,
            height: 24,
            width: 24,
          ),
        ),
      ),
    );
  }
}