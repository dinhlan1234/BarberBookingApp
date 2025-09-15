import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:testrunflutter/core/widgets/TextBasic.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

Widget listLevel(String iconPath, String label, String note) {
  return Row(
    children: [
      Image.asset(iconPath,color: Color(0xFFF99417),width: 40.w,height: 40.h,),
      SizedBox(width: 5.w),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            customText(
              text: label,
              color: Color(0xFF363062),
              fonSize: 16.sp,
              fonWeight: FontWeight.bold,
            ),
            Text(
              note,
              style: TextStyle(color: Color(0xFF6B7280), fontSize: 14.sp),
              textAlign: TextAlign.start,
              softWrap: true,
              overflow: TextOverflow.visible,
            ),
          ],
        ),
      ),
    ],
  );
}
