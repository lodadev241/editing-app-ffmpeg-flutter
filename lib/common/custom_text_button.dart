import 'package:flutter/material.dart';

class CustomTextButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final Icon icon;
  const CustomTextButton({
    super.key,
    required this.label,
    required this.onPressed,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: onPressed,
      label: Text(label),
      style: ButtonStyle(
        backgroundColor: WidgetStatePropertyAll(Colors.grey.shade200),
        foregroundColor: const WidgetStatePropertyAll(Colors.black),
        textStyle: const WidgetStatePropertyAll(
          TextStyle(
            fontSize: 18,
          ),
        ),
      ),
      icon: icon,
    );
  }
}
