import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:testrunflutter/core/widgets/TextBasic.dart';
import 'package:testrunflutter/data/firebase/FireStore.dart';
import 'package:testrunflutter/data/models/ServiceModel.dart';
import 'package:testrunflutter/data/models/ShopModel.dart';
import 'package:testrunflutter/data/models/UserModel.dart';
import 'package:testrunflutter/features/Pages/home/screens/Book_Appointmnet.dart';

Widget buildAboutTab(ShopModel shop, List<ServiceModel> listServices) {
  FireStoreDatabase dtb = FireStoreDatabase();
  List<String> openDays = shop.openDays;
  bool isExpanded = false;
  String text = shop.introduction != '0'
      ? '${shop.introduction}'
      : "${shop.shopName} tự hào là địa điểm yêu thích của các quý ông yêu thích phong cách hiện đại & chuyên nghiệp. "
      "Với đội ngũ thợ lành nghề, không gian chuyên nghiệp và các dịch vụ cao cấp, chúng tôi luôn nỗ lực để mang đến "
      "trải nghiệm tốt nhất cho khách hàng. Từ cắt tóc, cạo râu đến các liệu trình chăm sóc da mặt, tất cả đều được "
      "thực hiện bởi những người thợ đầy tâm huyết và chuyên nghiệp.";

  return StatefulBuilder(
    builder: (context, setState) {
      return SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Giới thiệu section
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(8.w),
                        decoration: BoxDecoration(
                          color: const Color(0XFF363062).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        child: Icon(
                          Icons.info_outline_rounded,
                          color: const Color(0XFF363062),
                          size: 18.sp,
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Text(
                        "Giới thiệu",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 17.sp,
                          color: const Color(0xFF111827),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final span = TextSpan(
                        text: text,
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: const Color(0xFF374151),
                          height: 1.5,
                        ),
                      );
                      final tp = TextPainter(
                        text: span,
                        maxLines: isExpanded ? null : 3,
                        textDirection: TextDirection.ltr,
                      );
                      tp.layout(maxWidth: constraints.maxWidth);
                      final isOverflow = tp.didExceedMaxLines;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            text,
                            maxLines: isExpanded ? null : 3,
                            overflow: TextOverflow.fade,
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: const Color(0xFF374151),
                              height: 1.5,
                            ),
                          ),
                          if (isOverflow) ...[
                            SizedBox(height: 8.h),
                            GestureDetector(
                              onTap: () => setState(() => isExpanded = !isExpanded),
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 12.w,
                                  vertical: 6.h,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0XFF363062).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20.r),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      isExpanded ? 'Thu gọn' : 'Đọc thêm',
                                      style: TextStyle(
                                        color: const Color(0XFF363062),
                                        fontSize: 13.sp,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    SizedBox(width: 4.w),
                                    Icon(
                                      isExpanded
                                          ? Icons.keyboard_arrow_up_rounded
                                          : Icons.keyboard_arrow_down_rounded,
                                      color: const Color(0XFF363062),
                                      size: 16.sp,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),

            SizedBox(height: 20.h),

            // Giờ mở cửa section
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(8.w),
                        decoration: BoxDecoration(
                          color: Colors.amber.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        child: Icon(
                          Icons.access_time_rounded,
                          color: Colors.amber.shade700,
                          size: 18.sp,
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Text(
                        "Giờ mở cửa",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 17.sp,
                          color: const Color(0xFF111827),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  Container(
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color: Colors.amber.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: _buildHoursRow(
                      "${openDays[0]} - ${openDays.last}",
                      "${shop.openHour} - ${shop.closeHour}",
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 20.h),

            // Lượt thích section
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(8.w),
                        decoration: BoxDecoration(
                          color: Colors.pink.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        child: Icon(
                          Icons.favorite_outline_rounded,
                          color: Colors.pink.shade400,
                          size: 18.sp,
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Text(
                        'Lượt thích của chúng tôi',
                        style: TextStyle(
                          color: const Color(0xFF111827),
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),
                  FutureBuilder<List<UserModel>>(
                    future: dtb.getUserLiked(shop.id),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Container(
                          height: 80.h,
                          child: Center(
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  const Color(0XFF363062)),
                            ),
                          ),
                        );
                      }
                      if (snapshot.hasError) {
                        return Container(
                          padding: EdgeInsets.all(12.w),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.error_outline_rounded,
                                color: Colors.red,
                                size: 20.sp,
                              ),
                              SizedBox(width: 8.w),
                              Text(
                                "Lỗi: ${snapshot.error}",
                                style: TextStyle(
                                  color: Colors.red.shade700,
                                  fontSize: 14.sp,
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return Container(
                          padding: EdgeInsets.all(16.w),
                          decoration: BoxDecoration(
                            color: Colors.grey.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.sentiment_neutral_rounded,
                                color: Colors.grey.shade500,
                                size: 24.sp,
                              ),
                              SizedBox(width: 8.w),
                              Text(
                                "Chưa có ai thích cửa hàng này",
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 12.sp,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                      final users = snapshot.data!;
                      return Column(
                        children: users.map((user) {
                          return _buildOurTim(
                            user.avatarUrl,
                            user.name,
                            "Đã like shop",
                          );
                        }).toList(),
                      );
                    },
                  ),
                ],
              ),
            ),

            SizedBox(height: 24.h),

            // Nút đặt lịch
            Container(
              width: double.infinity,
              height: 50.h,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12.r),
                gradient: const LinearGradient(
                  colors: [Color(0xFF363062), Color(0xFF4A4A7A)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF363062).withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) =>
                          BookAppointment(
                            shop: shop,
                            listServices: listServices,
                          ),
                      transitionsBuilder:
                          (context, animation, secondaryAnimation, child) {
                        const begin = Offset(1.0, 0.0);
                        const end = Offset.zero;
                        final tween = Tween(begin: begin, end: end);
                        final curvedAnimation = CurvedAnimation(
                          parent: animation,
                          curve: Curves.easeOutCubic,
                        );

                        return SlideTransition(
                          position: tween.animate(curvedAnimation),
                          child: child,
                        );
                      },
                      transitionDuration: const Duration(milliseconds: 400),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.event_available_rounded,
                      color: Colors.white,
                      size: 20.sp,
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      'Đặt lịch ngay',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}

Widget _buildHoursRow(String day, String time) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Row(
        children: [
          Icon(
            Icons.calendar_today_outlined,
            size: 18.sp,
            color: Colors.amber.shade700,
          ),
          SizedBox(width: 4.w),
          Text(
            day,
            style: TextStyle(
              fontSize: 12.sp,
              color: const Color(0xFF6B7280),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
      Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: Colors.amber.withOpacity(0.2),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Text(
          time,
          style: TextStyle(
            fontSize: 10.sp,
            fontWeight: FontWeight.bold,
            color: Colors.amber.shade800,
          ),
        ),
      ),
    ],
  );
}

Widget _buildOurTim(String url, String name, String service) {
  return Container(
    margin: EdgeInsets.only(bottom: 12.h),
    padding: EdgeInsets.all(12.w),
    decoration: BoxDecoration(
      color: Colors.pink.withOpacity(0.03),
      borderRadius: BorderRadius.circular(12.r),
      border: Border.all(color: Colors.pink.withOpacity(0.1)),
    ),
    child: Row(
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25.r),
            border: Border.all(
              color: Colors.pink.withOpacity(0.3),
              width: 2,
            ),
          ),
          child: CircleAvatar(
            radius: 22.r,
            backgroundImage: url != '0'
                ? CachedNetworkImageProvider(url)
                : AssetImage('assets/images/avtMacDinh.jpg'),
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: TextStyle(
                  color: const Color(0xFF111827),
                  fontSize: 15.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                service,
                style: TextStyle(
                  color: const Color(0xFF6B7280),
                  fontSize: 13.sp,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color: Colors.pink.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Icon(
            Icons.favorite_rounded,
            color: Colors.pink.shade400,
            size: 18.sp,
          ),
        ),
      ],
    ),
  );
}