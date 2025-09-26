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
  const ShopCard({super.key, required this.shop,required this.km, required this.urlImage, required this.name, required this.address, required this.rate});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (){
        Navigator.push(context, PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => DetailBarber(shop: shop,km: km,rate: rate,),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(1.0, 0.0);
            const end = Offset.zero;
            final tween = Tween(begin: begin, end: end);
            final curvedAnimation = CurvedAnimation(parent: animation, curve: Curves.ease);
            return SlideTransition(
              position: tween.animate(curvedAnimation),
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 1000),
        ));
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 16.h),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12.r),
              child: Image(
                image: CachedNetworkImageProvider(urlImage),
                width: 90.w,
                height: 90.h,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(width: 10.w,),
            Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name,style: TextStyle(fontSize: 16.sp,color: const Color(0XFF111827),fontWeight: FontWeight.bold),),
                    SizedBox(height: 6.h,),
                    Row(
                      children: [
                        Icon(Icons.location_on_rounded,color: Color(0XFF8683A1),),
                        Text(address,style: TextStyle(fontSize: 14.sp),)
                      ],
                    ),
                    SizedBox(height: 6.h,),
                    Row(
                      children: [
                        Icon(Icons.star,color: Color(0XFF8683A1),),
                        SizedBox(width: 4.w),
                        Text(rate,style: TextStyle(fontSize: 14.sp),)
                      ],
                    ),
                  ],
                )
            )
          ],
        ),
      ),
    );
  }
}
