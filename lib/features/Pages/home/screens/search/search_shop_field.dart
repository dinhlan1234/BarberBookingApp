import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:testrunflutter/data/firebase/FireStore.dart';
import 'package:testrunflutter/data/models/ShopModel.dart';
import 'package:testrunflutter/data/models/UserModel.dart';
import 'package:testrunflutter/features/Pages/home/screens/detail_barber.dart';

class SearchShopField extends StatefulWidget {
  final double lat;
  final double lon;
  final UserModel userModel;

  const SearchShopField({
    super.key,
    required this.lat,
    required this.lon,
    required this.userModel,
  });

  @override
  State<SearchShopField> createState() => _SearchShopFieldState();
}

class _SearchShopFieldState extends State<SearchShopField> with TickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  String keyword = "";
  FireStoreDatabase dtb = FireStoreDatabase();
  bool _isSearching = false;
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Search input field
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: TextField(
            controller: _controller,
            style: TextStyle(
              fontSize: 16.sp,
              color: const Color(0xFF111827),
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              hintText: "Tìm barbershop gần bạn...",
              hintStyle: TextStyle(
                color: const Color(0xFF9CA3AF),
                fontSize: 16.sp,
                fontWeight: FontWeight.w400,
              ),
              prefixIcon: Container(
                padding: EdgeInsets.all(12.w),
                child: Icon(
                  Icons.search_rounded,
                  color: const Color(0XFF363062),
                  size: 24.sp,
                ),
              ),
              suffixIcon: keyword.isNotEmpty
                  ? IconButton(
                icon: Icon(
                  Icons.close_rounded,
                  color: const Color(0xFF9CA3AF),
                  size: 20.sp,
                ),
                onPressed: () {
                  _controller.clear();
                  setState(() {
                    keyword = "";
                    _isSearching = false;
                  });
                  _animationController.reverse();
                },
              )
                  : null,
              filled: true,
              fillColor: Colors.white,
              contentPadding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 20.w),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16.r),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16.r),
                borderSide: BorderSide(
                  color: const Color(0XFF363062),
                  width: 2.w,
                ),
              ),
            ),
            onChanged: (value) {
              setState(() {
                keyword = value.trim();
                _isSearching = keyword.isNotEmpty;
              });

              if (keyword.isNotEmpty) {
                _animationController.forward();
              } else {
                _animationController.reverse();
              }
            },
          ),
        ),

        // Search results
        if (_isSearching)
          AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return Transform.scale(
                scale: _animation.value,
                alignment: Alignment.topCenter,
                child: Opacity(
                  opacity: _animation.value,
                  child: Container(
                    margin: EdgeInsets.only(top: 12.h),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16.r),
                      child: Container(
                        constraints: BoxConstraints(
                          maxHeight: 280.h,
                        ),
                        child: StreamBuilder(
                          stream: FirebaseFirestore.instance
                              .collection("Shops")
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return Container(
                                height: 120.h,
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SizedBox(
                                        width: 24.w,
                                        height: 24.w,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2.w,
                                          valueColor: AlwaysStoppedAnimation<Color>(
                                            Color(0XFF363062),
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: 12.h),
                                      Text(
                                        'Đang tìm kiếm...',
                                        style: TextStyle(
                                          color: Color(0xFF6B7280),
                                          fontSize: 14.sp,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }

                            final docs = snapshot.data!.docs.where((doc) {
                              final name = doc['shopName'].toString().toLowerCase();
                              return name.contains(keyword.toLowerCase());
                            }).toList();

                            if (docs.isEmpty) {
                              return Container(
                                height: 120.h,
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.search_off_rounded,
                                        color: Color(0xFF9CA3AF),
                                        size: 32.sp,
                                      ),
                                      SizedBox(height: 8.h),
                                      Text(
                                        "Không tìm thấy kết quả",
                                        style: TextStyle(
                                          color: Color(0xFF6B7280),
                                          fontSize: 16.sp,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      SizedBox(height: 4.h),
                                      Text(
                                        "Thử tìm kiếm với từ khóa khác",
                                        style: TextStyle(
                                          color: Color(0xFF9CA3AF),
                                          fontSize: 13.sp,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }

                            return ListView.separated(
                              padding: EdgeInsets.all(12.w),
                              itemCount: docs.length,
                              separatorBuilder: (context, index) => Divider(
                                height: 1.h,
                                color: Color(0xFFF3F4F6),
                              ),
                              itemBuilder: (context, index) {
                                final shopModel = ShopModel.fromJson(docs[index].data());

                                return Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12.r),
                                  ),
                                  child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(12.r),
                                      onTap: () async {
                                        // Show loading indicator
                                        showDialog(
                                          context: context,
                                          barrierDismissible: false,
                                          builder: (context) => Center(
                                            child: Container(
                                              padding: EdgeInsets.all(20.w),
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius: BorderRadius.circular(12.r),
                                              ),
                                              child: CircularProgressIndicator(
                                                valueColor: AlwaysStoppedAnimation<Color>(
                                                  Color(0XFF363062),
                                                ),
                                              ),
                                            ),
                                          ),
                                        );

                                        try {
                                          final results = await Future.wait([
                                            dtb.getDistance(widget.lat, widget.lon, shopModel),
                                            getRate(shopModel.id),
                                          ]);
                                          final double km = results[0] as double;
                                          final String rate = results[1] as String;

                                          // Hide loading
                                          Navigator.pop(context);

                                          Navigator.push(
                                            context,
                                            PageRouteBuilder(
                                              pageBuilder: (context, animation, secondaryAnimation) =>
                                                  DetailBarber(
                                                    shop: shopModel,
                                                    km: km,
                                                    rate: rate,
                                                  ),
                                              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                                const begin = Offset(1.0, 0.0);
                                                const end = Offset.zero;
                                                final tween = Tween(begin: begin, end: end);
                                                final curvedAnimation = CurvedAnimation(
                                                  parent: animation,
                                                  curve: Curves.easeInOut,
                                                );
                                                return SlideTransition(
                                                  position: tween.animate(curvedAnimation),
                                                  child: child,
                                                );
                                              },
                                              transitionDuration: Duration(milliseconds: 400),
                                            ),
                                          );
                                        } catch (e) {
                                          // Hide loading and show error
                                          Navigator.pop(context);
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text('Có lỗi xảy ra, vui lòng thử lại'),
                                              backgroundColor: Colors.red,
                                            ),
                                          );
                                        }
                                      },
                                      child: Padding(
                                        padding: EdgeInsets.all(12.w),
                                        child: Row(
                                          children: [
                                            // Shop avatar
                                            Container(
                                              width: 56.w,
                                              height: 56.w,
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(12.r),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.black.withOpacity(0.1),
                                                    blurRadius: 8,
                                                    offset: Offset(0, 2),
                                                  ),
                                                ],
                                              ),
                                              child: ClipRRect(
                                                borderRadius: BorderRadius.circular(12.r),
                                                child: CachedNetworkImage(
                                                  imageUrl: shopModel.shopAvatarImageUrl,
                                                  fit: BoxFit.cover,
                                                  placeholder: (context, url) => Container(
                                                    color: Color(0XFF363062).withOpacity(0.1),
                                                    child: Icon(
                                                      Icons.store,
                                                      color: Color(0XFF363062),
                                                      size: 24.sp,
                                                    ),
                                                  ),
                                                  errorWidget: (context, url, error) => Container(
                                                    color: Color(0XFF363062).withOpacity(0.1),
                                                    child: Icon(
                                                      Icons.store,
                                                      color: Color(0XFF363062),
                                                      size: 24.sp,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),

                                            SizedBox(width: 16.w),

                                            // Shop info
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    shopModel.shopName,
                                                    style: TextStyle(
                                                      fontWeight: FontWeight.bold,
                                                      color: Color(0XFF111827),
                                                      fontSize: 16.sp,
                                                    ),
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                  SizedBox(height: 4.h),
                                                  Row(
                                                    children: [
                                                      Icon(
                                                        Icons.location_on_outlined,
                                                        size: 14.sp,
                                                        color: Color(0xFF6B7280),
                                                      ),
                                                      SizedBox(width: 4.w),
                                                      Expanded(
                                                        child: Text(
                                                          shopModel.location.address,
                                                          style: TextStyle(
                                                            color: Color(0xFF6B7280),
                                                            fontSize: 13.sp,
                                                          ),
                                                          maxLines: 1,
                                                          overflow: TextOverflow.ellipsis,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  SizedBox(height: 2.h),
                                                  Container(
                                                    padding: EdgeInsets.symmetric(
                                                      horizontal: 8.w,
                                                      vertical: 2.h,
                                                    ),
                                                    decoration: BoxDecoration(
                                                      color: Color(0XFF363062).withOpacity(0.1),
                                                      borderRadius: BorderRadius.circular(8.r),
                                                    ),
                                                    child: Text(
                                                      'Barbershop',
                                                      style: TextStyle(
                                                        color: Color(0XFF363062),
                                                        fontSize: 11.sp,
                                                        fontWeight: FontWeight.w500,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),

                                            // Arrow icon
                                            Container(
                                              padding: EdgeInsets.all(8.w),
                                              decoration: BoxDecoration(
                                                color: Color(0XFF363062).withOpacity(0.1),
                                                borderRadius: BorderRadius.circular(8.r),
                                              ),
                                              child: Icon(
                                                Icons.arrow_forward_ios_rounded,
                                                size: 14.sp,
                                                color: Color(0XFF363062),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
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

  Future<String> getRate(String idShop) async {
    final docRef = FirebaseFirestore.instance.collection('RatingShops').doc(idShop);
    final docSnapshot = await docRef.get();
    final data = docSnapshot.data();
    final quantity = data?['quantity'] ?? 0;
    final rating = data?['rating'] ?? 0.0;
    return '${double.parse(rating.toString())} ($quantity)';
  }
}