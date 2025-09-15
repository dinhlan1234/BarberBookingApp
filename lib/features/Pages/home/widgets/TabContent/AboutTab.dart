import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:testrunflutter/core/widgets/TextBasic.dart';
import 'package:testrunflutter/data/models/ServiceModel.dart';
import 'package:testrunflutter/data/models/ShopModel.dart';
import 'package:testrunflutter/features/Pages/home/screens/Book_Appointmnet.dart';
Widget buildAboutTab(ShopModel shop,List<ServiceModel> listServices) {
  List<String> openDays = shop.openDays;
  bool isExpanded = false;
  String text = shop.introduction != '0'
    ? '${shop.introduction}'
    : "${shop.shopName} tự hào là địa điểm yêu thích của các quý ông yêu thích phong cách hiện đại & chuyên nghiệp. "
      "Với đội ngũ thợ lành nghề, không gian chuyên nghiệp và các dịch vụ cao cấp, chúng tôi luôn nỗ lực để mang đến "
      "trải nghiệm tốt nhất cho khách hàng. Từ cắt tóc, cạo râu đến các liệu trình chăm sóc da mặt, tất cả đều được "
      "thực hiện bởi những người thợ đầy tâm huyết và chuyên nghiệp.";

  return StatefulBuilder(
    builder: (context, setState) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final span = TextSpan(text: text, style: TextStyle(fontSize: 14.sp, color: Colors.black),);
              final tp = TextPainter(text: span, maxLines: isExpanded ? null : 3, textDirection: TextDirection.ltr,);
              tp.layout(maxWidth: constraints.maxWidth);
              final isOverflow = tp.didExceedMaxLines;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    text,
                    maxLines: isExpanded ? null : 3,
                    overflow: TextOverflow.fade,
                    style: TextStyle(fontSize: 14.sp),
                  ),
                  if (isOverflow)
                    GestureDetector(
                      onTap: () => setState(() => isExpanded = !isExpanded),
                      child: Text(
                        isExpanded ? 'Thu gọn' : 'Đọc thêm...',
                        style: TextStyle(
                          color: Colors.blue,
                          fontSize: 14.sp,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          SizedBox(height: 12.h),
          Text("Giờ mở cửa", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp)),
          SizedBox(height: 6.h),
          _buildHoursRow("${openDays[0]} - ${openDays.last}", "${shop.openHour} - ${shop.closeHour}"),
          SizedBox(height: 6.h),
          customText(text: 'Lượt thích của chúng tôi', color: Color(0xFF111827), fonSize: 16.sp, fonWeight: FontWeight.bold),
          SizedBox(height: 6.h),
          _buildOurTim('assets/images/bom.jpg','Nguyen Dinh Lan', 'Cắt đơn giản', '5.0'),
          _buildOurTim('assets/images/bom.jpg','Nguyen Bom', 'Cắt kiểu', '5.0'),
          _buildOurTim('assets/images/bom.jpg','Lan Dinh Nguyen', 'Cắt kiểu, uốn tóc', '4.5'),
          _buildOurTim('assets/images/bom.jpg','Nguyen Vu Quang', 'Cắt đơn giản, nhuộm tóc', '4.5'),
          SizedBox(height: 8.h,),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(onPressed: (){
              Navigator.push(context, PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) => BookAppointment(shop: shop,listServices: listServices,),
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
            },style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF363062),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r)
              )
            ), child: customText(text: 'Đặt lịch ngay', color: Colors.white, fonSize: 14.sp, fonWeight: FontWeight.bold)),
          )

        ],
      );
    },
  );
}
Widget _buildHoursRow(String day, String time) {
  return Padding(
    padding: EdgeInsets.symmetric(vertical: 4.h),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(day, style: TextStyle(fontSize: 14.sp, color: Colors.grey)),
        Text(time, style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold)),
      ],
    ),
  );
}
Widget _buildOurTim(String url, String name, String service, String rate){
  return Padding(
    padding: EdgeInsets.symmetric(horizontal: 5.w),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            CircleAvatar(backgroundImage: AssetImage(url ?? 'assets/images/avtMacDinh.jpg'),),
            SizedBox(width: 5.w,),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                customText(text: name, color: Color(0xFF111827), fonSize: 16.sp, fonWeight: FontWeight.bold),
                customText(text: service, color: Color(0xFF6B7280), fonSize: 14.sp, fonWeight: FontWeight.normal),
              ],
            ),
          ],
        ),
        Row(
          children: [
            Image.asset('assets/icons/star.png',color: Color(0xFF8683A1),width: 25.w,height: 25.h,),
            customText(text: rate, color: Color(0xFF6B7280), fonSize: 12.sp, fonWeight: FontWeight.normal)
          ],
        )

      ],
    ),
  );
}