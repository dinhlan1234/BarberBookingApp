import 'dart:ffi';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dash/flutter_dash.dart';
import 'package:testrunflutter/core/format/FormatPrice.dart';
import 'package:testrunflutter/core/widgets/TextBasic.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:testrunflutter/data/models/BookingModel/BookingDateModel.dart';
import 'package:testrunflutter/data/models/BookingModel/ServicesSelected.dart';
import 'package:testrunflutter/data/models/ShopModel.dart';
import 'package:testrunflutter/features/Auth/authPage.dart';

class Invoice extends StatefulWidget {
  final Map<String,dynamic> tempData;
  const Invoice({super.key, required this.tempData});

  @override
  State<Invoice> createState() => _InvoiceState();
}

class _InvoiceState extends State<Invoice> {
  late ShopModel shopModel;
  late ServicesSelected servicesSelected;
  late BookingDateModel bookingDateModel;
  @override
  void initState() {
    super.initState();
    _loadData();
  }
  void _loadData(){
    shopModel = widget.tempData['shop'] as ShopModel;
    servicesSelected = widget.tempData['servicesSelected'] as ServicesSelected;
    bookingDateModel = widget.tempData['bookingDateModel'] as BookingDateModel;
  }
  List<Map<String, dynamic>> listServices = [
  {
  'image': 'assets/images/barber4.png',
  'name': 'Cắt tóc nam',
  'note': 'Phong cách hiện đại, cá tính',
  'price': 80000,
},
{
'image': 'assets/images/barber5.png',
'name': 'Cạo râu',
'note': 'Sạch sẽ, gọn gàng',
'price': 50000,
},
{
'image': 'assets/images/barber6.png',
'name': 'Chăm sóc da',
'note': 'Thư giãn và dưỡng da',
'price': 120000,
}];

@override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: const Color(0xFF363062),
    extendBodyBehindAppBar: true,
    body: Stack(
      children: [
        // Background
        SizedBox(
          width: double.infinity,
          child: Image.asset(
            'assets/icons/setIcon.png',
            fit: BoxFit.cover,
          ),
        ),

        SafeArea(
          child: Align(
            alignment: Alignment.topCenter,
            child: Padding(
                padding: EdgeInsets.only(top: 30.h),
                child: Column(
                  children: [
                    Image.asset(
                      'assets/images/success3.png',
                      width: 100.w, // tuỳ chỉnh
                      height: 100.w,
                      fit: BoxFit.contain,
                    ),
                    SizedBox(height: 15.h,),
                    customText(text: 'Đặt chỗ thành công',
                        color: Colors.white,
                        fonSize: 18.sp,
                        fonWeight: FontWeight.bold),
                    SizedBox(height: 5.h,),
                    Text(
                      'Kiểm tra ngay menu đặt chỗ để biết thông tin chi tiết',
                      style: TextStyle(color: Colors.white, fontSize: 14.sp,),
                      textAlign: TextAlign.center,)
                  ],
                )
            ),
          ),
        ),

        // Bottom trắng
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            height: MediaQuery
                .of(context)
                .size
                .height * 0.50,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 15.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      customText(text: shopModel.shopName,
                          color: Color(0xFF111827),
                          fonSize: 16.sp,
                          fonWeight: FontWeight.bold),
                      customText(text: '${bookingDateModel.time} - ${bookingDateModel.weekdayName}, ${bookingDateModel.date}',
                          color: Color(0xFF6B7280),
                          fonSize: 14.sp,
                          fonWeight: FontWeight.normal)
                    ],
                  ),
                  SizedBox(height: 2.h,),
                  customText(text: servicesSelected.services.map((e) => e.name).join(', '),
                      color: Color(0xFF6B7280),
                      fonSize: 14.sp,
                      fonWeight: FontWeight.normal),
                  SizedBox(height: 15.h,),
                  customText(text: 'Tóm tắt thanh toán',
                      color: Color(0xFF111827),
                      fonSize: 16.sp,
                      fonWeight: FontWeight.bold),
                  Column(
                    children: List.generate(servicesSelected.services.length, (index){
                      final service = servicesSelected.services[index];
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          customText(text: service.name, color: Color(0xFF111827), fonSize: 14.sp, fonWeight: FontWeight.normal),
                          Row(
                            children: [
                              Icon(CupertinoIcons.money_dollar),
                              customText(text: FormatPrice.formatPrice(service.price), color: Color(0xFF111827), fonSize: 16.sp, fonWeight: FontWeight.normal)
                            ],
                          )
                        ],
                      );
                    })
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      customText(text: 'Mã giảm giá', color: Color(0xFF111827), fonSize: 14.sp, fonWeight: FontWeight.normal),
                      Row(
                        children: [

                          Icon(CupertinoIcons.money_dollar),

                          customText(text: FormatPrice.formatPrice(servicesSelected.discount), color: Color(0xFF111827), fonSize: 16.sp, fonWeight: FontWeight.normal)
                        ],
                      )
                    ],
                  ),
                  SizedBox(height: 10.h,),
                  LayoutBuilder(builder: (context,constraints){
                    return Dash(
                      direction: Axis.horizontal,
                      length: constraints.maxWidth,
                      dashLength: 8,
                      dashColor: Color(0xFFC3C1D0),
                    );
                  }),
                  SizedBox(height: 10.h,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      customText(text: 'Tổng tiền', color: Color(0xFF111827), fonSize: 14.sp, fonWeight: FontWeight.normal),
                      Row(
                        children: [

                          Icon(CupertinoIcons.money_dollar),

                          customText(text: FormatPrice.formatPrice(servicesSelected.total), color: Color(0xFF111827), fonSize: 16.sp, fonWeight: FontWeight.normal)
                        ],
                      )
                    ],
                  ),
                  SizedBox(height: 20.h,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton(
                          onPressed: (){
                            Navigator.pushAndRemoveUntil(
                              context,
                              PageRouteBuilder(
                                pageBuilder: (context, animation, secondaryAnimation) => const Authpage(),
                                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                  return SlideTransition(
                                    position: animation.drive(
                                      Tween(begin: const Offset(1.0, 0.0), end: Offset.zero),
                                    ),
                                    child: child,
                                  );
                                },
                                transitionDuration: const Duration(milliseconds: 1000),
                              ),
                                  (Route<dynamic> route) => false, // Xóa toàn bộ stack
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 10.h,horizontal: 20.w),
                            backgroundColor: Color(0xFF363062),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadiusGeometry.circular(12.r)
                            )
                          ),
                          child: customText(text: 'Trở về', color: Colors.white, fonSize: 16.sp, fonWeight: FontWeight.bold)
                      ),
                      ElevatedButton(
                          onPressed: (){
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(vertical: 10.h,horizontal: 50.w),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadiusGeometry.circular(12.r),
                                side: BorderSide(
                                  color: Color(0xFF363062)
                                )
                              )
                          ),
                          child: Row(
                            children: [
                              customText(text: 'Tải xuống', color: Color(0xFF363062), fonSize: 16.sp, fonWeight: FontWeight.bold),
                              SizedBox(width: 5.w,),
                              Icon(Icons.cloud_download,color: Color(0xFF363062),)
                            ],
                          )
                      )
                    ],
                  )
                ],
              ),
            ),

          ),
        )
      ],
    ),
  );
}}
