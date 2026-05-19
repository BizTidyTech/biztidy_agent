import 'package:flutter/material.dart';

// Pre-built SizedBox instances for the most common spacer sizes.
// Flutter sees the same const object and skips diffing entirely.
const _v4  = SizedBox(height: 4);
const _v6  = SizedBox(height: 6);
const _v8  = SizedBox(height: 8);
const _v10 = SizedBox(height: 10);
const _v12 = SizedBox(height: 12);
const _v14 = SizedBox(height: 14);
const _v16 = SizedBox(height: 16);
const _v20 = SizedBox(height: 20);
const _v28 = SizedBox(height: 28);
const _h8  = SizedBox(width: 8);
const _h12 = SizedBox(width: 12);
const _h16 = SizedBox(width: 16);

// ignore: non_constant_identifier_names
Widget verticalSpacer(double size) {
  switch (size) {
    case 4:  return _v4;
    case 6:  return _v6;
    case 8:  return _v8;
    case 10: return _v10;
    case 12: return _v12;
    case 14: return _v14;
    case 16: return _v16;
    case 20: return _v20;
    case 28: return _v28;
    default: return SizedBox(height: size);
  }
}

Widget horizontalSpacer(double size) {
  switch (size) {
    case 8:  return _h8;
    case 12: return _h12;
    case 16: return _h16;
    default: return SizedBox(width: size);
  }
}
