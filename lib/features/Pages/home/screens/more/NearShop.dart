import 'package:flutter/material.dart';
import 'package:testrunflutter/core/widgets/ShopCard.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:testrunflutter/data/models/ShopWithDistance.dart';

class NearShop extends StatefulWidget {
  final List<ShopWithDistance> list;

  const NearShop({super.key, required this.list});

  @override
  State<NearShop> createState() => _NearShopState();
}

class _NearShopState extends State<NearShop> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0XFF363062), Color(0XFF4D4C7D)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        elevation: 0,
        title: Row(
          children: [
            IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back, color: Colors.white),
            ),
            Text(
              'Các quán gần đây',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),

      backgroundColor: const Color(0xFFF5F6FA),

      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        child: widget.list.isEmpty
            ? Center(
                child: Text(
                  "Không có quán nào gần bạn",
                  style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
                ),
              )
            : ListView.separated(
                itemCount: widget.list.length,
                separatorBuilder: (_, __) => SizedBox(height: 12.h),
                itemBuilder: (context, index) {
                  final shop = widget.list[index];
                  final locationModel = shop.shop.location;
                  return ShopCard(
                    shop: shop.shop,
                    km: shop.distanceKm,
                    urlImage: shop.shop.shopAvatarImageUrl,
                    name: shop.shop.shopName,
                    address: locationModel.address,
                    rate:
                        '${double.parse(shop.ratingModel.rating.toStringAsFixed(1))} (${shop.ratingModel.quantity})',
                  );
                },
              ),
      ),
    );
  }
}
