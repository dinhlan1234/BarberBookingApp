import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:testrunflutter/core/format/TwoDigitInputFormatter.dart';
import 'package:testrunflutter/core/helper/aleart.dart';
import 'package:testrunflutter/core/widgets/TextBasic.dart';
import 'package:testrunflutter/features/Pages/profile/screens/registrationForm/form4Page.dart';

class Form3Page extends StatefulWidget {
  final Map<String,dynamic> tempData;
  const Form3Page({super.key,required this.tempData});

  @override
  State<Form3Page> createState() => _Form3PageState();
}

class _Form3PageState extends State<Form3Page> {
  TextEditingController openHourController = TextEditingController();
  TextEditingController openMinuteController = TextEditingController();

  TextEditingController closeHourController = TextEditingController();
  TextEditingController closeMinuteController = TextEditingController();

  List<String> days = ['Thứ 2','Thứ 3','Thứ 4','Thứ 5','Thứ 6','Thứ 7','Chủ nhật'];
  Set<int> selectedIndices = {};
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back),
          color: Color(0xFF111827),
        ),
        title: customText(
          text: 'Đăng ký doanh nghiệp',
          color: Color(0xFF111827),
          fonSize: 16.sp,
          fonWeight: FontWeight.bold,
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(12.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            customText(text: 'Thông tin chi tiết quán', color: Color(0xFF111827), fonSize: 16.sp, fonWeight: FontWeight.bold),
            SizedBox(height: 20.h,),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                customText(text: 'Giờ mở/đóng cửa:', color: Color(0xFF111827), fonSize: 14.sp, fonWeight: FontWeight.bold),
                Row(
                 children: [
                   customHour(openHourController),
                   SizedBox(width: 5.w,),
                   customText(text: ':', color: Color(0xFF111827), fonSize: 14.sp, fonWeight: FontWeight.bold),
                   SizedBox(width: 5.w,),
                   customMinute(openMinuteController)
                 ],
               ),
                Container(
                  height: 1.h,
                  width: 5.w,
                  color: Color(0xFF111827),
                ),
                Row(
                  children: [
                    customHour(closeHourController),
                    SizedBox(width: 5.w,),
                    customText(text: ':', color: Color(0xFF111827), fonSize: 14.sp, fonWeight: FontWeight.bold),
                    SizedBox(width: 5.w,),
                    customMinute(closeMinuteController)
                  ],
                ),
              ],
            ),
            SizedBox(height: 15.h,),
            customText(text: 'Ngày mở cửa: ', color: Color(0xFF111827), fonSize: 14.sp, fonWeight: FontWeight.bold),
            SizedBox(height: 15.h,),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: List.generate(days.length, (index){
                final isSelected = selectedIndices.contains(index);
                return GestureDetector(
                  onTap: (){
                    setState(() {
                      if (selectedIndices.contains(index)) {
                        selectedIndices.remove(index);
                      } else {
                        selectedIndices.add(index);
                      }
                    });
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 5.h),
                    decoration: BoxDecoration(
                      color: isSelected ? Color(0xFFD7D6E0) : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Color(0xFFD7D6E0))
                    ),
                    child: customText(text: days[index], color: isSelected ? Colors.white : Color(0xFF111827), fonSize: 14.sp, fonWeight: FontWeight.normal),
                  ),
                );
              }),
            ),
            SizedBox(height: 15.h,),
            SizedBox(height: 15.h,),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                  onPressed: () async{
                    showDialog(context: context, builder: (context) => Center(child: CircularProgressIndicator(),));
                    if(validateForm()){
                      String openHour = openHourController.text;
                      String openMinute = openMinuteController.text;
                      String closeHour = closeHourController.text;
                      String closeMinute = closeMinuteController.text;
                      Navigator.pop(context);
                      if(openHourController.text.length == 1){
                        final String oldValue = openHourController.text;
                        openHour = oldValue.padLeft(2,'0');
                      }
                      if(openMinuteController.text.length == 1){
                        final String oldValue = openMinuteController.text;
                        openMinute = oldValue.padLeft(2,'0');
                      }
                      if(closeHourController.text.length == 1){
                        final String oldValue = closeHourController.text;
                        closeHour = oldValue.padLeft(2,'0');
                      }
                      if(closeMinuteController.text.length == 1){
                        final String oldValue = closeMinuteController.text;
                        closeMinute = oldValue.padLeft(2,'0');
                      }
                      print('${openHour}:${openMinute} - ${closeHour}:${closeMinute}');
                      List<String> selectedDay = [];
                      for(var day in selectedIndices){
                        selectedDay.add(days[day]);
                      }
                      if(selectedDay.isNotEmpty){
                        Navigator.pop(context);
                        Navigator.push(context, PageRouteBuilder(
                          pageBuilder: (context, animation, secondaryAnimation) => Form4Page(
                            tempData: {
                              'ownerName': widget.tempData['ownerName'],
                              'cccd': widget.tempData['cccd'],
                              'email': widget.tempData['email'],
                              'phone': widget.tempData['phone'],
                              'shopName':  widget.tempData['shopName'],
                              'lat': widget.tempData['lat'],
                              'long': widget.tempData['long'],

                              'provinceName': widget.tempData['provinceName'],
                              'provinceCode': widget.tempData['provinceCode'],
                              'districtName': widget.tempData['districtName'],
                              'wardName': widget.tempData['wardName'],
                              'address': widget.tempData['address'],

                              'openHour': '${openHour}:${openMinute}',
                              'closeHour':'${closeHour}:${closeMinute}',
                              'openDays': selectedDay
                            },
                          ),
                          transitionsBuilder: (context, animation, secondaryAnimation, child) {
                            const begin = Offset(0.0, 1.0);
                            const end = Offset.zero;
                            final tween = Tween(begin: begin, end: end);
                            final curvedAnimation = CurvedAnimation(parent: animation, curve: Curves.ease);

                            return SlideTransition(
                              position: tween.animate(curvedAnimation),
                              child: child,
                            );
                          },
                          transitionDuration: const Duration(milliseconds: 1000),  // thời gian chuyển cảnh
                        ));
                      }else{
                        showError('Vui lòng chọn ngày mở cửa');
                      }
                    }

                  },
                  style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 10.h),
                      backgroundColor: Color(0xFF363062),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.r),
                      )
                  ),
                  child: customText(text: 'Tiếp', color: Colors.white, fonSize: 16.sp, fonWeight: FontWeight.bold)),
            )
          ],
        ),
      ),
    );
  }




  Widget customHour(TextEditingController controller) {
    return SizedBox(
      width: 35.w,
      height: 35.h,
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        decoration: InputDecoration(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.r),
          ),
          contentPadding: EdgeInsets.symmetric(vertical: 4.r, horizontal: 8.r),
          isDense: true,
        ),
      ),
    );
  }

  Widget customMinute(TextEditingController controller) {
    return SizedBox(
      width: 35.w,
      height: 35.h,
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        decoration: InputDecoration(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.r),
          ),
          contentPadding: EdgeInsets.symmetric(vertical: 4.r, horizontal: 8.r),
          isDense: true,
        ),
      ),
    );
  }

  bool validateForm(){
    showDialog(context: context,barrierDismissible: false, builder: (context) => Center(child: CircularProgressIndicator(),));
    if(openHourController.text.isEmpty){
      showError('Giờ mở cửa không được để trống');
      return false;
    }else if(closeHourController.text.isEmpty){
      showError('Giờ đóng cửa không được để trống');
      return false;
    }else if(openMinuteController.text.isEmpty){
      showError('Phút mở cửa không được để trống');
      return false;
    }else if(closeMinuteController.text.isEmpty){
      showError('Phút đóng cửa không được để trống');
      return false;
    }else if(openHourController.text.length > 3 || closeHourController.text.length > 3 || int.parse(openHourController.text) > 23 || int.parse(closeHourController.text) > 23 || int.parse(openHourController.text) < 0 || int.parse(closeHourController.text) < 0){
      showError('Định dạng giờ không chính xác');
      return false;
    }else if(openMinuteController.text.length > 3 || closeMinuteController.text.length > 3 || int.parse(openMinuteController.text) > 59 || int.parse(closeMinuteController.text) > 59 || int.parse(openMinuteController.text) < 0 || int.parse(closeMinuteController.text) < 0){
      showError('Định dạng phút không chính xác');
      return false;
    }
    return true;
  }
  void showError(String message) {
    displayMessageToUser(context, message, isSuccess: false, onOk: () {
      Navigator.pop(context);
    });
  }
}
