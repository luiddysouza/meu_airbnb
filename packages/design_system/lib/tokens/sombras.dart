import 'package:flutter/material.dart';

abstract final class DsSombras {
  static const List<BoxShadow> nivel1 = [
    BoxShadow(color: Color(0x1A000000), blurRadius: 4, offset: Offset(0, 1)),
  ];

  static const List<BoxShadow> nivel2 = [
    BoxShadow(color: Color(0x1F000000), blurRadius: 8, offset: Offset(0, 2)),
    BoxShadow(color: Color(0x0F000000), blurRadius: 4, offset: Offset(0, 1)),
  ];

  static const List<BoxShadow> nivel3 = [
    BoxShadow(color: Color(0x29000000), blurRadius: 16, offset: Offset(0, 4)),
    BoxShadow(color: Color(0x14000000), blurRadius: 8, offset: Offset(0, 2)),
  ];
}
