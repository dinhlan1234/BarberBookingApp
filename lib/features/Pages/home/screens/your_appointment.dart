import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dash/flutter_dash.dart';
import 'package:testrunflutter/core/format/FormatPrice.dart';
import 'package:testrunflutter/core/helper/aleart.dart';
import 'package:testrunflutter/core/widgets/TextBasic.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:testrunflutter/data/firebase/FireStore.dart';
import 'package:testrunflutter/data/models/BookingModel/BookingDateModel.dart';
import 'package:testrunflutter/data/models/BookingModel/ServicesSelected.dart';
import 'package:testrunflutter/data/models/ShopModel.dart';
import 'package:testrunflutter/data/repositories/services/FCMService.dart';
import 'package:testrunflutter/features/Pages/home/screens/invoice.dart';

// trang 4
class YourAppointment extends StatefulWidget {
  final ShopModel shop;
  final Map<String, dynamic> tempData;

  const YourAppointment({
    super.key,
    required this.shop,
    required this.tempData,
  });

  @override
  State<YourAppointment> createState() => _YourAppointmentState();
}

class _YourAppointmentState extends State<YourAppointment> {
  FireStoreDatabase dtb = FireStoreDatabase();
  TextEditingController couponController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool isDisplay = false;
  late bool checkCoupon;
  double total = 0;
  List<String> coupon = ['abcz', 'bomnguyen1234', 'dinhlan12345'];
  late BookingDateModel bookingDateModel;
  late ServicesSelected servicesSelected;

  @override
  void initState() {
    super.initState();
    _loadData();
    _focusNode.addListener(() {
      setState(() {});
    });
  }

  void _loadData() {
    bookingDateModel = widget.tempData['bookingDateModel'] as BookingDateModel;
    servicesSelected = widget.tempData['servicesSelected'] as ServicesSelected;
  }

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
          text: 'Thanh Toán',
          color: Colors.white,
          fonSize: 16.sp,
          fonWeight: FontWeight.bold,
        ),
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // Background
          SizedBox(
            width: double.infinity,
            child: Image.asset('assets/icons/setIcon.png', fit: BoxFit.cover),
          ),

          SafeArea(
            child: Column(
              children: [
                SizedBox(height: 50.h),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: Container(
                    padding: EdgeInsets.all(10.r),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12.r),
                          child: Image(
                            image: CachedNetworkImageProvider(
                              widget.shop.shopAvatarImageUrl,
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
                              text: widget.shop.shopName,
                              color: Colors.white,
                              fonSize: 16.sp,
                              fonWeight: FontWeight.bold,
                            ),
                            Row(
                              children: [
                                const Icon(
                                  Icons.location_on_rounded,
                                  color: Colors.white,
                                  size: 16,
                                ),
                                SizedBox(width: 3.w),
                                customText(
                                  text: widget.shop.location.address,
                                  color: Colors.white,
                                  fonSize: 14.sp,
                                  fonWeight: FontWeight.normal,
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Image.asset(
                                  'assets/icons/star.png',
                                  width: 14.w,
                                  color: Colors.white,
                                ),
                                SizedBox(width: 3.w),
                                customText(
                                  text: '5.0 (24)',
                                  color: Colors.white,
                                  fonSize: 14.sp,
                                  fonWeight: FontWeight.normal,
                                ),
                              ],
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

          // Bottom trắng
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.66,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 8.w),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ngay thang dat
                      Row(
                        children: [
                          const Icon(Icons.calendar_month),
                          SizedBox(width: 2.w),
                          customText(
                            text: 'Ngày & thời gian',
                            color: const Color(0xFF111827),
                            fonSize: 16.sp,
                            fonWeight: FontWeight.bold,
                          ),
                        ],
                      ),
                      customText(
                        text:
                            '${bookingDateModel.time} - ${bookingDateModel.weekdayName}, ${bookingDateModel.date}',
                        color: const Color(0xFF6B7280),
                        fonSize: 16.sp,
                        fonWeight: FontWeight.normal,
                      ),
                      SizedBox(height: 10.h),

                      // danh sach dich vu
                      Row(
                        children: [
                          const Icon(CupertinoIcons.scissors_alt),
                          SizedBox(width: 2.w),
                          customText(
                            text: 'Danh sách dịch vụ',
                            color: const Color(0xFF111827),
                            fonSize: 16.sp,
                            fonWeight: FontWeight.bold,
                          ),
                        ],
                      ),
                      SizedBox(height: 8.h),

                      Column(
                        children: List.generate(
                          servicesSelected.services.length,
                          (index) {
                            final service = servicesSelected.services[index];
                            return Container(
                              margin: EdgeInsets.only(bottom: 12.h),
                              padding: EdgeInsets.all(8.r),
                              decoration: BoxDecoration(
                                color: Colors.grey.withOpacity(0.02),
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CircleAvatar(
                                    radius: 28.r,
                                    backgroundImage: CachedNetworkImageProvider(
                                      service.avatarUrl,
                                    ),
                                  ),
                                  SizedBox(width: 12.w),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        customText(
                                          text: service.name,
                                          color: const Color(0xFF111827),
                                          fonSize: 16.sp,
                                          fonWeight: FontWeight.bold,
                                        ),
                                        SizedBox(height: 4.h),
                                        customText(
                                          text: service.note,
                                          color: const Color(0xFF6B7280),
                                          fonSize: 13.sp,
                                          fonWeight: FontWeight.normal,
                                        ),
                                      ],
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      const Icon(
                                        CupertinoIcons.money_dollar,
                                        color: Color(0xFF111827),
                                        size: 16,
                                      ),
                                      SizedBox(width: 2.w),
                                      customText(
                                        text: FormatPrice.formatPrice(
                                          service.price,
                                        ),
                                        color: const Color(0xFF111827),
                                        fonSize: 14.sp,
                                        fonWeight: FontWeight.w600,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),

                      SizedBox(height: 12.h),
                      customText(
                        text: 'Mã giảm giá',
                        color: const Color(0xFF111827),
                        fonSize: 16.sp,
                        fonWeight: FontWeight.bold,
                      ),
                      SizedBox(height: 10.h),
                      Row(
                        children: [
                          Expanded(
                            flex: 4,
                            child: SizedBox(
                              height: 50.h,
                              child: TextField(
                                controller: couponController,
                                focusNode: _focusNode,
                                textAlign: TextAlign.start,
                                style: TextStyle(
                                  color: const Color(0xFF363062),
                                  fontSize: 13.sp,
                                ),
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: Colors.white,
                                  hintText: 'Nhập mã giảm giá',
                                  prefixIcon: Padding(
                                    padding: EdgeInsets.all(10.r),
                                    child: Icon(
                                      Icons.stars,
                                      color: Color(0xFF363062),
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.horizontal(
                                      left: Radius.circular(12.r),
                                    ),
                                    borderSide: const BorderSide(
                                      color: Color(0xFF363062),
                                      width: 1,
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.horizontal(
                                      left: Radius.circular(12.r),
                                    ),
                                    borderSide: const BorderSide(
                                      color: Color(0xFFD1D5DB),
                                      width: 1,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: SizedBox(
                              height: 50.h,
                              child: ElevatedButton(
                                onPressed: () {
                                  for (var i = 0; i < coupon.length; i++) {
                                    if (coupon[i] == couponController.text) {
                                      displayMessageToUser(
                                        context,
                                        'Đã áp dụng thành công',
                                        isSuccess: true,
                                        onOk: () {
                                          setState(() {
                                            isDisplay = true;
                                            checkCoupon = true;
                                          });
                                        },
                                      );
                                    } else {
                                      setState(() {
                                        isDisplay = true;
                                        checkCoupon = false;
                                      });
                                    }
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  elevation: 0,
                                  backgroundColor: const Color(0xFF363062),
                                  padding: EdgeInsets.zero,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.horizontal(
                                      right: Radius.circular(12.r),
                                    ),
                                  ),
                                ),
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: customText(
                                    text: 'Apply',
                                    color: Colors.white,
                                    fonSize: 12.sp,
                                    fonWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 3.h),
                      isDisplay
                          ? checkCoupon
                                ? Text(
                                    'Đã áp dụng mã',
                                    style: TextStyle(
                                      color: Color(0xFF9CA3AF),
                                      fontSize: 12.sp,
                                    ),
                                  )
                                : Text(
                                    'Mã không chính xác',
                                    style: TextStyle(
                                      color: Colors.red,
                                      fontSize: 12.sp,
                                    ),
                                  )
                          : SizedBox.shrink(),
                      SizedBox(height: 12.h),
                      customText(
                        text: 'Tóm tắt thanh toán',
                        color: Color(0xFF111827),
                        fonSize: 16.sp,
                        fonWeight: FontWeight.bold,
                      ),
                      SizedBox(height: 5.h),
                      Column(
                        children: List.generate(
                          servicesSelected.services.length,
                          (index) {
                            final service = servicesSelected.services[index];
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                customText(
                                  text: service.name,
                                  color: Color(0xFF111827),
                                  fonSize: 16.sp,
                                  fonWeight: FontWeight.normal,
                                ),
                                Row(
                                  children: [
                                    Icon(CupertinoIcons.money_dollar),
                                    customText(
                                      text: FormatPrice.formatPrice(
                                        service.price,
                                      ),
                                      color: Color(0xFF111827),
                                      fonSize: 16.sp,
                                      fonWeight: FontWeight.normal,
                                    ),
                                  ],
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                      SizedBox(height: 12.h),
                      LayoutBuilder(
                        builder: (context, constraints) {
                          return Dash(
                            direction: Axis.horizontal,
                            length: constraints.maxWidth,
                            dashLength: 8,
                            dashColor: Color(0xFFC3C1D0),
                          );
                        },
                      ),
                      SizedBox(height: 8.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          customText(
                            text: 'Tổng tiền',
                            color: Color(0xFF111827),
                            fonSize: 16.sp,
                            fonWeight: FontWeight.normal,
                          ),
                          Row(
                            children: [
                              Icon(CupertinoIcons.money_dollar),
                              customText(
                                text: FormatPrice.formatPrice(
                                  servicesSelected.total,
                                ),
                                color: Color(0xFF111827),
                                fonSize: 16.sp,
                                fonWeight: FontWeight.normal,
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: 8.h),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () async {
                            await _onContinue();
                          },
                          style: ElevatedButton.styleFrom(
                            elevation: 0,
                            padding: EdgeInsets.symmetric(vertical: 10.h),
                            backgroundColor: Color(0xFF363062),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              customText(
                                text: 'Thanh toán',
                                color: Colors.white,
                                fonSize: 16.sp,
                                fonWeight: FontWeight.bold,
                              ),
                              SizedBox(width: 5.w),
                              Icon(Icons.wallet, color: Colors.white),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _onContinue() async {
    try{
      if (await dtb.checkAmount(widget.tempData['idUser'], servicesSelected.total,)) {
        if (await dtb.booking(widget.tempData['idUser'], widget.tempData['idShop'], servicesSelected, bookingDateModel, widget.tempData['status'],)) {
          Navigator.push(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>
                  Invoice(
                    tempData: {
                      'shop': widget.shop,
                      'servicesSelected': servicesSelected,
                      'bookingDateModel': bookingDateModel
                    },
                  ),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                const begin = Offset(1.0, 0.0);
                const end = Offset.zero;
                final tween = Tween(begin: begin, end: end);
                final curvedAnimation = CurvedAnimation(
                  parent: animation,
                  curve: Curves.ease,
                );
                return SlideTransition(
                  position: tween.animate(curvedAnimation),
                  child: child,
                );
              },
              transitionDuration: const Duration(milliseconds: 1000),
            ),
          );
          dtb.sendNotification(object: 'Shops', id: widget.shop.id, title: 'Bạn có lịch hẹn mới!', body: 'Bạn có lịch hẹn mới, nhớ kiểm tra và xác nhận nhé 😊');
        }else{
          displayMessageToUser(
            context,
            'Có lỗi trong lúc đặt lịch. Vui lòng thao tác lại sau!',
            isSuccess: false,
            onOk: () {},
          );
        }
      } else {
        displayMessageToUser(
          context,
          'Tài khoản của bạn không đủ tiền. Vui lòng nạp thêm tiền để đặt lịch hẹn !',
          isSuccess: false,
          onOk: () {},
        );
      }
    }catch(e){
      print(e);
    }
  }
}
