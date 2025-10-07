import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:testrunflutter/data/models/BookingWithUser.dart';
import 'package:testrunflutter/data/models/ShopModel.dart';
import 'package:testrunflutter/features/Pages/home/cubit/Schedules/SchedulesCubit.dart';
import 'package:testrunflutter/features/Pages/home/cubit/Schedules/SchedulesState.dart';
import 'package:collection/collection.dart';

class TabSchedule extends StatefulWidget {
  final ShopModel shop;

  const TabSchedule({super.key, required this.shop});

  @override
  State<TabSchedule> createState() => _TabScheduleState();
}

class _TabScheduleState extends State<TabSchedule> {
  DateTime selectedDate = DateTime.now();

  List<String> times = [];

  void _getTime() {
    final listTime = generateTimeSlots(
      widget.shop.openHour,
      widget.shop.closeHour,
    );
    if (listTime.isNotEmpty) {
      times = listTime;
    }
  }

  @override
  void initState() {
    super.initState();
    _getTime();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SchedulesCubit>().loadBookingByDate(selectedDate);
    });
  }

  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat('dd MMM yyyy', 'vi').format(selectedDate);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Date selection header
        Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: const Color(0XFF363062).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(
                  Icons.calendar_today_outlined,
                  color: const Color(0XFF363062),
                  size: 18.sp,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Lịch trình',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF111827),
                      ),
                    ),
                    Text(
                      formattedDate,
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: const Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0XFF363062),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: TextButton.icon(
                  onPressed: () => _selectDate(context),
                  icon: Icon(
                    Icons.edit_calendar_rounded,
                    color: Colors.white,
                    size: 16.sp,
                  ),
                  label: Text(
                    'Chọn ngày',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 8.h,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        SizedBox(height: 20.h),

        // Timeline section
        Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Timeline hôm nay",
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF111827),
                ),
              ),
              SizedBox(height: 16.h),

              // Timeline items
              BlocBuilder<SchedulesCubit,SchedulesState>(
                  builder: (context,state){
                    if(state is SchedulesLoading){
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }else if( state is SchedulesError){
                      return Text('xu ly sau');
                    }else if(state is SchedulesLoaded){
                      List<BookingWithUser> listBooking = state.listBooking;
                      return Column(
                        children: times.map((time) {
                          final todayStr = DateFormat('dd/MM/yyyy',).format(selectedDate);
                          final appointment = listBooking.firstWhereOrNull(
                                (item) => item.booking.bookingDateModel.time == time && item.booking.bookingDateModel.date == todayStr,
                          );
                          return _buildTimelineItem(time, appointment);
                        }).toList(),
                      );
                    }
                    return SizedBox();
                  }
              )
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTimelineItem(String time, BookingWithUser? appointment) {
    final hasAppointment = appointment != null;

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Time column
          SizedBox(
            width: 80.w,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  time,
                  style: TextStyle(
                    color: hasAppointment
                        ? const Color(0xFF111827)
                        : const Color(0xFF9CA3AF),
                    fontSize: 13.sp,
                    fontWeight: hasAppointment
                        ? FontWeight.w600
                        : FontWeight.normal,
                  ),
                ),
                if (hasAppointment)
                  Container(
                    margin: EdgeInsets.only(top: 4.h),
                    width: 4.w,
                    height: 4.w,
                    decoration: BoxDecoration(
                      color: _getStatusColor(appointment.booking.status),
                      borderRadius: BorderRadius.circular(2.r),
                    ),
                  ),
              ],
            ),
          ),

          SizedBox(width: 16.w),

          // Appointment card or empty slot
          Expanded(
            child: hasAppointment
                ? _buildAppointmentCard(appointment)
                : _buildEmptySlot(),
          ),
        ],
      ),
    );
  }

  Widget _buildAppointmentCard(BookingWithUser appointment) {
    final statusColor = _getStatusColor(appointment.booking.status);

    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: statusColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(color: statusColor.withOpacity(0.3), width: 2),
            ),
            child: CircleAvatar(
              radius: 18.r,
              backgroundImage: appointment.userModel.avatarUrl == '0'
                  ? AssetImage('assets/images/avtMacDinh.jpg')
                  : CachedNetworkImageProvider(appointment.userModel.avatarUrl),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  appointment.userModel.name,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF111827),
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  appointment.booking.servicesSelected.services.map((service) => service.name ).join(', '),
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: const Color(0xFF6B7280),
                  ),
                ),
                SizedBox(height: 4.h),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Text(
                    _getStatusText(appointment.booking.status),
                    style: TextStyle(
                      fontSize: 10.sp,
                      color: statusColor,
                      fontWeight: FontWeight.w600,
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

  Widget _buildEmptySlot() {
    return Container(
      height: 60.h,
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: Colors.grey.shade200,
          style: BorderStyle.solid,
        ),
      ),
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.access_time_rounded,
              color: Colors.grey.shade400,
              size: 16.sp,
            ),
            SizedBox(width: 8.w),
            Text(
              'Trống',
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 13.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Chờ duyệt':
        return const Color(0xFFF59E0B); // cam
      case 'Hoàn thành1':
        return const Color(0xFF10B981); // xanh lá
      case 'Hoàn thành2':
        return const Color(0xFF10B981);
      case 'Đã duyệt':
        return const Color(0xFF3B82F6); // xanh dương
      case 'Đã đến':
        return const Color(0xFF6366F1); // tím
      case 'Rủi ro':
        return const Color(0xFFEF4444); // đỏ
      case 'Đã hủy':
        return const Color(0xFF9CA3AF); // xám
      default:
        return const Color(0xFF6B7280); // mặc định: xám đậm
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'Chờ duyệt':
        return 'Chờ duyệt';
      case 'Hoàn thành1':
        return 'Hoàn thành';
      case 'Hoàn thành2':
        return 'Hoàn thành';
      case 'Đã duyệt':
        return 'Đã duyệt';
      case 'Đã đến':
        return 'Đã đến';
      case 'Rủi ro':
        return 'Rủi ro';
      case 'Đã hủy':
        return 'Đã hủy';
      default:
        return status;
    }
  }

  // Date picker method
  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: const Color(0XFF363062),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: const Color(0xFF111827),
            ),
            dialogBackgroundColor: Colors.white,
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
      context.read<SchedulesCubit>().loadBookingByDate(selectedDate);
    }
  }

  List<String> generateTimeSlots(String openHour, String closeHour) {
    // Tách giờ và phút
    final openParts = openHour.split(":");
    final closeParts = closeHour.split(":");

    // Tạo DateTime cho giờ mở và đóng
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

    // Lặp tới khi currentTime < closeTime
    while (currentTime.isBefore(closeTime) ||
        currentTime.isAtSameMomentAs(closeTime)) {
      // Format HH:mm
      final hour = currentTime.hour.toString().padLeft(2, '0');
      final minute = currentTime.minute.toString().padLeft(2, '0');
      timeSlots.add("$hour:$minute");

      // Tăng 30 phút
      currentTime = currentTime.add(Duration(minutes: 30));
    }

    return timeSlots;
  }
}