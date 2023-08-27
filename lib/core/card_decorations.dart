import 'package:flutter/material.dart';

mixin CardDecorations {
  static final BoxDecoration boxDecoration = BoxDecoration(
    color: Colors.white,
    boxShadow: [
      BoxShadow(
        color: Colors.grey,
        spreadRadius: 0,
        blurRadius: 20,
        offset: const Offset(0, 2),
      ),
    ],
    borderRadius: BorderRadius.circular(10),
  );

  /*
  static final BoxDecoration boxDecoration3 = BoxDecoration(
    color: Colors.white,
    boxShadow: [
      BoxShadow(
        color: AppColors.lighttertiaryGrey,
        spreadRadius: 5,
        blurRadius: 15,
        offset: const Offset(0, 3),
      ),
    ],
    borderRadius: BorderRadius.circular(10),
  );
  */
}