import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:testrunflutter/core/widgets/TextBasic.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:testrunflutter/data/firebase/ChatRepository.dart';
import 'package:testrunflutter/data/firebase/FireStore.dart';
import 'package:testrunflutter/data/models/LikeModel.dart';
import 'package:testrunflutter/data/models/ShopModel.dart';
import 'package:testrunflutter/data/models/UserModel.dart';
import 'package:testrunflutter/data/repositories/prefs/UserPrefsService.dart';
import 'package:testrunflutter/features/Pages/chat/screens/ChatPage.dart';
import 'package:testrunflutter/features/Pages/home/cubit/Service/ServiceCubit.dart';
import 'package:testrunflutter/features/Pages/home/cubit/Service/ServiceState.dart';
import 'package:testrunflutter/features/Pages/home/cubit/Schedules/SchedulesCubit.dart';
import 'package:testrunflutter/features/Pages/home/widgets/TabContent/buildTabContent.dart';
import 'package:testrunflutter/features/Pages/home/widgets/buildActionButton.dart';
import 'package:url_launcher/url_launcher.dart';

// Chi tiet quan
class DetailBarber extends StatefulWidget {
  final ShopModel shop;
  final double km;
  final String rate;

  const DetailBarber({super.key, required this.shop, required this.km,required this.rate});

  @override
  State<DetailBarber> createState() => _DetailBarberState();
}

class _DetailBarberState extends State<DetailBarber> with SingleTickerProviderStateMixin {
  FireStoreDatabase dtb = FireStoreDatabase();
  UserModel? _userModel;
  bool isFavorite = false;
  int selectedIndex = 0;
  final tabs = ['Về chúng tôi', 'Các dịch vụ', 'Lịch trình', 'Đánh giá'];
  late final ServiceCubit _serviceCubit;
  late final SchedulesCubit _schedulesCubit;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _serviceCubit = ServiceCubit(idShop: widget.shop.id);
    _schedulesCubit = SchedulesCubit(idShop: widget.shop.id);
    checkLike();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _serviceCubit.close();
    _schedulesCubit.close();
    _animationController.dispose();
    super.dispose();
  }
  Future<void> checkLike() async{
    final userData = await UserPrefsService.getUser();
    if (userData != null) {
      isFavorite = await dtb.checkLike(widget.shop.id, userData.id);
      setState(() {
        _userModel = userData;
      });
    } else {
      final newData = await dtb.getUserByEmail();
      isFavorite = await dtb.checkLike(widget.shop.id, newData!.id);
      setState(() {
        _userModel = newData;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _serviceCubit),
        BlocProvider.value(value: _schedulesCubit),
      ],
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        body: CustomScrollView(
          slivers: [
            // Custom App Bar with Hero Image
            SliverAppBar(
              expandedHeight: 280.h,
              pinned: true,
              backgroundColor: const Color(0XFF363062),
              leading: Container(
                margin: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: const Color(0XFF363062),
                    size: 20.sp,
                  ),
                ),
              ),
              actions: [
                Container(
                  margin: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: IconButton(
                    onPressed: () {},
                    icon: Icon(
                      Icons.share_rounded,
                      color: const Color(0XFF363062),
                      size: 20.sp,
                    ),
                  ),
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                background: Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(24.r),
                          bottomRight: Radius.circular(24.r),
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(24.r),
                          bottomRight: Radius.circular(24.r),
                        ),
                        child: CachedNetworkImage(
                          imageUrl: widget.shop.backgroundImageUrl,
                          width: double.infinity,
                          height: double.infinity,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            color: Colors.grey[300],
                            child: const Center(child: CircularProgressIndicator()),
                          ),
                        ),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(24.r),
                          bottomRight: Radius.circular(24.r),
                        ),
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
                      top: 60.h,
                      right: 16.w,
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                        decoration: BoxDecoration(
                          color: isShopOpen(
                            widget.shop.openHour,
                            widget.shop.closeHour,
                            widget.shop.openDays,
                          )
                              ? const Color(0xFF10B981)
                              : const Color(0xFFEF4444),
                          borderRadius: BorderRadius.circular(20.r),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 8.w,
                              height: 8.w,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(4.r),
                              ),
                            ),
                            SizedBox(width: 6.w),
                            Text(
                              isShopOpen(
                                widget.shop.openHour,
                                widget.shop.closeHour,
                                widget.shop.openDays,
                              )
                                  ? 'Đang mở cửa'
                                  : 'Đã đóng cửa',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Main Content
            SliverToBoxAdapter(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Padding(
                  padding: EdgeInsets.all(20.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Shop Info Card
                      Container(
                        padding: EdgeInsets.all(20.w),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20.r),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 20,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.shop.shopName,
                              style: TextStyle(
                                fontSize: 20.sp,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF111827),
                              ),
                            ),
                            SizedBox(height: 12.h),
                            Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(8.w),
                                  decoration: BoxDecoration(
                                    color: const Color(0XFF363062).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8.r),
                                  ),
                                  child: Icon(
                                    Icons.location_on_rounded,
                                    color: const Color(0XFF363062),
                                    size: 16.sp,
                                  ),
                                ),
                                SizedBox(width: 12.w),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Địa chỉ',
                                        style: TextStyle(
                                          fontSize: 12.sp,
                                          color: const Color(0xFF6B7280),
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      Text(
                                        '${widget.shop.location.address} (${widget.km == 0.0 ? '0.1' : widget.km}km)',
                                        style: TextStyle(
                                          fontSize: 14.sp,
                                          color: const Color(0xFF111827),
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 12.h),
                            Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(8.w),
                                  decoration: BoxDecoration(
                                    color: Colors.amber.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8.r),
                                  ),
                                  child: Icon(
                                    Icons.star_rounded,
                                    color: Colors.amber,
                                    size: 16.sp,
                                  ),
                                ),
                                SizedBox(width: 12.w),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Đánh giá',
                                      style: TextStyle(
                                        fontSize: 12.sp,
                                        color: const Color(0xFF6B7280),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    Text(
                                      widget.rate,
                                      style: TextStyle(
                                        fontSize: 14.sp,
                                        color: const Color(0xFF111827),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 24.h),

                      // Action Buttons
                      Container(
                        padding: EdgeInsets.all(20.w),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20.r),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 20,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildModernActionButton(
                              icon: Icons.map_outlined,
                              label: 'Bản đồ',
                              color: const Color(0xFF3B82F6),
                              onTap: () {
                                openMapWithAddress(
                                  address: widget.shop.location.address,
                                  wardName: widget.shop.location.wardName,
                                  districtName: widget.shop.location.districtName,
                                  provinceName: widget.shop.location.provinceName,
                                );
                              },
                            ),
                            _buildModernActionButton(
                              icon: Icons.chat_bubble_outline_rounded,
                              label: 'Chat',
                              color: const Color(0xFF10B981),
                              onTap: () async{
                                ChatRepository chatRepository = ChatRepository();
                                final currentUserId = _userModel!.id;
                                final shopId = widget.shop.id;
                                final shopName = widget.shop.shopName;
                                final shopAvatar = widget.shop.shopAvatarImageUrl;
                                final conversationId = await chatRepository.getOrCreateConversation(userId: currentUserId, userName: _userModel!.name, shopId: shopId, shopName: shopName,shopAvatar: shopAvatar,shopAddress: widget.shop.location.address,userAvatar: _userModel!.avatarUrl);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ChatPage(
                                      conversationId: conversationId.id,
                                      currentUserId: currentUserId,
                                      currentUserType: "user",
                                      shopName: shopName,
                                      shopAvatar: shopAvatar,
                                    ),
                                  ),
                                );
                              },
                            ),
                            _buildModernActionButton(
                              icon: Icons.phone_outlined,
                              label: 'Gọi',
                              color: const Color(0xFF8B5CF6),
                              onTap: () {
                                openPhoneDialer(widget.shop.phone);
                              },
                            ),
                            _buildModernActionButton(
                              icon: isFavorite ? Icons.favorite : Icons.favorite_border,
                              label: isFavorite ? 'Đã thích' : 'Yêu thích',
                              color: isFavorite ? const Color(0xFFEF4444) : const Color(0xFF6B7280),
                              onTap: () async{
                                final likeModel = LikeModel(idUser:  _userModel!.id, timestamp: Timestamp.now());
                                dtb.likeOrDislike(widget.shop.id, _userModel!.id, likeModel);
                                setState(() {
                                  isFavorite = !isFavorite;
                                });
                              },
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 32.h),

                      // Tab Bar
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16.r),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          padding: EdgeInsets.all(4.w),
                          child: Row(
                            children: List.generate(tabs.length, (index) {
                              final selected = selectedIndex == index;
                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    selectedIndex = index;
                                  });
                                },
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  margin: EdgeInsets.symmetric(horizontal: 2.w),
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 20.w,
                                    vertical: 12.h,
                                  ),
                                  decoration: BoxDecoration(
                                    color: selected
                                        ? const Color(0XFF363062)
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(12.r),
                                  ),
                                  child: Text(
                                    tabs[index],
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      color: selected
                                          ? Colors.white
                                          : const Color(0xFF6B7280),
                                      fontWeight: selected
                                          ? FontWeight.w600
                                          : FontWeight.w500,
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ),
                        ),
                      ),

                      SizedBox(height: 24.h),

                      // Tab Content
                      BlocBuilder<ServiceCubit, ServiceState>(
                        builder: (context, state) {
                          if (state is ServiceLoading) {
                            return _buildLoadingState();
                          }
                          if (state is ServiceError) {
                            return _buildErrorState(state.message);
                          }
                          if (state is ServiceLoaded) {
                            return Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20.r),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.08),
                                    blurRadius: 20,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Padding(
                                padding: EdgeInsets.all(20.w),
                                child: buildTabContent(index: selectedIndex, shop: widget.shop, listServices: state.listServices,),
                              ),
                            );
                          }
                          return const SizedBox();
                        },
                      ),

                      SizedBox(height: 20.h),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 48.w,
            height: 48.w,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Icon(
              icon,
              color: color,
              size: 24.sp,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            label,
            style: TextStyle(
              fontSize: 12.sp,
              color: const Color(0xFF374151),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Container(
      height: 200.h,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0XFF363062)),
            ),
            SizedBox(height: 16.h),
            Text(
              'Đang tải dữ liệu...',
              style: TextStyle(
                fontSize: 14.sp,
                color: const Color(0xFF6B7280),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Container(
      height: 200.h,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 48.sp,
              color: const Color(0xFFEF4444),
            ),
            SizedBox(height: 16.h),
            Text(
              'Có lỗi xảy ra',
              style: TextStyle(
                fontSize: 16.sp,
                color: const Color(0xFF111827),
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              message,
              style: TextStyle(
                fontSize: 14.sp,
                color: const Color(0xFF6B7280),
              ),
              textAlign: TextAlign.center,
            ),
          ],
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
      return now.isAfter(openTime) && now.isBefore(closeTime);
    } else {
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

  Future<void> openPhoneDialer(String phone) async {
    final sanitized = phone.replaceAll(RegExp(r'[^\d\+]'), '');

    if (sanitized.isEmpty) return;

    final uri = Uri(scheme: 'tel', path: sanitized);

    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      print('openPhoneDialer error: $e');
    }
  }
}