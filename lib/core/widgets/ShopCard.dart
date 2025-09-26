import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:testrunflutter/data/models/ShopModel.dart';
import 'package:testrunflutter/features/Pages/home/screens/detail_barber.dart';

class ShopCard extends StatelessWidget {
  final ShopModel shop;
  final double km;
  final String urlImage;
  final String name;
  final String address;
  final String rate;

  const ShopCard({
    super.key,
    required this.shop,
    required this.km,
    required this.urlImage,
    required this.name,
    required this.address,
    required this.rate,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                DetailBarber(shop: shop, km: km, rate: rate),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              const begin = Offset(1.0, 0.0);
              const end = Offset.zero;
              final tween = Tween(begin: begin, end: end);
              final curvedAnimation =
              CurvedAnimation(parent: animation, curve: Curves.ease);
              return SlideTransition(
                position: tween.animate(curvedAnimation),
                child: child,
              );
            },
            transitionDuration: const Duration(milliseconds: 600),
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 16.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Ảnh
            ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16.r),
                bottomLeft: Radius.circular(16.r),
              ),
              child: CachedNetworkImage(
                imageUrl: urlImage,
                width: 100.w,
                height: 100.h,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  width: 100.w,
                  height: 100.h,
                  color: Colors.grey[200],
                  child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                ),
                errorWidget: (context, url, error) => Container(
                  width: 100.w,
                  height: 100.h,
                  color: Colors.grey[300],
                  child: const Icon(Icons.broken_image, color: Colors.grey),
                ),
              ),
            ),
            SizedBox(width: 12.w),

            // Nội dung
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 4.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Tên shop
                    Text(
                      name,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF111827),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 6.h),

                    // Địa chỉ
                    Row(
                      children: [
                        const Icon(Icons.location_on_rounded,
                            size: 16, color: Color(0XFF8683A1)),
                        SizedBox(width: 4.w),
                        Expanded(
                          child: Text(
                            address,
                            style: TextStyle(fontSize: 13.sp, color: Colors.grey[600]),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 6.h),

                    // Rating + Km
                    Row(
                      children: [
                        const Icon(Icons.star,
                            size: 16, color: Colors.amber),
                        SizedBox(width: 4.w),
                        Text(
                          rate,
                          style: TextStyle(fontSize: 13.sp, color: Colors.grey[800]),
                        ),
                        SizedBox(width: 12.w),
                        const Icon(Icons.directions_walk,
                            size: 16, color: Colors.green),
                        SizedBox(width: 4.w),
                        Text(
                        double.parse(km.toStringAsFixed(1)) != 0.0 ?
                          "${km.toStringAsFixed(1)} km" : '0.1 km',
                          style: TextStyle(fontSize: 13.sp, color: Colors.grey[800]),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
