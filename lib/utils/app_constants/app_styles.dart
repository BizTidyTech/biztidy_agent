// ignore_for_file: unused_field

import 'package:biztidy_agent_app/utils/app_constants/app_colors.dart';
import 'package:flutter/material.dart';

class AppStyles {
  ///TextStyles
  static const FontWeight _lightWeight = FontWeight.w300;
  static const FontWeight _semiBoldWeight = FontWeight.w600;
  static const FontWeight _extraBoldWeight = FontWeight.w800;
  static const FontWeight _normalWeight = FontWeight.w400;
  static const FontWeight _regularWeight = FontWeight.w500;
  static const FontWeight _boldWeight = FontWeight.w700;

  // ── Cached TextStyle instances ─────────────────────────────────────────────
  // AppStyles methods are called 136 times across the app — every call that
  // hits the same (size, color) pair reuses the same TextStyle object instead
  // of allocating a new one. Key format: 'methodPrefix_size_colorToken'.
  static final Map<String, TextStyle> _cache = {};

  static TextStyle _cached(String key, TextStyle Function() build) =>
      _cache.putIfAbsent(key, build);

  static TextStyle navBarStringStyle(Color color) => _cached(
        'nav_${color.toARGB32()}',
        () => _base(10, _regularWeight, color),
      );

  static TextStyle defaultKeyStringStyle(double fontSize, String family) =>
      _cached(
        'defKey_${fontSize}_$family',
        () => _base(fontSize, _semiBoldWeight, AppColors.deepBlue, family: family),
      );

  static TextStyle keyStringStyle(double fontSize, Color textcolor) => _cached(
        'key_${fontSize}_${textcolor.toARGB32()}',
        () => _base(fontSize, _boldWeight, textcolor),
      );

  static TextStyle regularStringStyle(double fontSize, Color textcolor,
          {String? family}) =>
      _cached(
        'reg_${fontSize}_${textcolor.toARGB32()}_${family ?? ''}',
        () => _base(fontSize, _semiBoldWeight, textcolor, family: family),
      );

  static TextStyle normalStringStyle(double fontSize, Color textcolor,
          {String? family}) =>
      _cached(
        'norm_${fontSize}_${textcolor.toARGB32()}_${family ?? ''}',
        () => _base(fontSize, _regularWeight, textcolor, family: family),
      );

  static TextStyle subStringStyle(double fontSize, Color textcolor) => _cached(
        'sub_${fontSize}_${textcolor.toARGB32()}',
        () => _base(fontSize, _normalWeight, textcolor),
      );

  static TextStyle inputStringStyle(Color textcolor) => _cached(
        'input_${textcolor.toARGB32()}',
        () => _base(12, _semiBoldWeight, textcolor),
      );

  static TextStyle hintStringStyle(double fontSize) => _cached(
        'hint_$fontSize',
        () => _base(fontSize, _regularWeight, AppColors.darkGray),
      );

  static TextStyle floatingHintStringStyle(double fontSize, {Color? color}) =>
      _cached(
        'floatHint_${fontSize}_${(color ?? AppColors.lightGray).toARGB32()}',
        () => _base(
          fontSize,
          _regularWeight,
          color ?? AppColors.lightGray.withValues(alpha: 0.4),
        ),
      );

  static TextStyle floatingHintStringStyleColored(
          double fontSize, Color color) =>
      _cached(
        'floatHintC_${fontSize}_${color.toARGB32()}',
        () => _base(fontSize, _normalWeight, color),
      );

  //#base style
  static TextStyle _base(double size, FontWeight? fontWeight, Color? color,
      {String? family}) {
    return baseStyle(
        fontSize: size, fontWeight: fontWeight, color: color, family: family);
  }

  static TextStyle baseStyle({
    double fontSize = 10,
    FontWeight? fontWeight,
    Color? color,
    String? family,
  }) {
    return TextStyle(
      fontSize: fontSize,
      fontFamily: family ?? 'OpenSans',
      fontWeight: fontWeight ?? _normalWeight,
      color: color ?? AppColors.darkGray,
    );
  }
}
