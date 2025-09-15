import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:testrunflutter/core/widgets/TextBasic.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:testrunflutter/data/models/ServiceModel.dart';
import 'package:testrunflutter/data/models/ShopModel.dart';
import 'package:testrunflutter/features/Pages/home/cubit/Service/ServiceCubit.dart';
import 'package:testrunflutter/features/Pages/home/cubit/Service/ServiceState.dart';

Widget buildServicesTab(ShopModel shop, List<ServiceModel> listServices) {
  return SingleChildScrollView(
    child: Column(
      children: [
        ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: listServices.length,
            itemBuilder: (context, index) {
              final service = listServices[index];
              return _buildOurService(service.avatarUrl, service.name, service.note, _formatPrice(service.price));
            }
        ),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF363062),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
            child: customText(
              text: 'Đặt lịch ngay',
              color: Colors.white,
              fonSize: 14.sp,
              fonWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    ),
  );
}

Widget _buildOurService(String url,
    String name,
    String introduction,
    String money,) {
  return Padding(
    padding: EdgeInsets.symmetric(vertical: 8.h),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(backgroundImage: CachedNetworkImageProvider(url), radius: 24.r),
        SizedBox(width: 8.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              customText(
                text: name,
                color: Color(0xFF111827),
                fonSize: 16.sp,
                fonWeight: FontWeight.bold,
              ),
              SizedBox(height: 4.h),
              Text(
                introduction,
                style: TextStyle(color: Color(0xFF6B7280), fontSize: 14.sp),
                overflow: TextOverflow.ellipsis, // neu dai qua se hien ...
                maxLines: 2,
              ),
            ],
          ),
        ),

        // Giá tiền bên phải
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.attach_money_sharp, color: Color(0xFF8683A1)),
            customText(
              text: money,
              color: Color(0xFF111827),
              fonSize: 14.sp,
              fonWeight: FontWeight.bold,
            ),
          ],
        ),
      ],
    ),
  );
}

String _formatPrice(double price) {
  return price.toInt().toString().replaceAllMapped(
    RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},',);
}
