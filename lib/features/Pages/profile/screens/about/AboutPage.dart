import 'package:flutter/material.dart';
import 'package:testrunflutter/core/widgets/TextBasic.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF363062),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back),
          color: Colors.white,
        ),
        title: customText(
          text: 'Về chúng tôi',
          color: Colors.white,
          fonSize: 16.sp,
          fonWeight: FontWeight.bold,
        ),
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset('assets/icons/setIcon.png', fit: BoxFit.cover),
          ),
          SafeArea(
            child: Padding(
              padding: EdgeInsets.only(top: 60.h),
              child: Align(
                alignment: Alignment.topCenter,
                child: Image.asset('assets/images/LOGO GOBAR VERTICAL 1.png'),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: MediaQuery.of(context).size.height * 0.55,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
                ),
                child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 20.h,horizontal: 20.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      customText(text: 'Ứng dụng Gobar', color: Color(0xFF111827), fonSize: 16.sp, fonWeight: FontWeight.bold),
                      Text(
                        '"Gobar: The Best Solution for Online Barber Bookings"Want a more practical and efficient hair shaving experience? Gobar is the best solution for you! Gobar is an online barber booking application that makes it easy for you to search, select and order haircut services easily and quickly.',
                        style: TextStyle(
                          color: Color(0xFF6B7280),
                          fontSize: 16.sp,
                        ),
                        textAlign: TextAlign.start,
                        softWrap: true,
                        overflow: TextOverflow.visible,
                      ),
                      SizedBox(height: 10.h,),
                      Container(
                        height: 1.h,
                        width: double.infinity,
                        color: Color(0xFFF4F4F5),
                      ),
                      SizedBox(height: 10.h,),
                      customText(text: 'Đánh giá app', color: Color(0xFF8683A1), fonSize: 14.sp, fonWeight: FontWeight.normal),
                      SizedBox(height: 20.h,),
                      GestureDetector(
                        onTap: (){},
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            customText(text: 'Hãy đánh giá ứng dụng này', color: Color(0xFF363062), fonSize: 16.sp, fonWeight: FontWeight.bold),
                            Icon(Icons.navigate_next,color: Color(0xFF8683A1),)
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              )
          )
        ],
      ),
    );
  }
}
