import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:testrunflutter/core/widgets/TextBasic.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:testrunflutter/data/firebase/FireStore.dart';
import 'package:testrunflutter/data/models/BookingModel/BookingSchedules.dart';
import 'package:testrunflutter/data/models/BookingWithUser.dart';
import 'package:testrunflutter/data/models/ShopModel.dart';

Widget ReviewsTab(ShopModel shop) {
  FireStoreDatabase dtb = FireStoreDatabase();
  return FutureBuilder<List<BookingWithUser>>(
    future: dtb.getListBookingRate(shop.id),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return Container(
          height: 300.h,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(const Color(0XFF363062)),
                ),
                SizedBox(height: 16.h),
                Text(
                  'Đang tải đánh giá...',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: const Color(0xFF6B7280),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        );
      } else if (snapshot.hasError) {
        return Container(
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Icon(
                  Icons.error_outline_rounded,
                  size: 48.sp,
                  color: Colors.red.shade400,
                ),
              ),
              SizedBox(height: 16.h),
              Text(
                'Có lỗi xảy ra',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.red.shade700,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                '${snapshot.error}',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: const Color(0xFF6B7280),
                ),
              ),
            ],
          ),
        );
      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
        return Container(
          padding: EdgeInsets.all(32.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(24.w),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(50.r),
                  border: Border.all(color: Colors.grey.shade300, width: 2),
                ),
                child: Icon(
                  Icons.rate_review_outlined,
                  size: 48.sp,
                  color: Colors.grey.shade400,
                ),
              ),
              SizedBox(height: 20.h),
              Text(
                'Chưa có đánh giá nào',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF374151),
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                'Hãy là người đầu tiên đánh giá cửa hàng này',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: const Color(0xFF6B7280),
                ),
              ),
            ],
          ),
        );
      }

      final List<BookingWithUser> listBookingWithUser = snapshot.data!;

      // Calculate average rating
      double averageRating = 0;
      int totalRatings = 0;

      for (var booking in listBookingWithUser) {
        if (booking.booking.reviewModel?.rating != null) {
          averageRating += booking.booking.reviewModel!.rating.toDouble();
          totalRatings++;
        }
      }
      if (totalRatings > 0) {
        averageRating = averageRating / totalRatings;
      }

      return SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with statistics
            Container(
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0XFF363062).withOpacity(0.1),
                    const Color(0XFF363062).withOpacity(0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(color: const Color(0XFF363062).withOpacity(0.2)),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(12.w),
                        decoration: BoxDecoration(
                          color: const Color(0XFF363062).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                        child: Icon(
                          Icons.star_rate_rounded,
                          color: const Color(0XFF363062),
                          size: 24.sp,
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Đánh giá khách hàng',
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF111827),
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Row(
                              children: [
                                Text(
                                  '${averageRating.toStringAsFixed(1)}',
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0XFF363062),
                                  ),
                                ),
                                SizedBox(width: 6.w),
                                Row(
                                  children: List.generate(5, (index) {
                                    return Icon(
                                      Icons.star_rounded,
                                      size: 15.sp,
                                      color: averageRating > index
                                          ? Colors.amber.shade400
                                          : Colors.grey.shade300,
                                    );
                                  }),
                                ),
                                SizedBox(width: 6.w),
                                Text(
                                  '($totalRatings đánh giá)',
                                  style: TextStyle(
                                    fontSize: 11.sp,
                                    color: const Color(0xFF6B7280),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(height: 20.h),

            // Reviews list
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: listBookingWithUser.length,
              separatorBuilder: (_, __) => SizedBox(height: 16.h),
              itemBuilder: (context, index) {
                final userModel = listBookingWithUser[index].userModel;
                final review = listBookingWithUser[index].booking.reviewModel;
                return _buildOurReviews(
                  userModel.avatarUrl,
                  userModel.name,
                  review?.rating.toDouble() ?? 0,
                  review?.comment ?? "",
                  index,
                );
              },
            ),
          ],
        ),
      );
    },
  );
}

Widget _buildOurReviews(String url, String name, double rate, String cmt, int index) {
  return Container(
    padding: EdgeInsets.all(20.w),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20.r),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.06),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ],
      border: Border.all(
        color: Colors.grey.shade200,
        width: 1,
      ),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            // Avatar with enhanced design
            Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30.r),
                    border: Border.all(
                      color: const Color(0XFF363062).withOpacity(0.2),
                      width: 3,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: CircleAvatar(
                    backgroundImage: url != '0'
                        ? CachedNetworkImageProvider(url)
                        : const AssetImage('assets/images/avtMacDinh.jpg') as ImageProvider,
                    radius: 26.r,
                    backgroundColor: Colors.grey.shade200,
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: EdgeInsets.all(4.w),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(10.r),
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: Icon(
                      Icons.verified_rounded,
                      color: Colors.white,
                      size: 12.sp,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          name,
                          style: TextStyle(
                            color: const Color(0xFF1F2937),
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                        decoration: BoxDecoration(
                          color: const Color(0XFF363062).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Text(
                          'Khách hàng #${index + 1}',
                          style: TextStyle(
                            color: const Color(0XFF363062),
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  // Enhanced rating display
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.amber.shade50,
                          Colors.amber.shade100,
                        ],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: Colors.amber.shade300, width: 1.5),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Stars with animation-like gradient
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: List.generate(5, (starIndex) {
                            return Padding(
                              padding: EdgeInsets.only(right: 2.w),
                              child: Icon(
                                Icons.star_rounded,
                                size: 18.sp,
                                color: rate > starIndex
                                    ? Colors.amber.shade500
                                    : Colors.grey.shade300,
                              ),
                            );
                          }),
                        ),
                        SizedBox(width: 8.w),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                          decoration: BoxDecoration(
                            color: Colors.amber.shade600,
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Text(
                            '${rate.toStringAsFixed(1)}',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),

        // Comment section
        if (cmt.isNotEmpty) ...[
          SizedBox(height: 16.h),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(color: Colors.grey.shade200, width: 1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.format_quote_rounded,
                      color: const Color(0XFF363062),
                      size: 18.sp,
                    ),
                    SizedBox(width: 6.w),
                    Text(
                      'Nhận xét',
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: const Color(0XFF363062),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8.h),
                Text(
                  cmt,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: const Color(0xFF4B5563),
                    height: 1.5,
                    letterSpacing: 0.3,
                  ),
                  maxLines: 5,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ],
    ),
  );
}