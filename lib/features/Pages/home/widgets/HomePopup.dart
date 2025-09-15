import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:testrunflutter/core/widgets/TextBasic.dart';
class OpenPopup extends StatefulWidget {
  const OpenPopup({super.key});

  @override
  State<OpenPopup> createState() => _OpenPopupState();
}

class _OpenPopupState extends State<OpenPopup> {
  late List<bool> _isSelected;
  double _sliderValue = 1.0;
  final FocusNode _focusNode1 = FocusNode();
  final FocusNode _focusNode2 = FocusNode();
  @override
  void initState() {
    super.initState();
    final List<String> services = [
      'Cắt đơn giản',
      'Cắt kiểu',
      'Gội đầu',
      'Uốn tóc',
      'Nhuộm tóc',
    ];
    _isSelected = List<bool>.filled(services.length, false);
    _focusNode1.addListener(() {
      setState(() {}); // Cập nhật giao diện khi focus thay đổi
    });
    _focusNode2.addListener(() {
      setState(() {}); // Cập nhật giao diện khi focus thay đổi
    });
  }
  @override
  Widget build(BuildContext context) {
    final List<String> services = [
      'Cắt đơn giản',
      'Cắt kiểu',
      'Gội đầu',
      'Uốn tóc',
      'Nhuộm tóc',
    ];
    return SingleChildScrollView(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom, // Đẩy giao diện tránh bàn phím
      ),
      child: Container(
        height: 530.h,
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.symmetric(vertical: 15.h, horizontal: 15.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12.r),
                        child: Image.asset(
                          'assets/icons/fillter_icon_barberbooking.png',
                          fit: BoxFit.cover,),
                      ),
                      SizedBox(width: 10.w,),
                      Text('Lọc danh sách', style: TextStyle(
                          color: Color(0XFF111827),
                          fontWeight: FontWeight.bold,
                          fontSize: 15.sp),)
                    ],
                  ),
                  ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0XFFCBD5E1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.sp),
                        ),
                        elevation: 0,
                        minimumSize: Size(30.w, 30.h),
                        padding: EdgeInsets.zero,
                      ),
                      child: Icon(
                        Icons.close, size: 16.sp, color: Color(0xFF94A3B8),)
                  )
                ],
              ),
            ),
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                    color: Colors.white
                ),
                child: SingleChildScrollView(
                    child: Padding(
                      padding: EdgeInsets.only(right: 15.w,left: 15.w,bottom: 15.h),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 20.h,),
                          Text('Chọn dịch vụ', style: TextStyle(color: Color(
                              0XFF111827),
                              fontSize: 14.sp,
                              fontWeight: FontWeight.bold),),
                          SizedBox(height: 10.h,),
                          Wrap(
                            spacing: 10.w,
                            runSpacing: 10.h,
                            alignment: WrapAlignment.start,
                            children: services.asMap().entries.map((entry) {
                              final index = entry.key;
                              final service = entry.value;
                              return ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      _isSelected[index] = !_isSelected[index];
                                    });
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: _isSelected[index] ? Color(0XFFEDEFFB) : Colors.white,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12.sp),
                                        side: BorderSide(
                                            color: _isSelected[index] ? Color(0XFF363062) : Colors.white,
                                            width: 1
                                        )
                                    ),
                                  ),
                                  child: customText(text: service,
                                      color: Color(0XFF363062),
                                      fonSize: 14,
                                      fonWeight: FontWeight.normal)
                              );
                            }).toList(),
                          ),
                          SizedBox(height: 10.h,),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              customText(text: 'Đánh giá của quán', color: Color(0XFF111827), fonSize: 14.sp, fonWeight: FontWeight.bold),
                              SizedBox(height: 10.h,),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  Icon(Icons.star,color: _sliderValue >= 1 ? Color(0XFFF99417) :Color(0XFFE5E7EB),size: 32.r,),
                                  Icon(Icons.star,color: _sliderValue >= 2 ? Color(0XFFF99417) :Color(0XFFE5E7EB),size: 32.r,),
                                  Icon(Icons.star,color: _sliderValue >= 3 ? Color(0XFFF99417) :Color(0XFFE5E7EB),size: 32.r,),
                                  Icon(Icons.star,color: _sliderValue >= 4 ? Color(0XFFF99417) :Color(0XFFE5E7EB),size: 32.r,),
                                  Icon(Icons.star,color: _sliderValue == 5 ? Color(0XFFF99417) :Color(0XFFE5E7EB),size: 32.r,),
                                  SizedBox(width: 5.w,),
                                  customText(text: '($_sliderValue)', color: Color(0XFF363062), fonSize: 12.sp, fonWeight: FontWeight.normal),
                                ],
                              ),
                              SizedBox(
                                width: 270.w,
                                child: Slider(
                                    value: _sliderValue,
                                    min: 1.0,
                                    max: 5.0,
                                    divisions: 4,
                                    onChanged: (value){
                                      setState(() {
                                        _sliderValue = value;
                                      });
                                    }
                                ),
                              )
                            ],
                          ),
                          SizedBox(height: 10.h,),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              customText(text: 'Khoảng cách mong muốn', color: Color(0XFF111827), fonSize: 14.sp, fonWeight: FontWeight.bold),
                              Row(
                                children: [
                                  Row(
                                    children: [
                                      Column(
                                        children: [
                                          customText(text: 'Từ', color: Color(0XFF8683A1), fonSize: 12.sp, fonWeight: FontWeight.normal),
                                          SizedBox(
                                            width: 50.w,
                                            height: 50.h,
                                            child: TextField(
                                              focusNode: _focusNode1,
                                              keyboardType: TextInputType.number,
                                              textAlign: TextAlign.center,
                                              style: TextStyle(color: Color(0XFF363062),fontSize: 16.sp),
                                              decoration: InputDecoration(
                                                  filled: true,
                                                  fillColor: _focusNode1.hasFocus ? Color(0XFFEDEFFB) : Colors.white,
                                                  focusedBorder: OutlineInputBorder(
                                                    borderRadius: BorderRadius.circular(12.r),
                                                    borderSide: BorderSide(
                                                        color: Color(0XFF363062),
                                                        width: 1
                                                    ),
                                                  ),

                                                  enabledBorder: OutlineInputBorder(
                                                    borderRadius: BorderRadius.circular(12.r),
                                                    borderSide: BorderSide(
                                                        color: Color(0XFF363062),
                                                        width: 1
                                                    ),
                                                  )
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(width: 5.w,),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          SizedBox(height: 45.h), // Đẩy "km" xuống dưới một chút
                                          customText(
                                            text: 'km',
                                            color: const Color(0xFF363062),
                                            fonSize: 14.sp,
                                            fonWeight: FontWeight.normal,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  Container(
                                    margin: EdgeInsets.only(right: 15.w,left: 15.w,top: 18.h),
                                    width: 30.w,
                                    height: 1.h,
                                    color: Color(0XFF363062),
                                  ),
                                  Row(
                                    children: [
                                      Column(
                                        children: [
                                          customText(text: 'Đến', color: Color(0XFF8683A1), fonSize: 12.sp, fonWeight: FontWeight.normal),
                                          SizedBox(
                                            width: 50.w,
                                            height: 50.h,
                                            child: TextField(
                                              focusNode: _focusNode2,
                                              keyboardType: TextInputType.number,
                                              textAlign: TextAlign.center,
                                              style: TextStyle(color: Color(0XFF363062),fontSize: 16.sp),
                                              decoration: InputDecoration(
                                                  filled: true,
                                                  fillColor: _focusNode2.hasFocus ? Color(0XFFEDEFFB) : Colors.white,
                                                  focusedBorder: OutlineInputBorder(
                                                    borderRadius: BorderRadius.circular(12.r),
                                                    borderSide: BorderSide(
                                                        color: Color(0XFF363062),
                                                        width: 1
                                                    ),
                                                  ),

                                                  enabledBorder: OutlineInputBorder(
                                                    borderRadius: BorderRadius.circular(12.r),
                                                    borderSide: BorderSide(
                                                        color: Color(0XFF363062),
                                                        width: 1
                                                    ),
                                                  )
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(width: 5.w,),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          SizedBox(height: 45.h), // Đẩy "km" xuống dưới một chút
                                          customText(
                                            text: 'km',
                                            color: const Color(0xFF363062),
                                            fonSize: 14.sp,
                                            fonWeight: FontWeight.normal,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              SizedBox(height: 10.h,),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                    onPressed: (){},
                                    style: ElevatedButton.styleFrom(
                                      padding: EdgeInsets.symmetric(vertical: 10.h,horizontal: 10.w),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12.r),
                                      ),
                                      backgroundColor: Color(0XFF363062)
                                    ),
                                    child: customText(text: 'Xác nhận', color: Colors.white, fonSize: 14.sp, fonWeight: FontWeight.bold)
                                ),
                              )
                            ],
                          )
                        ],
                      ),
                    )
                ),
              ),

            ),
          ],
        ),
      ),
    );
  }
}
