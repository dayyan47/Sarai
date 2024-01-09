import 'dart:ui';
import 'package:flutter/material.dart';

class MyCustomScrollBehaviour extends MaterialScrollBehavior{
  @override
  Set<PointerDeviceKind>get dragDevices => {
    PointerDeviceKind.mouse,
    PointerDeviceKind.touch
  };
}