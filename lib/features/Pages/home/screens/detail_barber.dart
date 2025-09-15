import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:testrunflutter/core/widgets/TextBasic.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:testrunflutter/data/models/ShopModel.dart';
import 'package:testrunflutter/features/Pages/home/cubit/Service/ServiceCubit.dart';
import 'package:testrunflutter/features/Pages/home/cubit/Service/ServiceState.dart';
import 'package:testrunflutter/features/Pages/home/widgets/TabContent/buildTabContent.dart';
import 'package:testrunflutter/features/Pages/home/widgets/buildActionButton.dart';
import 'package:url_launcher/url_launcher.dart';

// trang 2
class DetailBarber extends StatefulWidget {
  final ShopModel shop;
  final double km;

  const DetailBarber({super.key, required this.shop, required this.km});

  @override
  State<DetailBarber> createState() => _DetailBarberState();
}

class _DetailBarberState extends State<DetailBarber>
    with SingleTickerProviderStateMixin {
  bool isFavorite = false;
  int selectedIndex = 0;
  final tabs = ['Về chúng tôi', 'Các dịch vụ', 'Lịch trình', 'Đánh giá'];
  late final ServiceCubit _serviceCubit;

  @override
  void initState() {
    super.initState();
    _serviceCubit = ServiceCubit(idShop: widget.shop.id);
  }

  @override
  void dispose() {
    _serviceCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _serviceCubit,
      child: Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: Icon(Icons.arrow_back),
                      ),
                      customText(
                        text: 'Chi tiết quán',
                        color: Color(0XFF111827),
                        fonSize: 16.sp,
                        fonWeight: FontWeight.bold,
                      ),
                    ],
                  ),
                  SizedBox(height: 10.h),
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12.r),
                        child: Image(
                          image: CachedNetworkImageProvider(
                            widget.shop.backgroundImageUrl,
                          ),
                          width: double.infinity,
                          height: 210.h,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: 0,
                        right: 0,
                        child: Container(
                          decoration: BoxDecoration(
                            color:
                                isShopOpen(
                                  widget.shop.openHour,
                                  widget.shop.closeHour,
                                  widget.shop.openDays,
                                )
                                ? Color(0xFF27AE60)
                                : Colors.red,
                            borderRadius: BorderRadius.only(
                              topRight: Radius.circular(12.r),
                              bottomLeft: Radius.circular(12.r),
                            ),
                          ),
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              vertical: 8.h,
                              horizontal: 8.w,
                            ),
                            child: customText(
                              text:
                                  isShopOpen(
                                    widget.shop.openHour,
                                    widget.shop.closeHour,
                                    widget.shop.openDays,
                                  )
                                  ? 'Mở cửa'
                                  : 'Đóng cửa',
                              color: Colors.white,
                              fonSize: 14.sp,
                              fonWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  // ten shop
                  customText(
                    text: widget.shop.shopName,
                    color: Color(0xFF111827),
                    fonSize: 16.sp,
                    fonWeight: FontWeight.bold,
                  ),
                  SizedBox(height: 4.h),
                  Row(
                    children: [
                      Icon(Icons.location_on_rounded, color: Color(0xFF8683A1)),
                      SizedBox(width: 8.w),
                      customText(
                        text:
                            '${widget.shop.location.address} (${widget.km == 0.0 ? '0.1' : widget.km}km)',
                        color: Color(0xFF8683A1),
                        fonSize: 14.sp,
                        fonWeight: FontWeight.normal,
                      ),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  Row(
                    children: [
                      Icon(Icons.star_outlined, color: Color(0xFF8683A1)),
                      customText(
                        text: '  ${widget.shop.ratingAvg}',
                        color: Color(0xFF8683A1),
                        fonSize: 14.sp,
                        fonWeight: FontWeight.normal,
                      ),
                    ],
                  ),
                  SizedBox(height: 10.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      buildActionButton(
                        color: Color(0xFF363062),
                        checkColor: false,
                        check: false,
                        imagePath: 'assets/icons/google-maps.png',
                        label: 'Maps',
                        onTab: () {
                          openMapWithAddress(
                            address: widget.shop.location.address,
                            wardName: widget.shop.location.wardName,
                            districtName: widget.shop.location.districtName,
                            provinceName: widget.shop.location.provinceName,
                          );
                        },
                      ),
                      buildActionButton(
                        color: Color(0xFF363062),
                        checkColor: true,
                        check: false,
                        imagePath: 'assets/icons/bubble-chat.png',
                        label: 'Chat',
                        onTab: () {},
                      ),
                      buildActionButton(
                        color: Color(0xFF363062),
                        checkColor: false,
                        check: false,
                        imagePath: 'assets/icons/share.png',
                        label: 'Share',
                        onTab: () {},
                      ),
                      buildActionButton(
                        color: isFavorite ? Colors.red : Colors.grey,
                        checkColor: true,
                        check: true,
                        imagePath: 'assets/icons/Share.png',
                        label: 'Yêu thích',
                        onTab: () {
                          setState(() {
                            isFavorite = !isFavorite;
                          });
                        },
                      ),
                    ],
                  ),

                  SizedBox(height: 20.h),

                  // =============== TAB BAR ===================
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      decoration: BoxDecoration(
                        color: Color(0XFFEDEFFB),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: List.generate(tabs.length, (index) {
                          final selected = selectedIndex == index;
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedIndex = index;
                              });
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 12.w,
                                vertical: 8.h,
                              ),
                              decoration: BoxDecoration(
                                color: selected
                                    ? Color(0xFFE0DFF9)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(12.r),
                                border: Border.all(
                                  color: selected
                                      ? Color(0xFF363062)
                                      : Colors.transparent,
                                ),
                              ),
                              child: Text(
                                tabs[index],
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: selected
                                      ? Color(0xFF363062)
                                      : Colors.grey,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                  ),

                  SizedBox(height: 20.h),

                  // =============== TAB NỘI DUNG ==============
                  BlocBuilder<ServiceCubit, ServiceState>(
                    builder: (context, state) {
                      if (state is ServiceLoading) {
                        return Center(child: CircularProgressIndicator());
                      }
                      if (state is ServiceError) {
                        return Center(child: Text(state.message));
                      }
                      if (state is ServiceLoaded) {
                        return buildTabContent(
                          index: selectedIndex,
                          shop: widget.shop,
                          listServices: state.listServices, // truyền dữ liệu cho tab
                        );
                      }
                      return SizedBox();
                    },
                  ),

                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  bool isShopOpen(String openHour, String closeHour, List<String> openDays) {
    final now = DateTime.now();

    final weekdayNames = {
      DateTime.monday: "Thứ 2",
      DateTime.tuesday: "Thứ 3",
      DateTime.wednesday: "Thứ 4",
      DateTime.thursday: "Thứ 5",
      DateTime.friday: "Thứ 6",
      DateTime.saturday: "Thứ 7",
      DateTime.sunday: "Chủ nhật",
    };

    final todayName = weekdayNames[now.weekday];
    if (todayName == null || !openDays.contains(todayName)) {
      return false;
    }

    final openParts = openHour.split(":");
    final closeParts = closeHour.split(":");

    final openTime = DateTime(
      now.year,
      now.month,
      now.day,
      int.parse(openParts[0]),
      int.parse(openParts[1]),
    );

    final closeTime = DateTime(
      now.year,
      now.month,
      now.day,
      int.parse(closeParts[0]),
      int.parse(closeParts[1]),
    );

    if (closeTime.isAfter(openTime)) {
      // Mở và đóng trong cùng 1 ngày
      return now.isAfter(openTime) && now.isBefore(closeTime);
    } else {
      // Trường hợp shop mở qua đêm
      return now.isAfter(openTime) || now.isBefore(closeTime);
    }
  }

  Future<void> openMapWithAddress({
    required String address,
    required String wardName,
    required String districtName,
    required String provinceName,
  }) async {
    final fullAddress = "$address, $wardName, $districtName, $provinceName";
    final Uri uri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(fullAddress)}',
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      throw 'Không thể mở Google Maps';
    }
  }
}
