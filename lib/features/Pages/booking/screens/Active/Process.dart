import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:testrunflutter/core/helper/aleart.dart';
import 'package:testrunflutter/core/widgets/TextBasic.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:testrunflutter/data/firebase/FireStore.dart';
import 'package:testrunflutter/data/models/BookingModel/BookingWithShop.dart';
import 'package:testrunflutter/data/models/ShopModel.dart';
import 'package:testrunflutter/data/repositories/services/FCMService.dart';
import 'package:url_launcher/url_launcher.dart';

class Process extends StatefulWidget {
  final BookingWithShop bookingWithShop;
  const Process({super.key, required this.bookingWithShop});

  @override
  State<Process> createState() => _ProcessState();
}

class _ProcessState extends State<Process> with SingleTickerProviderStateMixin {
  bool check = false;
  int riskStep = 0;
  Timer? _timer;
  FireStoreDatabase dtb = FireStoreDatabase();
  int currentStep = 1;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimation();
    _loadData();
    _startTimer();
  }

  void _setupAnimation() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 20), (timer) {
      if (mounted) {
        setState(() {
          check = canCheckIn();
        });
      }
    });
  }

  void _loadData() {
    if (widget.bookingWithShop.booking.status == 'Chờ duyệt') {
      currentStep = 0;
    } else if (widget.bookingWithShop.booking.status == 'Đã duyệt') {
      currentStep = 1;
    } else if (widget.bookingWithShop.booking.status == 'Đã đến') {
      currentStep = 2;
    } else if (widget.bookingWithShop.booking.status == 'Hoàn thành1' ||
        widget.bookingWithShop.booking.status == 'Hoàn thành2') {
      currentStep = 3;
    } else if (widget.bookingWithShop.booking.status == 'Rủi ro') {
      currentStep = 1;
      riskStep = 4;
    }
    check = canCheckIn();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Container(
          margin: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color: const Color(0XFF363062).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(
              Icons.arrow_back_ios_rounded,
              color: const Color(0XFF363062),
              size: 18.sp,
            ),
          ),
        ),
        title: Text(
          'Theo dõi lịch hẹn',
          style: TextStyle(
            color: const Color(0XFF363062),
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {});
        },
        color: const Color(0XFF363062),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.all(20.w),
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              children: [
                // Progress Tracker Section
                _buildProgressTracker(),

                SizedBox(height: 24.h),

                // Shop Info Card
                _buildShopInfoCard(),

                SizedBox(height: 20.h),

                // Booking Details Section
                _buildBookingDetails(),

                SizedBox(height: 24.h),

                // Action Button
                _buildActionButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProgressTracker() {
    List<Map<String, dynamic>> stepData = [
      {
        'title': 'Đã đặt',
        'subtitle': 'Lịch hẹn được tạo',
        'icon': Icons.event_note_rounded,
        'color': const Color(0XFF363062),
      },
      {
        'title': 'Đã xác nhận',
        'subtitle': 'Vui lòng chờ đến giờ để CheckIn',
        'icon': Icons.pending_actions_rounded,
        'color': Colors.orange,
      },
      {
        'title': 'Đang thực hiện',
        'subtitle': 'Đã đến shop',
        'icon': Icons.content_cut_rounded,
        'color': Colors.blue,
      },
      {
        'title': 'Hoàn thành',
        'subtitle': 'Dịch vụ đã xong',
        'icon': Icons.check_circle_rounded,
        'color': Colors.green,
      },
    ];

    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(10.w),
                decoration: BoxDecoration(
                  color: const Color(0XFF363062).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  Icons.timeline_rounded,
                  color: const Color(0XFF363062),
                  size: 20.sp,
                ),
              ),
              SizedBox(width: 12.w),
              Text(
                'Tiến trình lịch hẹn',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF111827),
                ),
              ),
            ],
          ),

          SizedBox(height: 24.h),

          // Progress Steps
          Column(
            children: List.generate(stepData.length, (index) {
              final step = stepData[index];
              final isActive = index <= currentStep;
              final isRisk = riskStep == 4 && index == 1;

              return Column(
                children: [
                  Row(
                    children: [
                      // Step Circle
                      Container(
                        width: 50.w,
                        height: 50.w,
                        decoration: BoxDecoration(
                          color: isRisk
                              ? Colors.red
                              : isActive
                              ? step['color']
                              : Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(25.r),
                          boxShadow: isActive
                              ? [
                            BoxShadow(
                              color: (isRisk ? Colors.red : step['color'])
                                  .withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ]
                              : null,
                        ),
                        child: Icon(
                          isRisk ? Icons.warning_rounded : step['icon'],
                          color: Colors.white,
                          size: 24.sp,
                        ),
                      ),

                      SizedBox(width: 16.w),

                      // Step Content
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isRisk && index == 1 ? 'Rủi ro' : step['title'],
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.bold,
                                color: isActive
                                    ? const Color(0xFF111827)
                                    : Colors.grey.shade500,
                              ),
                            ),
                            SizedBox(height: 2.h),
                            Text(
                              isRisk && index == 1
                                  ? 'Cần liên hệ shop để xử lý'
                                  : step['subtitle'],
                              style: TextStyle(
                                fontSize: 11.sp,
                                color: isActive
                                    ? const Color(0xFF6B7280)
                                    : Colors.grey.shade400,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Status Badge
                      if (isActive || isRisk)
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8.w,
                            vertical: 4.h,
                          ),
                          decoration: BoxDecoration(
                            color: (isRisk ? Colors.red : step['color'])
                                .withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Text(
                            isRisk ? 'Lỗi' : 'Hoàn thành',
                            style: TextStyle(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w600,
                              color: isRisk ? Colors.red : step['color'],
                            ),
                          ),
                        ),
                    ],
                  ),

                  // Connection Line
                  if (index < stepData.length - 1)
                    Container(
                      margin: EdgeInsets.only(left: 25.w, top: 8.h, bottom: 8.h),
                      width: 2.w,
                      height: 24.h,
                      color: index < currentStep
                          ? const Color(0XFF363062)
                          : Colors.grey.shade300,
                    ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildShopInfoCard() {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(
                    color: const Color(0XFF363062).withOpacity(0.2),
                    width: 2,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14.r),
                  child: CachedNetworkImage(
                    imageUrl: widget.bookingWithShop.shop.shopAvatarImageUrl,
                    width: 80.w,
                    height: 80.w,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.bookingWithShop.shop.shopName,
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF111827),
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_rounded,
                          color: const Color(0xFF6B7280),
                          size: 16.sp,
                        ),
                        SizedBox(width: 4.w),
                        Expanded(
                          child: Text(
                            widget.bookingWithShop.shop.location.address,
                            style: TextStyle(
                              fontSize: 13.sp,
                              color: const Color(0xFF6B7280),
                              fontWeight: FontWeight.w500,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4.h),
                    Row(
                      children: [
                        Icon(
                          Icons.star_rounded,
                          color: Colors.amber.shade400,
                          size: 16.sp,
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          '5.0 (24 reviews)',
                          style: TextStyle(
                            fontSize: 13.sp,
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

          SizedBox(height: 20.h),

          // Divider
          Container(
            height: 1.h,
            color: Colors.grey.shade200,
          ),

          SizedBox(height: 16.h),

          // Action Buttons Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildActionIcon(
                icon: Icons.map_outlined,
                label: 'Bản đồ',
                color: Colors.blue.shade600,
                onTap: () => openMapWithAddress(
                  address: widget.bookingWithShop.shop.location.address,
                  wardName: widget.bookingWithShop.shop.location.wardName,
                  districtName: widget.bookingWithShop.shop.location.districtName,
                  provinceName: widget.bookingWithShop.shop.location.provinceName,
                ),
              ),
              _buildActionIcon(
                icon: Icons.phone_outlined,
                label: 'Gọi điện',
                color: Colors.green.shade600,
                onTap: () => _makePhoneCall(widget.bookingWithShop.shop.phone),
              ),
              _buildActionIcon(
                icon: Icons.chat_bubble_outline_rounded,
                label: 'Chat',
                color: Colors.purple.shade600,
                onTap: () {},
              ),
              _buildActionIcon(
                icon: Icons.cancel_outlined,
                label: 'Hủy lịch',
                color: Colors.red.shade600,
                onTap: () async {
                  await FCMService.sendFCMNotification(
                    title: 'Chào mừng',
                    body: 'Test notification',
                    fcmToken: 'fuZyOJztTdigyKiHt_W38d:APA91bE83Rh9ZpeRLoP8daZOF03cqNLhBkYtW6oJ9k_oLQ0oNFnj5PvXaTObuK99Vnj1YrvsZIX1TMDzHvul44V6afFVgbxx3LVL-EgIKOD08sthP01lprE',
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionIcon({
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
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildBookingDetails() {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Date & Time Section
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: const Color(0XFF363062).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(
                  Icons.schedule_rounded,
                  color: const Color(0XFF363062),
                  size: 18.sp,
                ),
              ),
              SizedBox(width: 12.w),
              Text(
                'Thời gian đặt lịch',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF111827),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: const Color(0XFF363062).withOpacity(0.05),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: const Color(0XFF363062).withOpacity(0.1),
              ),
            ),
            child: Text(
              '${widget.bookingWithShop.booking.bookingDateModel.time} - ${widget.bookingWithShop.booking.bookingDateModel.weekdayName}, ${widget.bookingWithShop.booking.bookingDateModel.date}',
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0XFF363062),
              ),
            ),
          ),

          SizedBox(height: 24.h),

          // Services Section
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(
                  Icons.design_services_rounded,
                  color: Colors.blue.shade600,
                  size: 18.sp,
                ),
              ),
              SizedBox(width: 12.w),
              Text(
                'Dịch vụ đã chọn',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF111827),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          ...widget.bookingWithShop.booking.servicesSelected.services
              .map((service) => Container(
            margin: EdgeInsets.only(bottom: 12.h),
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.r),
                    border: Border.all(
                      color: Colors.blue.withOpacity(0.2),
                      width: 2,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8.r),
                    child: CachedNetworkImage(
                      imageUrl: service.avatarUrl,
                      width: 50.w,
                      height: 50.w,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        service.name,
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF111827),
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        service.note,
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: const Color(0xFF6B7280),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ))
              .toList(),
        ],
      ),
    );
  }

  Widget _buildActionButton() {
    String buttonText = _getButtonText();
    Color buttonColor = _getButtonColor();
    bool isEnabled = _isButtonEnabled();

    return Container(
      width: double.infinity,
      height: 56.h,
      decoration: BoxDecoration(
        gradient: isEnabled
            ? LinearGradient(
          colors: [buttonColor, buttonColor.withOpacity(0.8)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        )
            : null,
        color: isEnabled ? null : Colors.grey.shade300,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: isEnabled
            ? [
          BoxShadow(
            color: buttonColor.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ]
            : null,
      ),
      child: ElevatedButton(
        onPressed: isEnabled ? _handleButtonPress : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _getButtonIcon(),
              color: isEnabled ? Colors.white : Colors.grey.shade500,
              size: 20.sp,
            ),
            SizedBox(width: 8.w),
            Text(
              buttonText,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: isEnabled ? Colors.white : Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getButtonText() {
    if (currentStep == 0) return 'Vui lòng chờ quán xác nhận';
    if (currentStep == 2) return 'Đã đến quán';
    if (currentStep == 3) return 'Đã hoàn thành';
    if (currentStep == 1 && riskStep == 4) return 'Đơn rủi ro - Liên hệ quán';
    if (currentStep == 1 && !check) return 'Chờ đến giờ để check-in';
    return 'Tôi đã đến điểm cắt';
  }

  Color _getButtonColor() {
    if (currentStep == 3) return Colors.green;
    if (currentStep == 1 && riskStep == 4) return Colors.red;
    return const Color(0XFF363062);
  }

  IconData _getButtonIcon() {
    if (currentStep == 0) return Icons.pending_actions_rounded;
    if (currentStep == 2) return Icons.location_on_rounded;
    if (currentStep == 3) return Icons.check_circle_rounded;
    if (currentStep == 1 && riskStep == 4) return Icons.warning_rounded;
    if (currentStep == 1 && !check) return Icons.access_time_rounded;
    return Icons.location_on_rounded;
  }

  bool _isButtonEnabled() {
    return !(currentStep == 0 ||
        currentStep == 2 ||
        (currentStep == 1 && riskStep == 4) ||
        (currentStep == 1 && !check));
  }

  Future<void> _handleButtonPress() async {
    if (currentStep == 3) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    if (await checkLocation(widget.bookingWithShop.shop)) {
      if (await dtb.updateStatus(widget.bookingWithShop.booking)) {
        if (mounted) {
          Navigator.pop(context);
          setState(() {
            currentStep = 2;
          });
        }
        dtb.sendNotification(
          object: 'Shops',
          id: widget.bookingWithShop.booking.idShop,
          title: 'Khách đã đến!',
          body: 'Khách đã đến rồi, nhanh ra đón khách nào!',
        );
      } else {
        if (mounted) {
          Navigator.pop(context);
          displayMessageToUser(
            context,
            'Có lỗi trong lúc cập nhật trạng thái. Vui lòng kiểm tra kết nối mạng',
            isSuccess: false,
            onOk: () {},
          );
        }
      }
    } else {
      if (mounted) {
        Navigator.pop(context);
        displayMessageToUser(
          context,
          'Bạn chưa đến đúng vị trí. Vui lòng di chuyển đến shop để check-in',
          isSuccess: false,
          onOk: () {},
        );
      }
    }
  }

  // Keep existing methods unchanged
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

  bool canCheckIn() {
    try {
      final now = DateTime.now();
      final dateParts = widget.bookingWithShop.booking.bookingDateModel.date.split("/");
      if (dateParts.length != 3) return false;

      final day = int.parse(dateParts[0]);
      final month = int.parse(dateParts[1]);
      final year = int.parse(dateParts[2]);

      final timeParts = widget.bookingWithShop.booking.bookingDateModel.time.split(":");
      if (timeParts.length != 2) return false;

      final hour = int.parse(timeParts[0]);
      final minute = int.parse(timeParts[1]);

      final bookingDateTime = DateTime(year, month, day, hour, minute);
      final startAllow = bookingDateTime.subtract(const Duration(minutes: 10));
      final endAllow = bookingDateTime.add(const Duration(minutes: 10));

      return (now.isAfter(startAllow) || now.isAtSameMomentAs(startAllow)) &&
          (now.isBefore(endAllow) || now.isAtSameMomentAs(endAllow));
    } catch (e) {
      return false;
    }
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri uri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      throw 'Không thể gọi đến $phoneNumber';
    }
  }

  Future<bool> checkLocation(ShopModel shop) async{
    try{
      double latShop = shop.location.latitude;
      double lonShop = shop.location.longitude;
      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          displayMessageToUser(context, 'Vui lòng cấp quyền vị trí để sử dụng ứng dụng',isSuccess: false,onOk: (){Navigator.pop(context);});
          return false;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        displayMessageToUser(context, 'Quyền vị trí bị từ chối vĩnh viễn. Vui lòng vào cài đặt để bật',isSuccess: false,onOk: (){Navigator.pop(context);});
        return false;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final latPeople = position.latitude;
      final lonPeople = position.longitude;
      double distanceInMeters = Geolocator.distanceBetween(latPeople, lonPeople, latShop, lonShop);
      double distanceKm = distanceInMeters / 1000;
      if(distanceKm < 1){
        print('ok gan nhau');
        return true;
      }else{
        print('ok xa nhau');
        return false;
      }
    }catch(e){
      print(e);
      return false;
    }
  }

}
