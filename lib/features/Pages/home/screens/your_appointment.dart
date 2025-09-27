import 'dart:ui';
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

class _YourAppointmentState extends State<YourAppointment> with SingleTickerProviderStateMixin {
  FireStoreDatabase dtb = FireStoreDatabase();
  TextEditingController couponController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool isDisplay = false;
  late bool checkCoupon;
  double total = 0;
  List<String> coupon = ['abcz', 'bomnguyen1234', 'dinhlan12345'];
  late BookingDateModel bookingDateModel;
  late ServicesSelected servicesSelected;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _loadData();
    _setupAnimations();
    _focusNode.addListener(() {
      setState(() {});
    });
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic));

    _animationController.forward();
  }

  void _loadData() {
    bookingDateModel = widget.tempData['bookingDateModel'] as BookingDateModel;
    servicesSelected = widget.tempData['servicesSelected'] as ServicesSelected;
  }

  @override
  void dispose() {
    _animationController.dispose();
    _focusNode.dispose();
    couponController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF363062),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Container(
          margin: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12.r),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Icon(
                  Icons.arrow_back_ios_rounded,
                  color: Colors.white,
                  size: 18.sp,
                ),
              ),
            ),
          ),
        ),
        title: Text(
          'Thanh Toán',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // Enhanced Background
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  const Color(0xFF363062),
                  const Color(0xFF4A4A7A),
                  const Color(0xFF363062).withOpacity(0.8),
                ],
              ),
            ),
          ),

          // Background pattern
          Positioned.fill(
            child: Opacity(
              opacity: 0.1,
              child: Image.asset(
                'assets/icons/setIcon.png',
                fit: BoxFit.cover,
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                SizedBox(height: 20.h),

                // Shop Info Card with Animation
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Container(
                      margin: EdgeInsets.symmetric(horizontal: 20.w),
                      padding: EdgeInsets.all(20.w),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.white.withOpacity(0.15),
                            Colors.white.withOpacity(0.05),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20.r),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.2),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16.r),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.3),
                                width: 2,
                              ),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(14.r),
                              child: CachedNetworkImage(
                                imageUrl: widget.shop.shopAvatarImageUrl,
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
                                  widget.shop.shopName,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 6.h),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.location_on_rounded,
                                      color: Colors.white.withOpacity(0.8),
                                      size: 16.sp,
                                    ),
                                    SizedBox(width: 4.w),
                                    Expanded(
                                      child: Text(
                                        widget.shop.location.address,
                                        style: TextStyle(
                                          color: Colors.white.withOpacity(0.8),
                                          fontSize: 13.sp,
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
                                        color: Colors.white.withOpacity(0.8),
                                        fontSize: 13.sp,
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
                    ),
                  ),
                ),

                SizedBox(height: 24.h),

                // Content Container
                Expanded(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 600),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
                      child: SingleChildScrollView(
                        padding: EdgeInsets.all(24.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Drag indicator
                            Center(
                              child: Container(
                                width: 40.w,
                                height: 4.h,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade300,
                                  borderRadius: BorderRadius.circular(2.r),
                                ),
                              ),
                            ),

                            SizedBox(height: 24.h),

                            // Date & Time Section
                            _buildSectionHeader(
                              icon: Icons.schedule_rounded,
                              title: 'Ngày & Thời gian',
                              iconColor: const Color(0xFF363062),
                            ),
                            SizedBox(height: 12.h),
                            Container(
                              padding: EdgeInsets.all(16.w),
                              decoration: BoxDecoration(
                                color: const Color(0xFF363062).withOpacity(0.05),
                                borderRadius: BorderRadius.circular(16.r),
                                border: Border.all(
                                  color: const Color(0xFF363062).withOpacity(0.1),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(10.w),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF363062).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(10.r),
                                    ),
                                    child: Icon(
                                      Icons.access_time_rounded,
                                      color: const Color(0xFF363062),
                                      size: 20.sp,
                                    ),
                                  ),
                                  SizedBox(width: 12.w),
                                  Expanded(
                                    child: Text(
                                      '${bookingDateModel.time} - ${bookingDateModel.weekdayName}, ${bookingDateModel.date}',
                                      style: TextStyle(
                                        color: const Color(0xFF363062),
                                        fontSize: 15.sp,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            SizedBox(height: 24.h),

                            // Services Section
                            _buildSectionHeader(
                              icon: Icons.design_services_rounded,
                              title: 'Dịch vụ đã chọn',
                              iconColor: Colors.blue.shade600,
                            ),
                            SizedBox(height: 16.h),
                            ...servicesSelected.services.map((service) =>
                                _buildServiceCard(service)
                            ).toList(),

                            SizedBox(height: 24.h),

                            // Coupon Section
                            _buildSectionHeader(
                              icon: Icons.local_offer_rounded,
                              title: 'Mã giảm giá',
                              iconColor: Colors.orange.shade600,
                            ),
                            SizedBox(height: 16.h),
                            _buildCouponSection(),

                            SizedBox(height: 24.h),

                            // Payment Summary Section
                            _buildSectionHeader(
                              icon: Icons.receipt_long_rounded,
                              title: 'Tóm tắt thanh toán',
                              iconColor: Colors.green.shade600,
                            ),
                            SizedBox(height: 16.h),
                            _buildPaymentSummary(),

                            SizedBox(height: 32.h),

                            // Payment Button
                            _buildPaymentButton(),

                            SizedBox(height: 16.h),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader({
    required IconData icon,
    required String title,
    required Color iconColor,
  }) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Icon(
            icon,
            color: iconColor,
            size: 20.sp,
          ),
        ),
        SizedBox(width: 12.w),
        Text(
          title,
          style: TextStyle(
            color: const Color(0xFF111827),
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildServiceCard(service) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(
                color: const Color(0xFF363062).withOpacity(0.2),
                width: 2,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14.r),
              child: CachedNetworkImage(
                imageUrl: service.avatarUrl,
                width: 60.w,
                height: 60.w,
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
                  service.name,
                  style: TextStyle(
                    color: const Color(0xFF111827),
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 6.h),
                Text(
                  service.note,
                  style: TextStyle(
                    color: const Color(0xFF6B7280),
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  CupertinoIcons.money_dollar,
                  color: Colors.green.shade600,
                  size: 16.sp,
                ),
                SizedBox(width: 4.w),
                Text(
                  FormatPrice.formatPrice(service.price),
                  style: TextStyle(
                    color: Colors.green.shade700,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCouponSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Row(
            children: [
              Expanded(
                flex: 4,
                child: Container(
                  height: 56.h,
                  child: TextField(
                    controller: couponController,
                    focusNode: _focusNode,
                    style: TextStyle(
                      color: const Color(0xFF363062),
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w500,
                    ),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.grey.shade50,
                      hintText: 'Nhập mã giảm giá',
                      hintStyle: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 14.sp,
                      ),
                      prefixIcon: Icon(
                        Icons.local_offer_rounded,
                        color: Colors.orange.shade600,
                        size: 20.sp,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.horizontal(
                          left: Radius.circular(16.r),
                        ),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.horizontal(
                          left: Radius.circular(16.r),
                        ),
                        borderSide: BorderSide(
                          color: const Color(0xFF363062),
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Container(
                height: 56.h,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.orange.shade400, Colors.orange.shade600],
                  ),
                  borderRadius: BorderRadius.horizontal(
                    right: Radius.circular(16.r),
                  ),
                ),
                child: ElevatedButton(
                  onPressed: _applyCoupon,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.horizontal(
                        right: Radius.circular(16.r),
                      ),
                    ),
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: Text(
                      'Áp dụng',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (isDisplay) ...[
          SizedBox(height: 8.h),
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: checkCoupon
                  ? Colors.green.withOpacity(0.1)
                  : Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(
                color: checkCoupon
                    ? Colors.green.withOpacity(0.3)
                    : Colors.red.withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  checkCoupon ? Icons.check_circle_rounded : Icons.error_rounded,
                  color: checkCoupon ? Colors.green : Colors.red,
                  size: 16.sp,
                ),
                SizedBox(width: 8.w),
                Text(
                  checkCoupon ? 'Mã giảm giá đã được áp dụng' : 'Mã giảm giá không hợp lệ',
                  style: TextStyle(
                    color: checkCoupon ? Colors.green.shade700 : Colors.red.shade700,
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildPaymentSummary() {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          ...servicesSelected.services.map((service) =>
              Padding(
                padding: EdgeInsets.symmetric(vertical: 6.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        service.name,
                        style: TextStyle(
                          color: const Color(0xFF374151),
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Text(
                      FormatPrice.formatPrice(service.price),
                      style: TextStyle(
                        color: const Color(0xFF111827),
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              )
          ).toList(),

          Padding(
            padding: EdgeInsets.symmetric(vertical: 12.h),
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Dash(
                  direction: Axis.horizontal,
                  length: constraints.maxWidth,
                  dashLength: 8,
                  dashColor: Colors.grey.shade400,
                );
              },
            ),
          ),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Tổng thanh toán',
                style: TextStyle(
                  color: const Color(0xFF111827),
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.green.shade400, Colors.green.shade600],
                  ),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Text(
                  FormatPrice.formatPrice(servicesSelected.total),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentButton() {
    return Container(
      width: double.infinity,
      height: 56.h,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [const Color(0xFF363062), const Color(0xFF4A4A7A)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF363062).withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _onContinue,
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
              Icons.payment_rounded,
              color: Colors.white,
              size: 24.sp,
            ),
            SizedBox(width: 12.w),
            Text(
              'Xác nhận thanh toán',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _applyCoupon() {
    bool isValidCoupon = coupon.contains(couponController.text);

    if (isValidCoupon) {
      displayMessageToUser(
        context,
        'Mã giảm giá đã được áp dụng thành công',
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

  Future<void> _onContinue() async {
    try {
      if (await dtb.checkAmount(widget.tempData['idUser'], servicesSelected.total)) {
        if (await dtb.booking(
            widget.tempData['idUser'],
            widget.tempData['idShop'],
            servicesSelected,
            bookingDateModel,
            widget.tempData['status']
        )) {
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
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                const begin = Offset(1.0, 0.0);
                const end = Offset.zero;
                final tween = Tween(begin: begin, end: end);
                final curvedAnimation = CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeOutCubic,
                );
                return SlideTransition(
                  position: tween.animate(curvedAnimation),
                  child: child,
                );
              },
              transitionDuration: const Duration(milliseconds: 600),
            ),
          );

          dtb.sendNotification(
              object: 'Shops',
              id: widget.shop.id,
              title: 'Bạn có lịch hẹn mới!',
              body: 'Bạn có lịch hẹn mới, nhớ kiểm tra và xác nhận nhé'
          );
        } else {
          displayMessageToUser(
            context,
            'Có lỗi xảy ra trong quá trình đặt lịch. Vui lòng thử lại sau!',
            isSuccess: false,
            onOk: () {},
          );
        }
      } else {
        displayMessageToUser(
          context,
          'Tài khoản không đủ số dư. Vui lòng nạp thêm tiền để tiếp tục!',
          isSuccess: false,
          onOk: () {},
        );
      }
    } catch (e) {
      print('Error in _onContinue: $e');
      displayMessageToUser(
        context,
        'Đã xảy ra lỗi không mong muốn. Vui lòng thử lại sau!',
        isSuccess: false,
        onOk: () {},
      );
    }
  }
}