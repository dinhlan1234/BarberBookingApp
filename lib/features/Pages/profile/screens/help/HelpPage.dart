import 'package:flutter/material.dart';
import 'package:testrunflutter/core/widgets/TextBasic.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class HelpPage extends StatefulWidget {
  const HelpPage({super.key});

  @override
  State<HelpPage> createState() => _HelpPageState();
}

class _HelpPageState extends State<HelpPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back),
          color: Color(0xFF111827),
        ),
        title: customText(
          text: 'Chăm sóc khách hàng',
          color: Color(0xFF111827),
          fonSize: 16.sp,
          fonWeight: FontWeight.bold,
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(top: 30.h),
              child: Align(
                alignment: Alignment.topCenter,
                child: Image.asset('assets/icons/questionDiscord.png',width: 100.w,height: 100.h,color: Color(0xFF363062),),
              ),
            ),
            Text(
              'Chúng tôi có thể giúp gì cho bạn?',
              style: TextStyle(
                color: Color(0xFF363062),
                fontSize: 22.sp,
                fontWeight: FontWeight.bold
              ),
              overflow: TextOverflow.visible,
              softWrap: true,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 10.h,),
            Text(
              'Vui lòng nhập dữ liệu cá nhân của bạn và mô tả nhu cầu chăm sóc của bạn hoặc điều gì đó chúng tôi có thể giúp bạn',
              style: TextStyle(
                color: Color(0xFF8683A1),
                fontSize: 14.sp
              ),
              overflow: TextOverflow.visible,
              softWrap: true,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 10.h,),
            Padding(
                padding: EdgeInsets.only(right: 10.w,left: 10.w,bottom: 15.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  customText(text: 'Tên của bạn', color: Color(0xFF111827), fonSize: 14.sp, fonWeight: FontWeight.bold),
                  SizedBox(height: 5.h,),
                  TextField(
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.person,color: Color(0XFF363062)),
                      hintText: 'Nguyen Van A',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r)
                      )
                    ),
                  ),
                  SizedBox(height: 10.h,),
                  customText(text: 'Email', color: Color(0xFF111827), fonSize: 14.sp, fonWeight: FontWeight.bold),
                  SizedBox(height: 5.h,),
                  TextField(
                    decoration: InputDecoration(
                        prefixIcon: Icon(Icons.email,color: Color(0XFF363062)),
                        hintText: 'abcz@gmail.com',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.r)
                        )
                    ),
                  ),
                  SizedBox(height: 10.h,),
                  customText(text: 'Mô tả', color: Color(0xFF111827), fonSize: 14.sp, fonWeight: FontWeight.bold),
                  TextField(
                    maxLines: 6, // Cho phép nhập nhiều dòng
                    decoration: InputDecoration(
                      hintText: 'Nhập mô tả', // Placeholder
                      alignLabelWithHint: true, 
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12), // Bo tròn viền
                      ),
                      contentPadding: EdgeInsets.all(16), // Padding bên trong
                    ),
                  ),
                  SizedBox(height: 10.h,),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                        onPressed: (){},
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 10.h),
                          backgroundColor: Color(0xFF363062),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.r)
                          )
                        ),
                        child: customText(text: 'Gửi', color: Colors.white, fonSize: 16.sp, fonWeight: FontWeight.bold)),
                  )
                ],
              ),
            )

          ],
        ),
      ),
    );
  }
}
