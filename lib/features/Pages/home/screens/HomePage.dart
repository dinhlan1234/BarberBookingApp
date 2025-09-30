import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:testrunflutter/core/helper/aleart.dart';
import 'package:testrunflutter/core/widgets/MapCard.dart';
import 'package:testrunflutter/core/widgets/ShopCard.dart';
import 'package:testrunflutter/data/firebase/FireStore.dart';
import 'package:testrunflutter/data/models/ShopWithDistance.dart';
import 'package:testrunflutter/data/models/UserModel.dart';
import 'package:testrunflutter/data/repositories/prefs/UserPrefsService.dart';
import 'package:testrunflutter/features/Pages/home/screens/more/NearShop.dart';
import 'package:testrunflutter/features/Pages/home/screens/more/RateShop.dart';
import 'package:testrunflutter/features/Pages/home/screens/search/search_shop_field.dart';
import 'package:testrunflutter/features/Pages/home/widgets/HomePopup.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

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
  List<ShopWithDistance> listRateShops = [];

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
      if (mounted) {
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
        final result = await Future.wait([
          dtb.nearestShops(double.parse(lat), double.parse(lon)),
          dtb.getMostRated(double.parse(lat), double.parse(lon))
        ]);

        if(result[0].isNotEmpty && result[1].isNotEmpty){
          if(mounted){
            setState(() {
              listNearestShops = result[0];
              listRateShops = result[1];
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
    if (_isLoading) {
      return Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              LoadingAnimationWidget.bouncingBall(
                color: const Color(0XFF363062),
                size: 50.w,
              ),
              SizedBox(height: 20.h),
              Text(
                'Đang tìm kiếm quán gần đây cho bạn',
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
    }


    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        controller: _scrollController,
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0XFF363062),
                    const Color(0XFF363062).withOpacity(0.9),
                  ],
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(24.r),
                  bottomRight: Radius.circular(24.r),
                ),
              ),
              child: SafeArea(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 30.h),
                  child: Column(
                    children: [
                      // User info row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.location_on_rounded,
                                      color: Colors.white70,
                                      size: 18.sp,
                                    ),
                                    SizedBox(width: 6.w),
                                    Text(
                                      _userModel?.provinceName ?? 'Đang tải...',
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    )
                                  ],
                                ),
                                SizedBox(height: 4.h),
                                Text(
                                  'Chào, ${_userModel?.name ?? 'Người dùng'}!',
                                  style: TextStyle(
                                    fontSize: 20.sp,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                )
                              ],
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.all(3.w),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(50.r),
                            ),
                            child: CircleAvatar(
                              radius: 24.r,
                              backgroundImage: _userModel != null
                                  ? _userModel!.avatarUrl == '0'
                                  ? AssetImage('assets/images/avtMacDinh.jpg')
                                  : CachedNetworkImageProvider(_userModel!.avatarUrl)
                                  : AssetImage('assets/images/avtMacDinh.jpg'),
                            ),
                          )
                        ],
                      ),
                      SizedBox(height: 24.h),

                      // Search field
                      SearchShopField(lat: double.parse(lat), lon: double.parse(lon), userModel: _userModel!),
                    ],
                  ),
                ),
              ),
            ),

            // Main content
            Padding(
              padding: EdgeInsets.all(20.w),
              child: Column(
                children: [
                  // Hero banner
                  Container(
                    width: double.infinity,
                    height: 220.h,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20.r),
                      gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                          const Color(0XFFFBBF74).withOpacity(0.9),
                          const Color(0XFFFBBF74),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0XFFFBBF74).withOpacity(0.3),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(20.r),
                          child: Image.asset(
                            'assets/images/barber2.png',
                            width: double.infinity,
                            height: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20.r),
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withOpacity(0.6),
                              ],
                            ),
                          ),
                        ),
                        Positioned(
                          top: 20.h,
                          left: 20.w,
                          child: Container(
                            padding: EdgeInsets.all(12.w),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.9),
                              borderRadius: BorderRadius.circular(16.r),
                            ),
                            child: Image.asset(
                              'assets/images/Barber3.png',
                              width: 32.w,
                              height: 32.h,
                            ),
                          ),
                        ),
                        Positioned(
                          top: 25.h,
                          right: 0.w,
                          child: Image.asset(
                            'assets/images/welcome3.png',
                            width: 140.w,
                            height: 170.h,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          bottom: 20.h,
                          left: 20.w,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Tìm kiếm\nBarber Shop tốt nhất',
                                style: TextStyle(
                                  fontSize: 18.sp,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  height: 1.2,
                                ),
                              ),
                              SizedBox(height: 12.h),
                              ElevatedButton(
                                onPressed: () async {},
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: const Color(0XFF363062),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(25.r),
                                  ),
                                  padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                                  elevation: 0,
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'Đặt Ngay',
                                      style: TextStyle(
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(width: 8.w),
                                    Icon(Icons.arrow_forward_rounded, size: 16.sp),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                  SizedBox(height: 32.h),

                  // Nearby shops section
                  _buildSectionHeader('Quán cắt tóc gần đây', Icons.location_on_rounded),
                  SizedBox(height: 16.h),

                  if (listNearestShops.isNotEmpty)
                    ...listNearestShops.take(3).map((shop) {
                      final locationModel = shop.shop.location;
                      return Container(
                        margin: EdgeInsets.only(bottom: 16.h),
                        child: ShopCard(
                          shop: shop.shop,
                          km: shop.distanceKm,
                          urlImage: shop.shop.shopAvatarImageUrl,
                          name: shop.shop.shopName,
                          address: locationModel.address,
                          rate: '${double.parse(shop.ratingModel.rating.toString())} (${shop.ratingModel.quantity})',
                        ),
                      );
                    }).toList()
                  else
                    _buildEmptyState('Không có quán cắt tóc gần đây', Icons.store_outlined),

                  SizedBox(height: 16.h),
                  _buildViewAllButton(() {
                    Navigator.push(context, _createSlideRoute(NearShop(list: listNearestShops)));
                  }),

                  SizedBox(height: 32.h),

                  // Top rated section
                  _buildSectionHeader('Đánh giá cao nhất', Icons.star_rounded),
                  SizedBox(height: 16.h),

                  if (listRateShops.isNotEmpty)
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20.r),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          SizedBox(
                            height: 240.h,
                            child: PageView.builder(
                              controller: _pageController,
                              itemCount: listRateShops.length.clamp(0, 3),
                              onPageChanged: (index) {
                                setState(() {
                                  _currentPage = index;
                                });
                              },
                              itemBuilder: (context, index) {
                                final shop = listRateShops[index];
                                return Stack(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(20.r),
                                      child: CachedNetworkImage(
                                        imageUrl: shop.shop.backgroundImageUrl,
                                        width: double.infinity,
                                        height: 240.h,
                                        fit: BoxFit.cover,
                                        placeholder: (context, url) => Container(
                                          color: Colors.grey[200],
                                          child: const Center(child: CircularProgressIndicator()),
                                        ),
                                      ),
                                    ),
                                    Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(20.r),
                                        gradient: LinearGradient(
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                          colors: [
                                            Colors.transparent,
                                            Colors.black.withOpacity(0.7),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      top: 16.h,
                                      right: 16.w,
                                      child: Container(
                                        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.9),
                                          borderRadius: BorderRadius.circular(20.r),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              Icons.star_rounded,
                                              color: Colors.amber,
                                              size: 16.sp,
                                            ),
                                            SizedBox(width: 4.w),
                                            Text(
                                              '${double.parse(shop.ratingModel.rating.toString())}',
                                              style: TextStyle(
                                                fontSize: 12.sp,
                                                fontWeight: FontWeight.bold,
                                                color: const Color(0XFF363062),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      bottom: 16.h,
                                      right: 16.w,
                                      child: Container(
                                        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF363062),
                                          borderRadius: BorderRadius.circular(25.r),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              'Booking',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 12.sp,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            SizedBox(width: 6.w),
                                            Icon(Icons.calendar_month, color: Colors.white, size: 16.sp),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                          SizedBox(height: 16.h),

                          // Shop info
                          Container(
                            padding: EdgeInsets.all(20.w),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20.r),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        listRateShops[_currentPage].shop.shopName,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16.sp,
                                          color: const Color(0xFF111827),
                                        ),
                                      ),
                                    ),
                                    SmoothPageIndicator(
                                      controller: _pageController,
                                      count: listRateShops.length.clamp(0, 3),
                                      effect: ExpandingDotsEffect(
                                        activeDotColor: const Color(0xFF363062),
                                        dotColor: const Color(0xFF6B7280).withOpacity(0.3),
                                        dotHeight: 8.h,
                                        dotWidth: 8.w,
                                        spacing: 6.w,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 8.h),
                                Row(
                                  children: [
                                    Icon(Icons.location_on_outlined, size: 16.sp, color: const Color(0xFF6B7280)),
                                    SizedBox(width: 6.w),
                                    Expanded(
                                      child: Text(
                                        listRateShops[_currentPage].shop.location.address,
                                        style: TextStyle(color: const Color(0xFF6B7280), fontSize: 13.sp),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 4.h),
                                Row(
                                  children: [
                                    Icon(Icons.star_rounded, size: 16.sp, color: Colors.amber),
                                    SizedBox(width: 6.w),
                                    Text(
                                      '${double.parse(listRateShops[_currentPage].ratingModel.rating.toString())} (${listRateShops[_currentPage].ratingModel.quantity} đánh giá)',
                                      style: TextStyle(color: const Color(0xFF6B7280), fontSize: 13.sp),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    _buildEmptyState('Chưa có dữ liệu đánh giá', Icons.star_outline_rounded),

                  SizedBox(height: 16.h),
                  _buildViewAllButton(() {
                    Navigator.push(context, _createSlideRoute(RateShop(list: listRateShops)));
                  }),

                  SizedBox(height: 32.h),

                  // Map section
                  _buildSectionHeader('Tìm barbershop gần bạn', Icons.map_rounded),
                  SizedBox(height: 16.h),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20.r),
                      child: MapCard(isDisplay: true, height: 220, searchController: searchController),
                    ),
                  ),
                  SizedBox(height: 20.h),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color: const Color(0XFF363062).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Icon(
            icon,
            color: const Color(0XFF363062),
            size: 20.sp,
          ),
        ),
        SizedBox(width: 12.w),
        Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18.sp,
            color: const Color(0XFF111827),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(String message, IconData icon) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 40.h, horizontal: 20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFF6B7280).withOpacity(0.1)),
      ),
      child: Center(
        child: Column(
          children: [
            Icon(
              icon,
              size: 48.sp,
              color: const Color(0xFF6B7280).withOpacity(0.5),
            ),
            SizedBox(height: 12.h),
            Text(
              message,
              style: TextStyle(
                fontSize: 16.sp,
                color: const Color(0xFF6B7280),
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildViewAllButton(VoidCallback onPressed) {
    return Container(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: const Color(0XFF363062), width: 1.5.w),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 24.w),
          backgroundColor: Colors.white,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Xem tất cả',
              style: TextStyle(
                fontSize: 14.sp,
                color: const Color(0XFF363062),
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(width: 8.w),
            Icon(
              Icons.arrow_forward_rounded,
              color: const Color(0xFF363062),
              size: 18.sp,
            )
          ],
        ),
      ),
    );
  }

  PageRouteBuilder _createSlideRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        final tween = Tween(begin: begin, end: end);
        final curvedAnimation = CurvedAnimation(parent: animation, curve: Curves.easeInOut);
        return SlideTransition(
          position: tween.animate(curvedAnimation),
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 400),
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