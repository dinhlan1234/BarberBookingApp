import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

Widget levelIcon(String iconPath, bool isActive) {
  return CircleAvatar(
    radius: 22.r,
    backgroundColor: Colors.white,
    child: Image.asset(
      iconPath,
      width: 24.w,
      height: 24.h,
      color: isActive ? Color(0xFFF99417) : Colors.grey,
    ),
  );
}