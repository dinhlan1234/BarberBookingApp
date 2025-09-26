import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:testrunflutter/core/format/FormatPrice.dart';
import 'package:testrunflutter/core/helper/aleart.dart';
import 'package:testrunflutter/core/widgets/MapCard.dart';
import 'package:testrunflutter/core/widgets/ShopCard.dart';
import 'package:testrunflutter/core/widgets/TextBasic.dart';
import 'package:testrunflutter/data/firebase/FireStore.dart';
import 'package:testrunflutter/data/models/LocationModel.dart';
import 'package:testrunflutter/data/models/ShopModel.dart';
import 'package:testrunflutter/data/models/ShopWithDistance.dart';
import 'package:testrunflutter/data/models/UserModel.dart';
import 'package:testrunflutter/data/repositories/prefs/UserPrefsService.dart';
import 'package:testrunflutter/features/Pages/home/cubit/City/CityState.dart';
import 'package:testrunflutter/features/Pages/home/screens/search/search_shop_field.dart';
import 'package:testrunflutter/features/Pages/home/widgets/HomePopup.dart';
import 'package:testrunflutter/features/Pages/home/cubit/City/CityCubit.dart';
import 'package:vietnam_provinces/vietnam_provinces.dart';
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  UserModel? _userModel;

  final TextEditingController searchController = TextEditingController();

  int _currentPage = 0;

  final ScrollController _scrollController = ScrollController();
  final PageController _pageController = PageController();
  FireStoreDatabase dtb = FireStoreDatabase();

  late final String lat;
  late final String lon;
  bool _isLoading = true;


  Map<String,dynamic>? data;
  List<ShopWithDistance> listNearestShops = [];

  @override
  void dispose() {
    _pageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    Future.wait([
    getUser(),
    fetchLocation(),
    ]).then((_){
      if (mounted) setState(() => _isLoading = false);
    });
  }
  Future<void> getUser() async {
    final userData = await UserPrefsService.getUser();
    if (mounted) {
      setState(() {
        _userModel = userData;
      });
    } else {
      final newData = await dtb.getUserByEmail();
      if (mounted) { // Kiểm tra mounted
        setState(() {
          _userModel = newData;
        });
      }
    }
  }
  Future<void> fetchLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          displayMessageToUser(context, 'Vui lòng cấp quyền vị trí để sử dụng ứng dụng',isSuccess: false,onOk: (){Navigator.pop(context);});
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        displayMessageToUser(context, 'Quyền vị trí bị từ chối vĩnh viễn. Vui lòng vào cài đặt để bật',isSuccess: false,onOk: (){Navigator.pop(context);});
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      lat = position.latitude.toString();
      lon = position.longitude.toString();

      if(lat.isNotEmpty && lon.isNotEmpty){
        final listShop = await dtb.nearestShops(double.parse(lat), double.parse(lon));
        if(listShop.isNotEmpty){
          if(mounted){
            setState(() {
              listNearestShops = listShop;
            });
          }
        }
      }
    } catch (e) {
      print('Lỗi: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String,dynamic>> shops = [
      {
        'image': 'assets/images/avtBarber.jpg',
        'name': 'Master piece Barbershop – Haircut styling',
        'address': 'Joga Expo Centre (2 km)',
        'rate': '5.0',
      },
      {
        'image': 'assets/images/avtBarber.jpg',
        'name': 'Bom Barber – Haircut styling',
        'address': '39 Lê Thiện Trị',
        'rate': '5.0',
      },
      {
        'image': 'assets/images/avtBarber.jpg',
        'name': 'Central Barber – Haircut styling',
        'address': '3 Cách Mạng Tháng 8',
        'rate': '5.0',
      },
    ];
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        controller: _scrollController,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 15.h,horizontal: 12.w),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.location_on_rounded, color: const Color(0XFF363062),
                            weight: 16.w,),
                          SizedBox(width: 1.w,),
                          customText(
                            text: _userModel!.provinceName,
                            color: Color(0xFF6B7280),
                            fonSize: 14.sp,
                            fonWeight: FontWeight.normal,
                          )
                        ],
                      ),
                    Row(
                      children: [
                        SizedBox(width: 4.w,),
                        _userModel == null
                            ? Center(child: CircularProgressIndicator(),)
                            : Text(
                          _userModel!.name,
                          style: TextStyle(fontSize: 18.sp, color: const Color(0XFF111827)),)
                      ],
                    )
                    ],
                  ),
                  CircleAvatar(
                    backgroundImage: _userModel != null
                        ? _userModel!.avatarUrl == '0'
                              ? AssetImage('assets/images/avtMacDinh.jpg')
                              : CachedNetworkImageProvider(_userModel!.avatarUrl)
                        : AssetImage('assets/images/avtMacDinh.jpg'),
                  )
                ],
              ),
              SizedBox(height: 14.h),
              // phần hình ảnh lớn
              Container(
                width: 339.w,
                height: 200.h,
                clipBehavior: Clip.hardEdge,
                decoration: BoxDecoration(
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Stack(
                  children: [
                    Image.asset('assets/images/barber2.png',width: double.infinity,height: double.infinity,fit: BoxFit.cover,),
                    Positioned(
                        top: 12.h,
                        left: 13.w,
                        child: Container(
                            width: 56.w,
                            height: 56.h,
                            decoration: BoxDecoration(
                                color: const Color(0XFFFBBF74),
                                shape: BoxShape.rectangle,
                                borderRadius: BorderRadius.circular(12.r)
                            ),
                            child: Image.asset('assets/images/Barber3.png',width:double.infinity,height: double.infinity,fit: BoxFit.cover,)
                        )
                    ),
                    Positioned(
                        top: 30.h,
                        right: 0.w,
                        child: Image.asset('assets/images/welcome3.png',width:150.w,height:190.h,fit: BoxFit.cover,)
                    ),
                    Positioned(
                        bottom: 5.h,
                        left: 5.w,
                        child: ElevatedButton(
                            onPressed: () async{

                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0XFF363062),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.r)
                              ),
                              padding: EdgeInsets.symmetric(horizontal: 30.w),
                            ),
                            child: Text('Đặt Ngay',style: TextStyle(fontSize: 12.sp,color: Colors.white),)
                        )
                    )
                  ],
                ),
              ),
              SizedBox(height: 14.h,),
              // Phần tìm kiếm
              SearchShopField(lat: double.parse(lat), lon: double.parse(lon),userModel: _userModel!),
              SizedBox(height: 14.h,),

              // quán cắt tóc gần đây
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text('Quán cắt tóc gần đây',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 17 .sp,color: const Color(0XFF111827)),),
                ],
              ),
              SizedBox(height: 14.h,),
              if (listNearestShops.isNotEmpty)
                ...listNearestShops.take(3).map((shop) {
                  final locationModel = shop.shop.location;
                  return ShopCard(
                    shop: shop.shop,
                    km: shop.distanceKm,
                    urlImage: shop.shop.shopAvatarImageUrl,
                    name: shop.shop.shopName,
                    address: locationModel.address,
                    rate: '${double.parse(shop.ratingModel.rating.toString())} (${shop.ratingModel.quantity})',
                  );
                }).toList()
              else
                SizedBox(
                  height: 100.h,
                  child: const Center(
                    child: Text(
                      'Không có quán cắt tóc gần đây',
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ),
                ),

              OutlinedButton(
                  onPressed: (){},
                  style: OutlinedButton.styleFrom(
                      side: BorderSide(color: const Color(0XFF363062),width: 1.5.w),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r)
                      ),
                      padding: EdgeInsets.symmetric(vertical: 12.h,horizontal: 16.w)
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Xem tất cả',style: TextStyle(fontSize: 13.sp,color: const Color(0XFF363062)),),
                      SizedBox(width: 5.w,),
                      Icon(Icons.open_in_new_outlined,color: Color(0xFF363062), size: 22,)
                    ],
                  )
              ),
              SizedBox(height: 16.h,),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Đánh giá nhiều nhất', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17.sp, color: const Color(0xFF111827))),
                  SizedBox(height: 12.h),
                  SizedBox(
                    height: 200.h, // Chiều cao cố định cho PageView
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: shops.length,
                      onPageChanged: (index){
                        setState(() {
                          _currentPage = index;
                        });
                      },
                      itemBuilder: (context, index) {
                        final shop = shops[index];
                        return Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12.r),
                              child: Image.asset(
                                shop['image'],
                                width: double.infinity,
                                height: 200.h,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Positioned(
                              bottom: 10.h,
                              right: 10.w,
                              child: Container(
                                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF363062),
                                  borderRadius: BorderRadius.circular(8.r),
                                ),
                                child: Row(
                                  children: [
                                    Text(
                                      'Booking',
                                      style: TextStyle(color: Colors.white, fontSize: 12.sp),
                                    ),
                                    SizedBox(width: 6.w),
                                    Icon(Icons.calendar_month, color: Colors.white, size: 18.sp),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  SizedBox(height: 12.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      SmoothPageIndicator(
                        controller: _pageController,
                        count: shops.length,
                        effect: ExpandingDotsEffect(
                          activeDotColor: const Color(0xFF363062),
                          dotColor: const Color(0xFF6B7280),
                          dotHeight: 8.h,
                          dotWidth: 8.w,
                          spacing: 6.w,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    shops[_currentPage]['name'],
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15.sp, color: const Color(0xFF111827)),
                  ),
                  SizedBox(height: 4.h),
                  Row(
                    children: [
                      Icon(Icons.location_on_outlined, size: 16.sp, color: const Color(0xFF6B7280)),
                      SizedBox(width: 4.w),
                      Text(
                        shops[_currentPage]['address'],
                        style: TextStyle(color: const Color(0xFF6B7280), fontSize: 13.sp),
                      ),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  Row(
                    children: [
                      Icon(Icons.star, size: 16.sp, color: const Color(0xFF6B7280)),
                      SizedBox(width: 4.w),
                      Text('5.0', style: TextStyle(color: const Color(0xFF6B7280), fontSize: 13.sp)),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 10.h,),
              OutlinedButton(
                  onPressed: (){},
                  style: OutlinedButton.styleFrom(
                      side: BorderSide(color: const Color(0XFF363062),width: 1.5.w),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r)
                      ),
                      padding: EdgeInsets.symmetric(vertical: 12.h,horizontal: 16.w)
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Xem tất cả',style: TextStyle(fontSize: 13.sp,color: const Color(0XFF363062)),),
                      SizedBox(width: 5.w,),
                      Icon(Icons.open_in_new_outlined,color: Color(0xFF363062), size: 22,)
                    ],
                  )
              ),
              SizedBox(height: 16.h,),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Find a barber nearby',
                    style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 16.h,),
                  MapCard(isDisplay: true,height: 200,searchController: searchController)
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}


void _openPopup(context) {
  showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Color(0XFFEDEFFB),
      builder: (BuildContext bc) => OpenPopup()
  );
}