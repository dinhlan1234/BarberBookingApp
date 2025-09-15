import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:testrunflutter/core/widgets/TextBasic.dart';
Widget buildActionButton({
  required bool checkColor,
  required Color color,
  required bool check,
  required String imagePath,
  required String label,
  required VoidCallback onTab
}) {
  return GestureDetector(
    onTap: onTab,
    child: Column(
      children: [
        check ? Icon(CupertinoIcons.heart_fill,color: color,) : Image.asset(imagePath,fit: BoxFit.cover,color: checkColor ? color : null,width: 20.w,height: 20.h,),
        SizedBox(height: 6.h,),
        customText(text: label, color: Color(0xFF363062), fonSize: 14.sp, fonWeight: FontWeight.normal)
      ],
    ),
  );
}