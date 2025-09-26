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
  const Process({super.key,required this.bookingWithShop});

  @override
  State<Process> createState() => _ProcessState();
}

class _ProcessState extends State<Process> {
  bool check = false;
  int riskStep = 0;
  Timer? _timer;
  FireStoreDatabase dtb = FireStoreDatabase();
  int currentStep = 1;
  
  @override
  void initState() {
    super.initState();
    _loadData();
    _startTimer();
  }
  void _startTimer() {
    // Refresh UI mỗi 30 giây để check thời gian
    _timer = Timer.periodic(const Duration(seconds: 20), (timer) {
      if (mounted) {
        setState(() {
          check = canCheckIn();
        });
      }
    });
  }

  void _loadData(){
    if(widget.bookingWithShop.booking.status == 'Chờ duyệt'){
      currentStep = 0;
    }else if(widget.bookingWithShop.booking.status == 'Đã duyệt'){
      currentStep = 1;
    }else if(widget.bookingWithShop.booking.status == 'Đã đến'){
      currentStep = 2;
    }else if(widget.bookingWithShop.booking.status == 'Hoàn thành1'){
      currentStep = 3;
    }else if(widget.bookingWithShop.booking.status == 'Hoàn thành2'){
      currentStep = 3;
    }else if(widget.bookingWithShop.booking.status == 'Rủi ro'){
      currentStep = 1;
      riskStep = 4;
    }
    if(canCheckIn()){
      check = true;
    }else{
      check = false;
    }
  }
  List<String> steps = ['Booked', 'Waiting', 'OnProcess', 'Finished'];
  List<IconData> icons = [
    Icons.calendar_today_outlined,
    Icons.timer_outlined,
    Icons.content_cut,
    Icons.verified_outlined,
  ];
  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back),
          color: Color(0xFF363062),
        ),
        title: customText(
          text: 'Lịch trình',
          color: Color(0xFF363062),
          fonSize: 16.sp,
          fonWeight: FontWeight.bold,
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {});
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
          child: Column(
            children: [
              // ICONS
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(steps.length, (index) {
                  return Icon(
                    icons[index],
                    color: index <= currentStep ? Color(0xFF2B256E) : Colors.grey[300],
                  );
                }),
              ),
              SizedBox(height: 12.h),
              Stack(
                children: [
                  Container(
                    height: 6.h,
                    margin: EdgeInsets.symmetric(horizontal: 4.w),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),

                  // Line progress
                  LayoutBuilder(
                    builder: (context, constraints) {
                      double stepWidth = constraints.maxWidth / (steps.length - 1);
                      return Container(
                        height: 6.h,
                        width: stepWidth * currentStep,
                        decoration: BoxDecoration(
                          color: Colors.orange,
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                      );
                    },
                  ),

                  // Circles on progress line
                  Positioned.fill(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(steps.length, (index) {
                        return Container(
                          width: 20.w,
                          height: 20.w,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(
                              color: index <= currentStep ? Colors.orange : Colors.grey[300]!,
                              width: 3.w,
                            ),
                            shape: BoxShape.circle,
                          ),
                        );
                      }),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 12.h),

              // LABELS
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(steps.length, (index) {
                  return Container(
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: Color(0xFF2B256E),
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Text(
                      steps[index],
                      style: TextStyle(color: Colors.white, fontSize: 11.sp),
                    ),
                  );
                }),
              ),
              SizedBox(height: 12.h,),

              // nhãn shop
              Container(
                padding: EdgeInsets.symmetric(vertical: 12.h,horizontal: 12.w),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5), // Màu và độ mờ của bóng
                      spreadRadius: 1, // Độ lan rộng của bóng
                      blurRadius: 5, // Độ mờ của bóng
                      offset: Offset(0, 3), // Độ lệch (x, y) của bóng (ví dụ: xuống dưới)
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Image(
                            image: CachedNetworkImageProvider(widget.bookingWithShop.shop.shopAvatarImageUrl),
                            width: 80.w,
                            height: 80.w,
                            fit: BoxFit.cover
                        ),
                        SizedBox(width: 5.w,),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            customText(text: widget.bookingWithShop.shop.shopName, color: Color(0xFF111827), fonSize: 16.sp, fonWeight: FontWeight.bold),
                            Row(
                              children: [
                                Icon(Icons.location_on_rounded,color: Color(0xFF6B7280),size: 19,),
                                customText(text: widget.bookingWithShop.shop.location.address, color: Color(0xFF6B7280), fonSize: 14.sp, fonWeight: FontWeight.normal)
                              ],
                            ),
                            Row(
                              children: [
                                Icon(Icons.star,color: Color(0xFF6B7280),size: 19,),
                                customText(text: '5.0 (24)', color: Color(0xFF6B7280), fonSize: 14.sp, fonWeight: FontWeight.normal)
                              ],
                            )
                          ],
                        )
                      ],
                    ),
                    SizedBox(height: 15.h,),
                    Container(
                      height: 1.h,
                      width: double.infinity,
                      color: Color(0xFFEDEFFB),
                    ),
                    SizedBox(height: 12.h,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            //Map
                            GestureDetector(
                              onTap: (){
                                openMapWithAddress(address: widget.bookingWithShop.shop.location.address, wardName: widget.bookingWithShop.shop.location.wardName, districtName: widget.bookingWithShop.shop.location.districtName, provinceName: widget.bookingWithShop.shop.location.provinceName);
                              },
                              child: Column(
                                children: [
                                  Image.asset('assets/icons/google-maps.png',width: 25.w,height: 25.h,),
                                  customText(text: 'Maps', color: Color(0xFF363062), fonSize: 12.sp, fonWeight: FontWeight.normal)
                                ],
                              ),
                            ),
                            SizedBox(width: 30.w,),
                            //phone
                            GestureDetector(
                              onTap: (){
                                _makePhoneCall(widget.bookingWithShop.shop.phone);
                              },
                              child: Column(
                                children: [
                                  Icon(Icons.phone,size: 25.r,),
                                  customText(text: 'Điện thoại', color: Color(0xFF363062), fonSize: 12.sp, fonWeight: FontWeight.normal)
                                ],
                              ),
                            ),
                            SizedBox(width: 30.w,),
                            // Chat
                            GestureDetector(
                              onTap: (){},
                              child: Column(
                                children: [
                                  Image.asset('assets/icons/bubble-chat.png',color: Color(0xff363062),width: 25.w,height: 25.h,),
                                  customText(text: 'Chat', color: Color(0xFF363062), fonSize: 12.sp, fonWeight: FontWeight.normal)
                                ],
                              ),
                            )
                          ],
                        ),
                        //Huy
                        ElevatedButton(
                            onPressed: ()async{
                              await FCMService.sendFCMNotification(
                                title: 'Chao mung',
                                body: 'Test notification',
                                fcmToken: 'fuZyOJztTdigyKiHt_W38d:APA91bE83Rh9ZpeRLoP8daZOF03cqNLhBkYtW6oJ9k_oLQ0oNFnj5PvXaTObuK99Vnj1YrvsZIX1TMDzHvul44V6afFVgbxx3LVL-EgIKOD08sthP01lprE',
                              );
                            },
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFF363062),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.r)
                                )
                            ),
                            child: customText(text: 'Hủy', color: Colors.white, fonSize: 16.sp, fonWeight: FontWeight.bold))
                      ],
                    )
                  ],
                ),
              ),
              SizedBox(height: 15.h,),
              // ngay va thoi gian
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.calendar_month,color: Color(0xFF111827),),
                      SizedBox(width: 5.w,),
                      customText(text: 'Ngày và thời gian', color: Color(0xFF111827), fonSize: 16.sp, fonWeight: FontWeight.bold)
                    ],
                  ),
                  customText(text: '${widget.bookingWithShop.booking.bookingDateModel.time} - ${widget.bookingWithShop.booking.bookingDateModel.weekdayName}, ${widget.bookingWithShop.booking.bookingDateModel.date}', color: Color(0xFF6B7280), fonSize: 16.sp, fonWeight: FontWeight.normal)
                ],
              ),
              SizedBox(height: 15.h,),
              Row(
                children: [
                  Icon(Icons.cut,color: Color(0xFF111827),),
                  SizedBox(width: 5.w,),
                  customText(text: 'Dịch vụ đã chọn', color: Color(0xFF111827), fonSize: 16.sp, fonWeight: FontWeight.bold)
                ],
              ),
              SizedBox(height: 10.h,),
              ListView.separated(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: widget.bookingWithShop.booking.servicesSelected.services.length,
                itemBuilder: (context,index){
                  return Row(
                    children: [
                      CircleAvatar(backgroundImage: CachedNetworkImageProvider(widget.bookingWithShop.booking.servicesSelected.services[index].avatarUrl),radius: 25.r,),
                      SizedBox(width: 10.w,),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          customText(text: widget.bookingWithShop.booking.servicesSelected.services[index].name, color: Color(0xFF111827), fonSize: 16.sp, fonWeight: FontWeight.bold),
                          customText(text: widget.bookingWithShop.booking.servicesSelected.services[index].note, color: Color(0xFF6B7280), fonSize: 16.sp, fonWeight: FontWeight.bold)

                        ],
                      )
                    ],
                  );
                }, separatorBuilder: (BuildContext context, int index) => SizedBox(height: 5.h,),
              ),
              SizedBox(height: 15.h,),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                    onPressed: currentStep == 0
                        ? null
                        : currentStep == 2
                          ? null
                          : currentStep == 3
                            ? (){}
                            :currentStep == 1 && riskStep == 4
                              ? null
                              : currentStep == 1 && !check
                                ? null
                                : () async{
                      showDialog(context: context, barrierDismissible: false, builder: (context) => const Center(child: CircularProgressIndicator(),));
                     if(await checkLocation(widget.bookingWithShop.shop)){
                       if(await dtb.updateStatus(widget.bookingWithShop.booking)){
                         if(mounted){
                           Navigator.pop(context);
                           setState(() {
                             currentStep = 2;
                           });
                         }
                         dtb.sendNotification(object: 'Shops', id: widget.bookingWithShop.booking.idShop, title: 'Khách đã đến !!!', body: 'Khách đã đến rồi bạn ơi, nhanh nhanh ra mở cửa đón khách nào 🤗');
                       }else{
                         if(mounted){
                           Navigator.pop(context);
                           displayMessageToUser(context, 'Có lỗi trong lúc chuyển trạng thái. Vui lòng kiểm tra kết nối mạng',isSuccess: false,onOk: (){});
                         }
                       }
                     }else{
                       if(mounted){
                         Navigator.pop(context);
                         displayMessageToUser(context, 'Hình như bạn chưa đến đúng vị trí. Vui lòng đến đúng vị trí 😭',isSuccess: false,onOk: (){});
                       }
                     }
                    },
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      backgroundColor: currentStep == 0
                          ? Colors.grey
                          : currentStep == 2
                            ? Colors.grey
                            : currentStep == 3
                              ? Colors.green
                              : currentStep == 1 && riskStep == 4
                                ? Colors.grey
                                : currentStep == 1 && !check
                                  ? Colors.grey
                                  : Color(0xFF2B256E),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14.r)
                      )
                    ),
                    child: customText(
                        text: currentStep == 0
                            ? 'Vui lòng chờ quán xác nhận'
                            : currentStep == 2
                              ? 'Đã đến quán'
                              : currentStep == 3
                                ? 'Đã hoàn thành'
                                :  currentStep == 1 && riskStep == 4
                                  ? 'Đơn rủi ro vui lòng liên hệ quán để xử lý'
                                  : currentStep == 1 && !check
                                    ? 'Vui lòng chờ đến thời gian để check in'
                                    : 'Tôi đã đến điểm cắt',
                        color: Colors.white,
                        fonSize: 14.sp,
                        fonWeight: FontWeight.normal
                    )
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
  Future<void> openMapWithAddress({
    required String address,
    required String wardName,
    required String districtName,
    required String provinceName,
  }) async {
    final fullAddress = "$address, $wardName, $districtName, $provinceName";
    final Uri uri = Uri.parse('https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(fullAddress)}',);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      throw 'Không thể mở Google Maps';
    }
  }
  bool canCheckIn() {
    try {
      // Lấy thời gian hiện tại
      final now = DateTime.now();

      // Parse ngày booking
      final dateParts = widget.bookingWithShop.booking.bookingDateModel.date.split("/");
      if (dateParts.length != 3) {
        print("Định dạng ngày không hợp lệ: ${widget.bookingWithShop.booking.bookingDateModel.date}");
        return false;
      }
      final day = int.parse(dateParts[0]);
      final month = int.parse(dateParts[1]);
      final year = int.parse(dateParts[2]);

      // Parse giờ booking
      final timeParts = widget.bookingWithShop.booking.bookingDateModel.time.split(":");
      if (timeParts.length != 2) {
        print("Định dạng giờ không hợp lệ: ${widget.bookingWithShop.booking.bookingDateModel.time}");
        return false;
      }
      final hour = int.parse(timeParts[0]);
      final minute = int.parse(timeParts[1]);

      // Tạo booking DateTime (không cần .toLocal())
      final bookingDateTime = DateTime(year, month, day, hour, minute);

      // Khoảng thời gian cho phép: -10 phút đến +10 phút
      final startAllow = bookingDateTime.subtract(const Duration(minutes: 10));
      final endAllow = bookingDateTime.add(const Duration(minutes: 10));


      // Kiểm tra thời gian hiện tại có nằm trong khoảng [startAllow, endAllow]
      bool canCheck = (now.isAfter(startAllow) || now.isAtSameMomentAs(startAllow)) &&
          (now.isBefore(endAllow) || now.isAtSameMomentAs(endAllow));

      return canCheck;

    } catch (e) {
      print('Lỗi trong canCheckIn: $e');
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
