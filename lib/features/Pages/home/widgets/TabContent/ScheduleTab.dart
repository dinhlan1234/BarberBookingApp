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
      'date': '2025-07-11',
      'time': '08.30 am',
      'name': 'Alam Carl',
      'service': 'Basic haircut',
      'avatar': 'assets/images/bom.jpg',
      'color': const Color(0xFFFF9F1C)
    },
    {
      'date': '2025-07-09',
      'time': '09.00 am',
      'name': 'Sergio Wirl',
      'service': 'Hair coloring',
      'avatar': 'assets/images/bom.jpg',
      'color': const Color(0xFFB388EB)
    },
    {
      'date': '2025-07-09',
      'time': '10.00 am',
      'name': 'Sergio Wirl',
      'service': 'Basic haircut',
      'avatar': 'assets/images/bom.jpg',
      'color': const Color(0xFFB388EB)
    },
  ];

  final List<String> times = [
    '08.00 am',
    '08.30 am',
    '09.00 am',
    '09.30 am',
    '10.00 am',
    '10.30 am',
  ];

  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat('dd MMM yyyy').format(selectedDate);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ========== CHỌN NGÀY ==========
        Row(
          children: [
            Icon(Icons.calendar_today_outlined, size: 18.sp, color: Colors.grey[700]),
            SizedBox(width: 8.w),
            Text(
              formattedDate,
              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            TextButton(
              onPressed: () => _selectDate(context),
              child: Text(
                'Chọn ngày',
                style: TextStyle(fontSize: 14.sp, color: Colors.blue),
              ),
            )
          ],
        ),
        SizedBox(height: 8.h),

        Text(
          "Timeline",
          style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 12.h),

        // ========== HIỂN THỊ LỊCH TRÌNH ==========
        Column(
          children: times.map((time) {
            final todayStr = DateFormat('yyyy-MM-dd').format(selectedDate); // chuyển ngày người dùng đã chọn về dạng "yyyy/MM/dd"
            final appointment = scheduleData.firstWhere(
                  (item) => item['time'] == time && item['date'] == todayStr,
              orElse: () => {},
            );

            return Padding(
              padding: EdgeInsets.symmetric(vertical: 8.h),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(width: 70.w, child: Text(time, style: TextStyle(color: Colors.grey, fontSize: 14.sp))),
                  const SizedBox(width: 12),
                  appointment.isNotEmpty
                      ? Container(
                    width: 220.w,
                    padding: EdgeInsets.all(10.r),
                    decoration: BoxDecoration(
                      color: appointment['color'],
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 16.r,
                          backgroundImage: AssetImage(appointment['avatar']),
                        ),
                        SizedBox(width: 8.w),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              appointment['name'],
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              appointment['service'],
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: Colors.white.withOpacity(0.9),
                              ),
                            )
                          ],
                        )
                      ],
                    ),
                  )
                      : Container(
                    height: 48.h,
                    width: 220.w,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        )
      ],
    );
  }

  // ================== CHỌN NGÀY ==================
  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2023, 1),
      lastDate: DateTime(2030),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }
}
