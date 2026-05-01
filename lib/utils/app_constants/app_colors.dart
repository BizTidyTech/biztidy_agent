import 'package:flutter/material.dart';

class AppColors {
  static Color scaffoldBackgroundColor(BuildContext context) {
    return Theme.of(context).scaffoldBackgroundColor;
  }

  static Color kPrimaryColor = fromHex("#00EFEF");

  static Color primaryThemeColor = fromHex('#00B4B4');

  static Color reviewValueColor = fromHex('#001F3F');

  static Color plainWhite = fromHex('#ffffff');

  static Color fullBlack = fromHex('#000000');

  static Color deepBlue = fromHex('#001F3F');

  static Color lightGray = fromHex('#161a1818').withValues(alpha: 0.05);

  static Color coolRed = const Color.fromARGB(255, 252, 30, 14);

  static Color lighterGray = fromHex('#0c000000').withValues(alpha: 0.02);

  static Color regularGray = fromHex('#28252021');

  static Color darkGray = fromHex('#7e1a1818');

  static Color blueGray = fromHex('#6cd3dde7');

  static Color inputFieldBlack = fromHex('#1A1819');

  static Color normalGreen = const Color.fromARGB(255, 38, 223, 50);

  static Color transparent = Colors.transparent;

  static Color fromHex(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }
}
