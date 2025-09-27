import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dash/flutter_dash.dart';
import 'package:intl/intl.dart';
import 'package:testrunflutter/core/format/FormatPrice.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:testrunflutter/data/firebase/FireStore.dart';
import 'package:testrunflutter/data/models/BookingModel/BookingDateModel.dart';
import 'package:testrunflutter/data/models/BookingModel/ServicesSelected.dart';
import 'package:testrunflutter/data/models/ServiceModel.dart';
import 'package:testrunflutter/data/models/ShopModel.dart';
import 'package:testrunflutter/data/models/UserModel.dart';
import 'package:testrunflutter/data/repositories/prefs/UserPrefsService.dart';
import 'package:testrunflutter/features/Pages/home/screens/your_appointment.dart';

class BookAppointment extends StatefulWidget {
  final ShopModel shop;
  final List<ServiceModel> listServices;
  const BookAppointment({super.key, required this.shop, required this.listServices});

  @override
  State<BookAppointment> createState() => _BookAppointmentState();
}

class _BookAppointmentState extends State<BookAppointment> {
  DateTime selectedDate = DateTime.now();
  UserModel? _userModel;
  FireStoreDatabase dtb = FireStoreDatabase();

  @override
  void initState() {
    super.initState();
    _getTime();
    _fetchUser();
  }

  List<String> timeSlots = [];
  final Set<int> selectedServiceIndices = {};
  Set<int> disabled = {};
  int? selectedIndex;

  void _getTime() {
    final listTime = generateTimeSlots(widget.shop.openHour, widget.shop.closeHour);
    if (listTime.isNotEmpty) {
      timeSlots = listTime;
    }
  }

  Future<void> _fetchUser() async {
    final userData = await UserPrefsService.getUser();
    if (userData != null) {
      setState(() {
        _userModel = userData;
      });
    } else {
      final newData = await dtb.getUserByEmail();
      setState(() {
        _userModel = newData;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0XFF363062).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(
                        Icons.arrow_back_ios_rounded,
                        color: const Color(0XFF363062),
                        size: 20.sp,
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Text(
                    'Đặt lịch hẹn',
                    style: TextStyle(
                      color: const Color(0xFF111827),
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Date Selection Section
                    Container(
                      padding: EdgeInsets.all(20.w),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20.r),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
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
                                  Icons.calendar_month_rounded,
                                  color: const Color(0XFF363062),
                                  size: 20.sp,
                                ),
                              ),
                              SizedBox(width: 12.w),
                              Text(
                                'Chọn ngày',
                                style: TextStyle(
                                  color: const Color(0xFF111827),
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 20.h),
                          _buildCalendar(),
                        ],
                      ),
                    ),

                    SizedBox(height: 20.h),

                    // Services Section
                    Container(
                      padding: EdgeInsets.all(20.w),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20.r),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: EdgeInsets.all(10.w),
                                decoration: BoxDecoration(
                                  color: Colors.blue.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                                child: Icon(
                                  Icons.design_services_rounded,
                                  color: Colors.blue.shade600,
                                  size: 20.sp,
                                ),
                              ),
                              SizedBox(width: 12.w),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Chọn dịch vụ',
                                      style: TextStyle(
                                        color: const Color(0xFF111827),
                                        fontSize: 18.sp,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    if (selectedServiceIndices.isNotEmpty)
                                      Text(
                                        '${selectedServiceIndices.length} dịch vụ đã chọn',
                                        style: TextStyle(
                                          color: const Color(0xFF6B7280),
                                          fontSize: 13.sp,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 20.h),
                          SizedBox(
                            height: 160.h,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              separatorBuilder: (_, __) => SizedBox(width: 16.w),
                              itemCount: widget.listServices.length,
                              itemBuilder: (context, index) {
                                final isSelected = selectedServiceIndices.contains(index);
                                return GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      if (isSelected) {
                                        selectedServiceIndices.remove(index);
                                      } else {
                                        selectedServiceIndices.add(index);
                                      }
                                    });
                                  },
                                  child: Container(
                                    width: 120.w,
                                    padding: EdgeInsets.all(12.w),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? const Color(0XFF363062).withOpacity(0.1)
                                          : Colors.grey.shade50,
                                      borderRadius: BorderRadius.circular(16.r),
                                      border: Border.all(
                                        color: isSelected
                                            ? const Color(0XFF363062)
                                            : Colors.grey.shade300,
                                        width: 2,
                                      ),
                                    ),
                                    child: Column(
                                      children: [
                                        Stack(
                                          children: [
                                            Container(
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(40.r),
                                                border: Border.all(
                                                  color: isSelected
                                                      ? const Color(0XFF363062)
                                                      : Colors.grey.shade300,
                                                  width: 2,
                                                ),
                                              ),
                                              child: CircleAvatar(
                                                radius: 35.r,
                                                backgroundImage: CachedNetworkImageProvider(
                                                    widget.listServices[index].avatarUrl
                                                ),
                                              ),
                                            ),
                                            if (isSelected)
                                              Positioned(
                                                top: 0,
                                                right: 0,
                                                child: Container(
                                                  padding: EdgeInsets.all(4.w),
                                                  decoration: BoxDecoration(
                                                    color: const Color(0XFF363062),
                                                    borderRadius: BorderRadius.circular(20.r),
                                                    border: Border.all(color: Colors.white, width: 2),
                                                  ),
                                                  child: Icon(
                                                    Icons.check_rounded,
                                                    color: Colors.white,
                                                    size: 12.sp,
                                                  ),
                                                ),
                                              ),
                                          ],
                                        ),
                                        SizedBox(height: 8.h),
                                        Text(
                                          widget.listServices[index].name,
                                          style: TextStyle(
                                            fontSize: 11.sp,
                                            fontWeight: FontWeight.w600,
                                            color: isSelected
                                                ? const Color(0XFF363062)
                                                : const Color(0xFF111827),
                                          ),
                                          textAlign: TextAlign.center,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        SizedBox(height: 4.h),
                                        Container(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 8.w,
                                            vertical: 4.h,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.amber.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(8.r),
                                          ),
                                          child: Text(
                                            _formatPrice(widget.listServices[index].price),
                                            style: TextStyle(
                                              fontSize: 11.sp,
                                              color: Colors.amber.shade700,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 20.h),

                    // Time Selection Section
                    Container(
                      padding: EdgeInsets.all(20.w),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20.r),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: EdgeInsets.all(10.w),
                                decoration: BoxDecoration(
                                  color: Colors.orange.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                                child: Icon(
                                  Icons.schedule_rounded,
                                  color: Colors.orange.shade600,
                                  size: 20.sp,
                                ),
                              ),
                              SizedBox(width: 12.w),
                              Text(
                                'Chọn giờ',
                                style: TextStyle(
                                  color: const Color(0xFF111827),
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 20.h),
                          Wrap(
                            spacing: 12.w,
                            runSpacing: 12.h,
                            children: List.generate(timeSlots.length, (index) {
                              final isDisabled = disabled.contains(index);
                              final isSelected = selectedIndex == index;
                              return GestureDetector(
                                onTap: isDisabled ? null : () {
                                  setState(() {
                                    selectedIndex = index;
                                  });
                                },
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 18.w,
                                    vertical: 12.h,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isDisabled
                                        ? Colors.grey.shade100
                                        : isSelected
                                        ? const Color(0XFF363062)
                                        : Colors.white,
                                    border: Border.all(
                                      color: isDisabled
                                          ? Colors.grey.shade300
                                          : isSelected
                                          ? const Color(0XFF363062)
                                          : const Color(0XFF363062).withOpacity(0.3),
                                      width: 2,
                                    ),
                                    borderRadius: BorderRadius.circular(12.r),
                                  ),
                                  child: Text(
                                    timeSlots[index],
                                    style: TextStyle(
                                      color: isDisabled
                                          ? Colors.grey.shade500
                                          : isSelected
                                          ? Colors.white
                                          : const Color(0XFF363062),
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14.sp,
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ),
                        ],
                      ),
                    ),

                    // Payment Summary Section
                    if (selectedServiceIndices.isNotEmpty  && selectedIndex != null) ...[
                      SizedBox(height: 20.h),
                      Container(
                        padding: EdgeInsets.all(20.w),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20.r),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(10.w),
                                  decoration: BoxDecoration(
                                    color: Colors.green.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12.r),
                                  ),
                                  child: Icon(
                                    Icons.receipt_long_rounded,
                                    color: Colors.green.shade600,
                                    size: 20.sp,
                                  ),
                                ),
                                SizedBox(width: 12.w),
                                Text(
                                  'Tóm tắt thanh toán',
                                  style: TextStyle(
                                    color: const Color(0xFF111827),
                                    fontSize: 18.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 16.h),
                            ...selectedServiceIndices.map((serviceIndex) {
                              return Container(
                                padding: EdgeInsets.symmetric(vertical: 8.h),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        widget.listServices[serviceIndex].name,
                                        style: TextStyle(
                                          color: const Color(0xFF111827),
                                          fontSize: 15.sp,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        Icon(
                                          CupertinoIcons.money_dollar,
                                          size: 16.sp,
                                          color: Colors.green.shade600,
                                        ),
                                        SizedBox(width: 4.w),
                                        Text(
                                          _formatPrice(widget.listServices[serviceIndex].price),
                                          style: TextStyle(
                                            color: const Color(0xFF111827),
                                            fontSize: 15.sp,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: 8.h),
                              child: LayoutBuilder(
                                builder: (context, constraints) {
                                  return Dash(
                                    direction: Axis.horizontal,
                                    length: constraints.maxWidth,
                                    dashLength: 8,
                                    dashColor: Colors.grey.shade300,
                                  );
                                },
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Tổng cộng',
                                  style: TextStyle(
                                    color: const Color(0xFF111827),
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 12.w,
                                    vertical: 6.h,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.green.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8.r),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        CupertinoIcons.money_dollar,
                                        size: 16.sp,
                                        color: Colors.green.shade600,
                                      ),
                                      SizedBox(width: 4.w),
                                      Text(
                                        FormatPrice.formatPrice(
                                          selectedServiceIndices.fold<double>(
                                            0,
                                                (sum, i) => sum + widget.listServices[i].price,
                                          ),
                                        ),
                                        style: TextStyle(
                                          color: Colors.green.shade700,
                                          fontSize: 16.sp,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],

                    SizedBox(height: 24.h),
                  ],
                ),
              ),
            ),

            // Fixed Bottom Button
            if (selectedServiceIndices.isNotEmpty && selectedIndex != null)
              Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 12,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: Container(
                  width: double.infinity,
                  height: 50.h,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12.r),
                    gradient: const LinearGradient(
                      colors: [Color(0xFF363062), Color(0xFF4A4A7A)],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF363062).withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: () {
                      String weekdayName = DateFormat('EEEE', 'vi_VN').format(selectedDate);
                      String formatted = DateFormat('dd/MM/yyyy', 'vi_VN').format(selectedDate);
                      final bookingDateModel = BookingDateModel(
                        time: timeSlots[selectedIndex!],
                        weekdayName: weekdayName,
                        date: formatted,
                      );
                      final selectedServices = selectedServiceIndices
                          .map((i) => widget.listServices[i])
                          .toList();
                      final servicesSelected = ServicesSelected(
                        services: selectedServices,
                        total: selectedServiceIndices.fold<double>(
                          0,
                              (sum, i) => sum + widget.listServices[i].price,
                        ),
                        discount: 0,
                      );
                      Navigator.push(
                        context,
                        PageRouteBuilder(
                          pageBuilder: (context, animation, secondaryAnimation) =>
                              YourAppointment(
                                shop: widget.shop,
                                tempData: {
                                  'idUser': _userModel?.id,
                                  'idShop': widget.shop.id,
                                  'servicesSelected': servicesSelected,
                                  'bookingDateModel': bookingDateModel,
                                  'status': 'Chờ duyệt'
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
                          transitionDuration: const Duration(milliseconds: 400),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.event_available_rounded,
                          color: Colors.white,
                          size: 20.sp,
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          'Xác nhận đặt lịch',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
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

  Widget _buildCalendar() {
    final firstDay = DateTime(selectedDate.year, selectedDate.month, 1);
    final lastDay = DateTime(selectedDate.year, selectedDate.month + 1, 0);
    final daysInMonth = lastDay.day;

    final startWeekday = firstDay.weekday % 7;
    final totalCells = daysInMonth + startWeekday;

    return Column(
      children: [
        Container(
          padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
          decoration: BoxDecoration(
            color: const Color(0XFF363062).withOpacity(0.1),
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: _prevMonth,
                icon: Icon(
                  Icons.arrow_back_ios_rounded,
                  color: const Color(0XFF363062),
                  size: 18.sp,
                ),
              ),
              Text(
                DateFormat.yMMMM('vi_VN').format(selectedDate),
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: const Color(0XFF363062),
                ),
              ),
              IconButton(
                onPressed: _nextMonth,
                icon: Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: const Color(0XFF363062),
                  size: 18.sp,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 16.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: ['CN', 'T2', 'T3', 'T4', 'T5', 'T6', 'T7']
              .map(
                (e) => Expanded(
              child: Center(
                child: Text(
                  e,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF6B7280),
                  ),
                ),
              ),
            ),
          )
              .toList(),
        ),
        SizedBox(height: 12.h),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: totalCells,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
          ),
          itemBuilder: (context, index) {
            if (index < startWeekday) return Container();

            int day = index - startWeekday + 1;

            return GestureDetector(
              onTap: () async {
                final newDate = DateTime(
                  selectedDate.year,
                  selectedDate.month,
                  day,
                );

                setState(() {
                  selectedDate = newDate;
                });

                String formattedDate = DateFormat('dd/MM/yyyy', 'vi_VN').format(newDate);
                final bookedTimes = await dtb.getBookedTimes(widget.shop.id, formattedDate);

                final newDisabled = <int>{};
                for (int i = 0; i < timeSlots.length; i++) {
                  if (bookedTimes.contains(timeSlots[i])) {
                    newDisabled.add(i);
                  }
                }

                setState(() {
                  disabled = newDisabled;
                  selectedIndex = null; // Reset selected time when date changes
                });
              },
              child: Container(
                margin: EdgeInsets.all(4.r),
                decoration: BoxDecoration(
                  color: selectedDate.day == day
                      ? const Color(0xFF363062)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12.r),
                  border: selectedDate.day == day
                      ? null
                      : Border.all(
                    color: Colors.grey.shade300,
                    width: 1,
                  ),
                ),
                child: Center(
                  child: Text(
                    '$day',
                    style: TextStyle(
                      color: selectedDate.day == day
                          ? Colors.white
                          : const Color(0xFF111827),
                      fontSize: 14.sp,
                      fontWeight: selectedDate.day == day
                          ? FontWeight.bold
                          : FontWeight.w500,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  void _nextMonth() {
    setState(() {
      selectedDate = DateTime(selectedDate.year, selectedDate.month + 1, 1);
    });
  }

  void _prevMonth() {
    setState(() {
      selectedDate = DateTime(selectedDate.year, selectedDate.month - 1, 1);
    });
  }

  String _formatPrice(double price) {
    return price.toInt().toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
    );
  }

  List<String> generateTimeSlots(String openHour, String closeHour) {
    final openParts = openHour.split(":");
    final closeParts = closeHour.split(":");

    final now = DateTime.now();
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

    List<String> timeSlots = [];
    DateTime currentTime = openTime;

    while (currentTime.isBefore(closeTime) || currentTime.isAtSameMomentAs(closeTime)) {
      final hour = currentTime.hour.toString().padLeft(2, '0');
      final minute = currentTime.minute.toString().padLeft(2, '0');
      timeSlots.add("$hour:$minute");

      currentTime = currentTime.add(const Duration(minutes: 30));
    }

    return timeSlots;
  }
}