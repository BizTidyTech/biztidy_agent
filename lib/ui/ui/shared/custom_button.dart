// ignore_for_file: avoid_print

import 'package:biztidy_agent_app/utils/app_constants/app_colors.dart';
import 'package:biztidy_agent_app/utils/app_constants/app_styles.dart';
import 'package:biztidy_agent_app/utils/extension_and_methods/screen_utils.dart';
import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final Widget? child;
  final double? width;
  final double? height;
  final Color? color;
  final Color? borderColor;
  final double? borderRadius;
  final String? buttonText;
  final double? fontSize;
  final Color? textcolor;
  final void Function()? onPressed;

  const CustomButton({
    super.key,
    this.width,
    this.height,
    this.child,
    this.color,
    this.onPressed,
    this.borderRadius,
    this.borderColor,
    this.buttonText,
    this.fontSize,
    this.textcolor,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed ??
          () {
            print('Custom Button pressed');
          },
      style: TextButton.styleFrom(
        fixedSize: Size(width ?? screenWidth(context) * 0.75, height ?? 50),
        padding: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius ?? 10),
          side: BorderSide(
            color: borderColor ?? AppColors.deepBlue,
            width: 2.0,
          ),
        ),
        backgroundColor: color ?? AppColors.deepBlue,
      ),
      child: child ??
          Text(
            buttonText ?? '',
            style: AppStyles.subStringStyle(
              fontSize ?? 18,
              textcolor ?? AppColors.kPrimaryColor,
            ),
          ),
    );
  }
}
