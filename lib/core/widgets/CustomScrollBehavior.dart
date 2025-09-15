import 'dart:ui';

import 'package:flutter/material.dart';

class MyCustomScrollBehavior extends MaterialScrollBehavior {
  Set<PointerDeviceKind> get dragDevices => {
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
    PointerDeviceKind.stylus,
    PointerDeviceKind.trackpad
  };
  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    switch(getPlatform(context)){
      case TargetPlatform.iOS:
      case TargetPlatform.android:
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
        return const BouncingScrollPhysics();
      default:
        return const ClampingScrollPhysics();
    }
  }
}
