import 'package:flutter/material.dart';

class CustomSnackbar extends SnackBar {
  CustomSnackbar({
    super.key,
    required String content,
    required double width,
    required int seconds,
  }) : super(
          content: Text(
            content,
            textAlign: TextAlign.center,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          width: width,
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: seconds),
        );
}
