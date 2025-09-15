import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dash/flutter_dash.dart';
import 'package:intl/intl.dart';
import 'package:testrunflutter/core/format/FormatPrice.dart';
import 'package:testrunflutter/core/widgets/TextBasic.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:testrunflutter/data/firebase/FireStore.dart';
import 'package:testrunflutter/data/models/BookingModel/BookingDateModel.dart';
import 'package:testrunflutter/data/models/BookingModel/BookingSchedules.dart';
import 'package:testrunflutter/data/models/BookingModel/ServicesSelected.dart';
import 'package:testrunflutter/data/models/ServiceModel.dart';
import 'package:testrunflutter/data/models/ShopModel.dart';
import 'package:testrunflutter/data/models/UserModel.dart';
import 'package:testrunflutter/data/repositories/prefs/UserPrefsService.dart';
import 'package:testrunflutter/features/Pages/home/screens/your_appointment.dart';

// trang 3
class BookAppointment extends StatefulWidget {
  final ShopModel shop;
  final List<ServiceModel> listServices;
  const BookAppointment({super.key,required this.shop,required this.listServices});

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

  void _getTime(){
    final listTime = generateTimeSlots(widget.shop.openHour,widget.shop.closeHour);
    if(listTime.isNotEmpty){
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
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.only(bottom: 8.h),
            child: Column(
              children: [
                Row(
                  children: [
                    IconButton(
                      onPressed: () {},
                      icon: Icon(Icons.arrow_back, color: Color(0xFF111827)),
                    ),
                    customText(
                      text: 'Đặt lịch hẹn',
                      color: Color(0xFF111827),
                      fonSize: 16.sp,
                      fonWeight: FontWeight.bold,
                    ),
                  ],
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12.w),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          customText(
                            text: 'Chọn Ngày',
                            color: Color(0xFF111827),
                            fonSize: 16.sp,
                            fonWeight: FontWeight.bold,
                          ),
                        ],
                      ),
                      SizedBox(height: 12.h),
                      _buildCalendar(),
                      SizedBox(height: 24.h),
                      Row(
                        children: [
                          customText(
                            text: 'Chọn dịch vụ',
                            color: Color(0xFF111827),
                            fonSize: 16.sp,
                            fonWeight: FontWeight.bold,
                          ),
                        ],
                      ),
                      SizedBox(height: 12.h),

                      // hiển thị dịch vụ
                      SizedBox(
                        height: 130.h,
                        child: ListView.separated( // cho phép chèn khoảng cách giữa các phần tử
                          scrollDirection: Axis.horizontal,
                          separatorBuilder: (_, __) => SizedBox(width: 16.w), // khoảng cách giữa các phần tử
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
                              child: Column(
                                children: [
                                  Stack(
                                    children: [
                                      CircleAvatar(
                                        radius: 35.r,
                                        backgroundImage: CachedNetworkImageProvider(widget.listServices[index].avatarUrl),
                                      ),
                                      if (isSelected)
                                        CircleAvatar(
                                          radius: 35.r,
                                          backgroundColor: Colors.black.withOpacity(0.3),
                                          child: Icon(Icons.check, color: Colors.white),
                                        ),
                                    ],
                                  ),
                                  SizedBox(height: 5.h),
                                  Text(
                                    widget.listServices[index].name,
                                    style: TextStyle(fontSize: 14.sp),
                                  ),
                                  Text(
                                    _formatPrice( widget.listServices[index].price),
                                    style: TextStyle(fontSize: 13.sp, color: Colors.grey),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                      SizedBox(height: 16.h),

                      //button time
                      Wrap(
                        spacing: 12, // khoảng cách ngang
                        runSpacing: 12, // khoảng cách dọc
                        children: List.generate(timeSlots.length, (index){
                          final isDisabled = disabled.contains(index);
                          final isSelected = selectedIndex == index;
                          return GestureDetector(
                            onTap: isDisabled ? null : (){setState(() {selectedIndex = index;});},
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 5.h),
                              decoration: BoxDecoration(
                                color: isDisabled ? Colors.white : isSelected ? Color(0xFFD7D6E0) : Colors.white,
                                border: Border.all(color: isDisabled ? Color(0xFFD7D6E0) : Color(0xFF363062),),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                              timeSlots[index],
                                style: TextStyle(
                                  color: isDisabled
                                      ? Colors.grey
                                      : isSelected? Colors.deepPurple: Colors.black,
                                  fontWeight: FontWeight.w500,),
                              )
                            ),
                          );
                        }),
                      ),
                      SizedBox(height: 12.h,),

                      // tám tắt thông tin thanh toán
                      if(selectedServiceIndices.isNotEmpty)
                      Row(
                        children: [
                          customText(text: 'Tóm tắt thanh toán', color: Color(0xFF111827), fonSize: 16.sp, fonWeight: FontWeight.bold)
                        ],
                      ),
                      SizedBox(
                          height: selectedServiceIndices.length * 30.h,
                          child: ListView.builder(
                              itemCount: selectedServiceIndices.length,
                              itemBuilder: (context,index){
                                final actualIndex = selectedServiceIndices.elementAt(index);
                                return Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    customText(text: widget.listServices[actualIndex].name, color: Color(0xFF111827), fonSize: 16.sp, fonWeight: FontWeight.normal),
                                    Row(
                                      children: [
                                        Icon(CupertinoIcons.money_dollar),
                                        customText(text: _formatPrice(widget.listServices[actualIndex].price), color: Color(0xFF111827), fonSize: 16.sp, fonWeight: FontWeight.normal)
                                      ],
                                    )
                                  ],
                                );
                              })
                      ),
                      // gạch ngang
                      LayoutBuilder(builder: (context,constraints){
                        return Dash(
                          direction: Axis.horizontal,
                          length: constraints.maxWidth,
                          dashLength: 8,
                          dashColor: selectedServiceIndices.isNotEmpty ? Color(0xFFC3C1D0) : Colors.white,
                        );
                      }),
                      SizedBox(height: 5.h,),
                      if(selectedServiceIndices.isNotEmpty)
                        SizedBox(
                          height: 30.h,
                          child: ListView.builder(
                              itemCount: 1,
                              itemBuilder: (context,index){
                                return Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    customText(text: 'Tổng', color: Color(0xFF111827), fonSize: 16.sp, fonWeight: FontWeight.bold),
                                    Row(
                                      children: [
                                        Icon(CupertinoIcons.money_dollar),
                                        customText(text: FormatPrice.formatPrice(selectedServiceIndices.fold<double>(0, (sum, i) => sum + widget.listServices[i].price)), color: Color(0xFF111827), fonSize: 16.sp, fonWeight: FontWeight.normal)
                                      ],
                                    )
                                  ],
                                );
                              }),
                        ),
                      SizedBox(height: 5.h,),
                      if(selectedServiceIndices.isNotEmpty)
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                              onPressed: (){
                                String weekdayName = DateFormat('EEEE','vi_VN').format(selectedDate);
                                String formatted = DateFormat('dd/MM/yyyy', 'vi_VN').format(selectedDate);
                                final bookingDateModel = BookingDateModel(time: timeSlots[selectedIndex!], weekdayName: weekdayName, date: formatted);
                                final selectedServices = selectedServiceIndices.map((i) => widget.listServices[i]).toList();
                                final servicesSelected = ServicesSelected(services: selectedServices, total: selectedServiceIndices.fold<double>(0, (sum, i) => sum + widget.listServices[i].price),discount: 0);
                                Navigator.push(context, PageRouteBuilder(
                                  pageBuilder: (context, animation, secondaryAnimation) => YourAppointment(
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
                                    const begin = Offset(1.0, 0.0);  // Bắt đầu bên phải màn hình
                                    const end = Offset.zero;          // Kết thúc ở vị trí hiện tại
                                    final tween = Tween(begin: begin, end: end);
                                    final curvedAnimation = CurvedAnimation(parent: animation, curve: Curves.ease);

                                    return SlideTransition(
                                      position: tween.animate(curvedAnimation),
                                      child: child,
                                    );
                                  },
                                  transitionDuration: const Duration(milliseconds: 1000),  // thời gian chuyển cảnh
                                ));
                              },
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Color(0xFF363062),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.r)
                                  ),
                                padding: EdgeInsets.symmetric(vertical: 10.h,horizontal: 10.h)
                              ),
                              child: customText(text: 'Xác nhận', color: Colors.white, fonSize: 16.sp, fonWeight: FontWeight.bold)),
                        )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }


  Widget _buildCalendar() {
    final firstDay = DateTime(selectedDate.year, selectedDate.month, 1);
    final lastDay = DateTime(selectedDate.year, selectedDate.month + 1, 0);
    final daysInMonth = lastDay.day;

    final startWeekday = firstDay.weekday % 7; // Sunday = 0
    final totalCells = daysInMonth + startWeekday;

    return Column(
      children: [
        Container(
          padding: EdgeInsets.symmetric(vertical: 10.h),
          decoration: BoxDecoration(
            color: Color(0xFFEDEFFB),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: _prevMonth,
                icon: Icon(Icons.arrow_back_ios),
              ),
              Text(
                DateFormat.yMMMM('vi_VN').format(selectedDate),
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
              ),
              IconButton(
                onPressed: _nextMonth,
                icon: Icon(Icons.arrow_forward_ios),
              ),
            ],
          ),
        ),
        SizedBox(height: 10.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: ['Cn', 'Thứ 2', 'Thứ 3', 'Thứ 4', 'Thứ 5', 'Thứ 6', 'Thứ 7']
              .map(
                (e) => Expanded(
                  child: Center(
                    child: Text(e, style: TextStyle(fontSize: 12.sp)),
                  ),
                ),
              )
              .toList(),
        ),
        SizedBox(height: 6.h),
        GridView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: totalCells,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
          ),
          itemBuilder: (context, index) {
            if (index < startWeekday) return Container();

            int day = index - startWeekday + 1;
            final isSelected =
                selectedDate.day == day &&
                selectedDate.month == DateTime.now().month &&
                selectedDate.year == DateTime.now().year;

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

                // Format lại ngày cho đúng với dữ liệu lưu trong Firestore
                String formattedDate = DateFormat('dd/MM/yyyy', 'vi_VN').format(newDate);

                // Lấy các giờ đã đặt
                final bookedTimes = await dtb.getBookedTimes(widget.shop.id, formattedDate);

                // So khớp với timeSlots
                final newDisabled = <int>{};
                for (int i = 0; i < timeSlots.length; i++) {
                  if (bookedTimes.contains(timeSlots[i])) {
                    newDisabled.add(i);
                  }
                }

                setState(() {
                  disabled = newDisabled;
                });
              },

              child: Container(
                margin: EdgeInsets.all(4.r),
                decoration: BoxDecoration(
                  color: selectedDate.day == day
                      ? Color(0xFF5D55FA)
                      : Colors.transparent,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '$day',
                    style: TextStyle(
                      color: selectedDate.day == day
                          ? Colors.white
                          : Colors.black,
                      fontSize: 14.sp,
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
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},',);
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
    while (currentTime.isBefore(closeTime) || currentTime.isAtSameMomentAs(closeTime)) {
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
