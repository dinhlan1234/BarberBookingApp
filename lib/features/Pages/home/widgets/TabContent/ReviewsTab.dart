import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:testrunflutter/core/widgets/TextBasic.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

Widget Reviewstab(){
  return Column(
    children: [
      _buildOurReviews('assets/images/bom.jpg', 'Nguyen Dinh Lan', 5.0,'Good service, recommendation for barber shop seekers' ),
      _buildOurReviews('assets/images/bom.jpg', 'Bom Nguyen', 4.0,'Good service, recommendation for barber shop seekers' ),
      _buildOurReviews('assets/images/bom.jpg', 'Nguyen Van Minh', 3.0,'Good service, recommendation for barber shop seekers' ),
      _buildOurReviews('assets/images/bom.jpg', 'Nguyen Vu Quang', 2.0,'Good service, recommendation for barber shop seekers' ),

    ],
  );
}
Widget _buildOurReviews(String url, String name, double rate, String cmt){
  return Row(
    children: [
      CircleAvatar(backgroundImage: AssetImage(url),),
      SizedBox(width: 7.w,),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                SizedBox(width: 5.w,),
                customText(text: name, color: Color(0xFF111827), fonSize: 16.sp, fonWeight: FontWeight.bold),
              ],
            ),
            Row(
              children: [
                Image.asset('assets/icons/star.png',color: rate >=1 ? Colors.yellow : Color(0xFF8683A1),width: 25.w,height: 25.h,),
                Image.asset('assets/icons/star.png',color: rate >=2 ? Colors.yellow : Color(0xFF8683A1),width: 25.w,height: 25.h,),
                Image.asset('assets/icons/star.png',color: rate >=3 ? Colors.yellow : Color(0xFF8683A1),width: 25.w,height: 25.h,),
                Image.asset('assets/icons/star.png',color: rate >=4 ? Colors.yellow : Color(0xFF8683A1),width: 25.w,height: 25.h,),
                Image.asset('assets/icons/star.png',color: rate >=5 ? Colors.yellow : Color(0xFF8683A1),width: 25.w,height: 25.h,),
                customText(text: '(${rate.toString()})', color: Color(0xFF363062), fonSize: 10.sp, fonWeight: FontWeight.normal)
              ],
            ),
            Text(cmt,style: TextStyle(fontSize: 12.sp,color: Color(0xFf6B7280),),maxLines: 2,)
          ],
        ),
      )
    ],
  );
}