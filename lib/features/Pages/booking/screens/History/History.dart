import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:testrunflutter/core/widgets/TextBasic.dart';
import 'package:testrunflutter/data/models/BookingModel/BookingSchedules.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:testrunflutter/data/models/BookingModel/BookingWithShop.dart';
import 'package:testrunflutter/features/Pages/booking/screens/History/historicalDetails.dart';
Widget HistoryBooking(List<BookingWithShop> list){
  if(list.isEmpty){
    return Center(
      child: Text(
        'Bạn chưa có lịch sử lịch trình nào...',
        style: TextStyle(fontSize: 18),
      ),
    );
  }
  return ListView.builder(
      itemCount: list.length,
      itemBuilder: (context,index){
        return history(context, list[index]);
      }
  );
}
Widget history(BuildContext context,BookingWithShop b) {
  return Container(
    padding: EdgeInsets.all(10.r),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16.r),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.1),
          blurRadius: 10,
          offset: const Offset(0, 3),
        ),
      ],
    ),
    child: GestureDetector(
      onTap: () {
        Navigator.push(context, PageRouteBuilder(pageBuilder: (context, animation, secondaryAnimation)
        => HistoryDetail(booking: b),
          transitionsBuilder: (context, animation, secondaryAnimation, child,) {
            const begin = Offset(1.0, 0.0,); // Bắt đầu bên phải màn hình
            const end = Offset.zero; // Kết thúc ở vị trí hiện tại
            final tween = Tween(begin: begin, end: end);
            final curvedAnimation = CurvedAnimation(
              parent: animation,
              curve: Curves.ease,
            );
            return SlideTransition(position: tween.animate(curvedAnimation), child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 1000,), // thời gian chuyển cảnh
        ),
        );
      },
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12.r),
            child: Image(
              image: CachedNetworkImageProvider(
                b.shop.shopAvatarImageUrl,
              ),
              width: 80.w,
              height: 80.w,
              fit: BoxFit.cover,
            ),
          ),
          SizedBox(width: 10.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              customText(
                text: b.shop.shopName,
                color: Color(0xFF363062),
                fonSize: 16.sp,
                fonWeight: FontWeight.bold,
              ),
              Row(
                children: [
                  const Icon(
                    Icons.timer,
                    color: Color(0xFF363062),
                    size: 16,
                  ),
                  SizedBox(width: 3.w),
                  customText(
                    text: '${b.booking.bookingDateModel.time} - ${b.booking
                        .bookingDateModel.date}',
                    color: Color(0xFF363062),
                    fonSize: 14.sp,
                    fonWeight: FontWeight.normal,
                  ),
                ],
              ),
              Row(
                children: [
                  Icon(
                    Icons.notifications_active,
                    color: Color(0xFF363062),
                    size: 16,
                  ),
                  SizedBox(width: 3.w),
                  customText(
                    text: b.booking.status == 'Hoàn thành1'
                        ? 'Hoàn thành'
                        :  b.booking.status == 'Hoàn thành2'
                          ? 'Đã hoàn thành đơn rủi ro'
                          : 'Rủi ro',
                    color: Color(0xFF363062),
                    fonSize: 14.sp,
                    fonWeight: FontWeight.normal,
                  ),
                ],
              ),
            ],
          ),
          SizedBox(width: 70.w),
          Icon(Icons.chevron_right)
        ],
      ),
    ),
  );
}