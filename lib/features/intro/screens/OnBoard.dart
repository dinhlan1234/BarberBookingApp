import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:testrunflutter/features/Auth/screens/LoginScreen.dart';

class OnBoard extends StatefulWidget {
  const OnBoard({super.key});

  @override
  State<OnBoard> createState() => _OnBoardState();
}

class _OnBoardState extends State<OnBoard> {
  int currentPage = 0;
  final List<Map<String, String>> pages = [
    {
      "image": "assets/images/welcome1.png",
      "title": "Welcome Gobars",
      "desc":
      "Find the best grooming experience in your city with just one tap! Don't miss out on the haircut or treatment of your dreams. Let's start now!"
    },
    {
      "image": "assets/images/welcome2.png",
      "title": "Loooking for barber?",
      "desc":
      "Find the best barbershop around you in seconds, make an appointment, and enjoy the best grooming experience."
    },
    {
      "image": "assets/images/welcome3.png",
      "title": "Everything in your hands",
      "desc":
      "With Gobar, find high-quality barbershops, see reviews, and make appointments easily. Achieve your confident appearance!"
    }
  ];

  void nextPage() {
    if (currentPage < pages.length - 1) {
      setState(() {
        currentPage++;
      });
    } else {
      Navigator.push(context, PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const LoginScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);  // Bắt đầu bên phải màn hình
          const end = Offset.zero;          // Kết thúc ở vị trí hiện tại
          final tween = Tween(begin: begin, end: end);
          final curvedAnimation = CurvedAnimation(parent: animation, curve: Curves.ease);

          return SlideTransition(
            position: tween.animate(curvedAnimation),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 2000),  // thời gian chuyển cảnh
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Stack(
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: EdgeInsets.only(top: 60.h),
              child: Image.asset(
                pages[currentPage]["image"]!,
                height: 600.h,
                fit: BoxFit.cover,
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: 280.h,
              padding: EdgeInsets.all(24.w),
              decoration: BoxDecoration(
                  color: const Color(0xFFFFA726),
                  borderRadius:
                  BorderRadius.vertical(top: Radius.circular(32.r))),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        pages[currentPage]["title"]!,
                        style: TextStyle(
                            fontSize: 25.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                      SizedBox(
                        height: 8.h,
                      ),
                      Text(
                        pages[currentPage]["desc"]!,
                        style:
                        TextStyle(fontSize: 15.sp, color: Colors.white),
                      )
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(pages.length, (index) => buildDot(index == currentPage),
                    ),
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: nextPage,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF363062),
                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r)),
                      ),
                      child: Text(
                        "Get Started",
                        style: TextStyle(fontSize: 16.sp, color: Colors.white),
                      ),
                    ),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}

Widget buildDot(bool isActive) {
  return Container(
    margin: EdgeInsets.symmetric(horizontal: 4.w),
    width: isActive ? 12.w : 8.w,
    height: isActive ? 12.h : 8.h,
    decoration: BoxDecoration(
      color: isActive ? Colors.white : Colors.white54,
      shape: BoxShape.circle,
    ),
  );
}
