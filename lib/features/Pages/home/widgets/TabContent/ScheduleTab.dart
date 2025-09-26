import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

class TabSchedule extends StatefulWidget {
  const TabSchedule({super.key});

  @override
  State<TabSchedule> createState() => _TabScheduleState();
}

class _TabScheduleState extends State<TabSchedule> {
  DateTime selectedDate = DateTime.now();

  final List<Map<String, dynamic>> scheduleData = [
    {
      'date': '2025-09-26',
      'time': '08.30 am',
      'name': 'Alam Carl',
      'service': 'Basic haircut',
      'avatar': 'assets/images/bom.jpg',
      'status': 'confirmed'
    },
    {
      'date': '2025-09-26',
      'time': '09.00 am',
      'name': 'Sergio Wirl',
      'service': 'Hair coloring',
      'avatar': 'assets/images/bom.jpg',
      'status': 'pending'
    },
    {
      'date': '2025-09-27',
      'time': '10.00 am',
      'name': 'John Smith',
      'service': 'Basic haircut',
      'avatar': 'assets/images/bom.jpg',
      'status': 'confirmed'
    },
  ];

  final List<String> times = [
    '08.00 am',
    '08.30 am',
    '09.00 am',
    '09.30 am',
    '10.00 am',
    '10.30 am',
    '11.00 am',
    '11.30 am',
  ];

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
                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
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
              Column(
                children: times.map((time) {
                  final todayStr = DateFormat('yyyy-MM-dd').format(selectedDate);
                  final appointment = scheduleData.firstWhere(
                        (item) => item['time'] == time && item['date'] == todayStr,
                    orElse: () => {},
                  );

                  return _buildTimelineItem(time, appointment);
                }).toList(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTimelineItem(String time, Map<String, dynamic> appointment) {
    final hasAppointment = appointment.isNotEmpty;

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
                    fontWeight: hasAppointment ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
                if (hasAppointment)
                  Container(
                    margin: EdgeInsets.only(top: 4.h),
                    width: 4.w,
                    height: 4.w,
                    decoration: BoxDecoration(
                      color: _getStatusColor(appointment['status']),
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

  Widget _buildAppointmentCard(Map<String, dynamic> appointment) {
    final statusColor = _getStatusColor(appointment['status']);

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
              backgroundImage: AssetImage(appointment['avatar']),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  appointment['name'],
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF111827),
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  appointment['service'],
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
                    _getStatusText(appointment['status']),
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
        border: Border.all(color: Colors.grey.shade200, style: BorderStyle.solid),
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
      case 'confirmed':
        return const Color(0xFF10B981);
      case 'pending':
        return const Color(0xFFF59E0B);
      case 'cancelled':
        return const Color(0xFFEF4444);
      default:
        return const Color(0xFF6B7280);
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'confirmed':
        return 'Đã xác nhận';
      case 'pending':
        return 'Chờ xác nhận';
      case 'cancelled':
        return 'Đã hủy';
      default:
        return 'Không xác định';
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
    }
  }
}