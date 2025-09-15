import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:testrunflutter/core/widgets/TextBasic.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:testrunflutter/features/Pages/profile/screens/level/widget/levelIcon.dart';
import 'package:testrunflutter/features/Pages/profile/screens/level/widget/levelLabel.dart';
import 'package:testrunflutter/features/Pages/profile/screens/level/widget/listLevel.dart';

class LevelPage extends StatelessWidget {
  const LevelPage({super.key});

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
          text: 'Cấp độ',
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
              padding: EdgeInsets.symmetric(horizontal: 10.w),
              child: Column(
                children: [
                  Row(
                    children: [
                      customText(
                        text: 'Cấp độ hiện tại của bạn là ',
                        color: Colors.white,
                        fonSize: 18.sp,
                        fonWeight: FontWeight.bold,
                      ),
                      customText(
                        text: 'bạch kim',
                        color: Color(0xFFF99417),
                        fonSize: 18.sp,
                        fonWeight: FontWeight.bold,
                      ),
                    ],
                  ),
                  SizedBox(height: 20.h),
                  Container(
                    padding: EdgeInsets.symmetric(
                      vertical: 20.h,
                      horizontal: 10.w,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.09),
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Column(
                      children: [
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            // Thanh progress nền xám
                            Container(
                              height: 6.h,
                              margin: EdgeInsets.symmetric(horizontal: 20.w),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade300,
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            // Thanh progress màu cam đến cấp hiện tại
                            Positioned(
                              left: 20.w,
                              right:
                                  MediaQuery.of(context).size.width *
                                  0.35, // Đến Platinum
                              child: Container(
                                height: 6.h,
                                decoration: BoxDecoration(
                                  color: Color(0xFFF99417),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                            // Các icon cấp độ
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                levelIcon("assets/level/sliver.png", true),
                                levelIcon("assets/level/gold.png", true),
                                levelIcon("assets/level/medal.png", true),
                                levelIcon("assets/level/diamond.png", false),
                              ],
                            ),
                          ],
                        ),

                        SizedBox(height: 20.h),
                        // Label cấp độ
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Row(
                              children: [
                                SizedBox(width: 10.w),
                                LevelLabel("Silver"),
                              ],
                            ),
                            Row(
                              children: [
                                SizedBox(width: 10.w),
                                LevelLabel("Gold"),
                              ],
                            ),

                            LevelLabel("Platinum"),

                            LevelLabel("Diamond"),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.64,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 15.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    customText(
                      text: 'Danh sách cấp độ',
                      color: Color(0xFF8683A1),
                      fonSize: 14.sp,
                      fonWeight: FontWeight.normal,
                    ),
                   Expanded(
                     child: SingleChildScrollView(
                       child: Column(
                         children: [
                           listLevel('assets/level/sliver.png', 'Silver', 'Lorem Ipsum is simply dummy text of the printing and typesetting industry.'),
                           SizedBox(height: 15.h,),
                           listLevel('assets/level/gold.png', 'Gold', 'Lorem Ipsum is simply dummy text of the printing and typesetting industry.'),
                           SizedBox(height: 15.h,),
                           listLevel('assets/level/medal.png', 'Platinum', 'Lorem Ipsum is simply dummy text of the printing and typesetting industry.'),
                           SizedBox(height: 15.h,),
                           listLevel('assets/level/diamond.png', 'Diamond', 'Lorem Ipsum is simply dummy text of the printing and typesetting industry.'),
                           SizedBox(height: 15.h,),
                           ElevatedButton(
                               onPressed: (){},
                               style: ElevatedButton.styleFrom(
                                   padding: EdgeInsets.symmetric(vertical: 10.h,horizontal: 10.h),
                                   backgroundColor: Color(0xFF363062),
                                   shape: RoundedRectangleBorder(
                                       borderRadius: BorderRadius.circular(8.r)
                                   )
                               ),
                               child: Row(
                                 mainAxisAlignment: MainAxisAlignment.center,
                                 children: [
                                   customText(text: 'Kỷ niệm điều này', color: Colors.white, fonSize: 16.sp, fonWeight: FontWeight.bold),
                                   SizedBox(width: 10.w,),
                                   Icon(Icons.celebration,color: Colors.white,)
                                 ],
                               )
                           ),

                         ],
                       ),
                     ),
                   )
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
