import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:testrunflutter/core/widgets/MapCard.dart';
import 'package:testrunflutter/core/widgets/TextBasic.dart'; // Giả định có customText
import 'package:geolocator/geolocator.dart'; // Thêm gói geolocator

class FindABarber extends StatefulWidget {
  const FindABarber({super.key});

  @override
  State<FindABarber> createState() => _FindABarberState();
}

class _FindABarberState extends State<FindABarber> {
  final TextEditingController _searchController = TextEditingController();
  bool _hasText = false; // Theo dõi xem TextField có văn bản không
  int? _selectedIndex; // Theo dõi TextField được chọn
  LatLng? _currentPosition; // Lưu tọa độ hiện tại

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onTextChanged); // Lắng nghe thay đổi văn bản
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    setState(() {
      _hasText = _searchController.text.isNotEmpty; // Cập nhật trạng thái khi văn bản thay đổi
    });
  }

  Future<void> _updateCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      print('Dịch vụ định vị bị tắt');
      return;
    }

    LocationPermission permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      print('Quyền truy cập vị trí bị từ chối');
      return;
    }

    Position position = await Geolocator.getCurrentPosition();
    setState(() {
      _currentPosition = LatLng(position.latitude, position.longitude);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          color: Colors.white,
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 10.h),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.arrow_back, color: Color(0xFF111827)),
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        'Tìm quán cắt tóc gần đây',
                        style: TextStyle(
                          color: const Color(0xFF111827),
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Nội dung chính
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        height: 300.h,
                        child: MapCard(
                          isDisplay: false,
                          height: 300,
                          searchController: _searchController,
                        ),
                      ),

                      // Thông tin bên dưới
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.2), // Sửa lại opacity hợp lệ
                              spreadRadius: 2,
                              blurRadius: 5,
                              offset: const Offset(0, -2),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 15.h),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (!_hasText) ...[
                                // Hiển thị khi TextField rỗng
                                Row(
                                  children: [
                                    const Icon(Icons.location_on_rounded, color: Color(0xFF111827)),
                                    SizedBox(width: 5.w),
                                    Text(
                                      'Đà Nẵng',
                                      style: TextStyle(
                                        color: const Color(0xFF111827),
                                        fontSize: 16.sp,
                                        fontWeight: FontWeight.normal,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 5.h),
                                Text(
                                  '39 Lê Thiện Trị - Hòa Hải - Ngũ Hành Sơn - Đà Nẵng',
                                  style: TextStyle(
                                    color: const Color(0xFF6B7280),
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                                SizedBox(height: 10.h),
                                SizedBox(
                                  height: 140.h,
                                  child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    shrinkWrap: true,
                                    physics: const ClampingScrollPhysics(),
                                    itemCount: 5,
                                    itemBuilder: (context, index) {
                                      return Padding(
                                        padding: EdgeInsets.only(right: 10.w),
                                        child: Container(
                                          width: 200.w,
                                          height: 120.h,
                                          decoration: BoxDecoration(
                                            color: Colors.blue[100],
                                            borderRadius: BorderRadius.circular(10.r),
                                          ),
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              const Icon(Icons.store, color: Colors.blue, size: 30),
                                              SizedBox(height: 5.h),
                                              Text(
                                                'Cửa hàng ${index + 1}',
                                                style: TextStyle(
                                                  fontSize: 14.sp,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.blue[900],
                                                ),
                                              ),
                                              Text(
                                                'Đánh giá: 4.5',
                                                style: TextStyle(
                                                  fontSize: 12.sp,
                                                  color: Colors.blue[900],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ] else ...[
                                // Hiển thị khi TextField có văn bản
                                Padding(
                                  padding: EdgeInsets.only(top: 20.h),
                                  child: customText(
                                    text: 'Cập nhật vị trí',
                                    color: const Color(0xFF111827),
                                    fonSize: 16.sp,
                                    fonWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 10.h),
                                SizedBox(
                                  height: 50.h,
                                  child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    shrinkWrap: true,
                                    physics: const ClampingScrollPhysics(),
                                    itemCount: 3,
                                    itemBuilder: (context, index) {
                                      return Padding(
                                        padding: EdgeInsets.only(right: 10.w),
                                        child: GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              _selectedIndex = index;
                                              _updateCurrentLocation();
                                            });
                                          },
                                          child: Container(
                                            width: 150.w,
                                            height: 40.h,
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              border: Border.all(
                                                color: _selectedIndex == index
                                                    ? Colors.blue
                                                    : Colors.grey.withOpacity(0.3),
                                                width: 2.0,
                                              ),
                                              borderRadius: BorderRadius.circular(8.r),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black.withOpacity(0.1), // Sửa lại opacity hợp lệ
                                                  blurRadius: 4,
                                                  offset: const Offset(0, 2),
                                                ),
                                              ],
                                            ),
                                            child: Center(
                                              child: Text(
                                                'Vị trí ${index + 1}',
                                                style: TextStyle(
                                                  fontSize: 14.sp,
                                                  color: _selectedIndex == index
                                                      ? Colors.blue
                                                      : Colors.black,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(top: 15.h),
                                  child: customText(
                                    text: _currentPosition != null
                                        ? 'Vị trí hiện tại: ${_currentPosition!.latitude}, ${_currentPosition!.longitude}'
                                        : 'Chưa cập nhật vị trí',
                                    color: const Color(0xFF6B7280),
                                    fonSize: 12.sp,
                                    fonWeight: FontWeight.normal,
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(top: 15.h),
                                  child: SizedBox(
                                    width:double.infinity,
                                    child: ElevatedButton(
                                      onPressed: () {
                                        if (_currentPosition != null) {
                                          print(
                                              'Vị trí đã cập nhật: ${_currentPosition!.latitude}, ${_currentPosition!.longitude}');
                                        } else {
                                          print('Vui lòng chọn vị trí để cập nhật!');
                                        }
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFF363062),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8.r),
                                        ),
                                        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
                                      ),
                                      child: Text(
                                        'Xác nhận vị trí',
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
                            ],
                          ),
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
    );
  }
}