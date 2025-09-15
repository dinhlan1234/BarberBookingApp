import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:testrunflutter/core/notification/Notification.dart';
import 'package:testrunflutter/core/widgets/TextBasic.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:testrunflutter/data/firebase/FireStore.dart';
import 'package:testrunflutter/data/models/UserModel.dart';
import 'package:testrunflutter/data/repositories/prefs/UserPrefsService.dart';
import 'package:testrunflutter/data/repositories/services/FCMService.dart';
import 'package:testrunflutter/features/Auth/authPage.dart';
import 'package:testrunflutter/features/Pages/profile/cubit/City/CityCubit.dart';
import 'package:testrunflutter/features/Pages/profile/cubit/City/CityState.dart';
import 'package:testrunflutter/features/Pages/profile/cubit/information/InformationCubit.dart';
import 'package:testrunflutter/features/Pages/profile/cubit/information/InformationState.dart';
import 'package:testrunflutter/features/Pages/profile/screens/about/AboutPage.dart';
import 'package:testrunflutter/features/Pages/profile/screens/account/AccountPage.dart';
import 'package:testrunflutter/features/Pages/profile/screens/editProfile.dart';
import 'package:testrunflutter/features/Pages/profile/screens/help/HelpPage.dart';
import 'package:testrunflutter/features/Pages/profile/screens/level/pages/level_page.dart';
import 'package:testrunflutter/features/Pages/profile/screens/registrationForm/form1Page.dart';
import 'package:testrunflutter/features/Pages/profile/screens/security/SecurityPage.dart';
import 'package:testrunflutter/features/Pages/profile/screens/wallet/wallet.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  UserModel? _userModel;
  FireStoreDatabase dtb = FireStoreDatabase();
  bool isOn = false;
  InformationCubit? _informationCubit;

  @override
  void initState() {
    super.initState();
    _fetchUser();
  }

  Future<void> _fetchUser() async {
    final userData = await UserPrefsService.getUser();
    if (userData != null) {
      setState(() {
        _userModel = userData;
        _informationCubit = InformationCubit(id: _userModel!.id);
      });
    } else {
      final newData = await dtb.getUserByEmail();
      setState(() {
        _userModel = newData;
        _informationCubit = InformationCubit(id: _userModel!.id);
      });
    }
  }

  @override
  void dispose() {
    _informationCubit?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF363062),
      body: SafeArea(
        child: Stack(
          children: [
            // ảnh nền
            SizedBox(
              width: double.infinity,
              child: Image.asset('assets/icons/setIcon.png', fit: BoxFit.cover),
            ),
            Padding(
              padding: EdgeInsets.all(12.r),
              child: Column(
                children: [
                  // profile and logo
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      customText(text: 'Profile', color: Colors.white, fonSize: 16.sp, fonWeight: FontWeight.bold,),
                      Image.asset('assets/logos/logov1.png'),
                    ],
                  ),
                  SizedBox(height: 16.h),
                  // phần thông tin phái trên
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _userModel == null || _informationCubit == null
                          ? const Center(child: CircularProgressIndicator())
                          : Expanded(
                              child: BlocProvider.value(
                                value: _informationCubit!,
                                child: BlocBuilder<InformationCubit, InformationState>(
                                  builder: (context, state) {
                                    if (state is InformationLoading) {
                                      return CircularProgressIndicator();
                                    } else if (state is InformationLoaded) {
                                      final user = state.user;
                                      return Row(
                                        children: [
                                          CircleAvatar(
                                            backgroundImage:
                                                user.avatarUrl == '0'
                                                ? AssetImage(
                                                    'assets/images/avtMacDinh.jpg',
                                                  )
                                                : CachedNetworkImageProvider(
                                                    user.avatarUrl,
                                                  ),
                                            radius: 32.r,
                                          ),
                                          SizedBox(width: 10.w),
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              GestureDetector(
                                                onTap: () {
                                                  Navigator.push(context, PageRouteBuilder(
                                                    pageBuilder: (context, animation, secondaryAnimation,) => const LevelPage(),
                                                      transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                                            const begin = Offset(0.0, 1.0,); // Bắt đầu bên phải màn hình
                                                            const end = Offset.zero; // Kết thúc ở vị trí hiện tại
                                                            final tween = Tween(begin: begin,end: end,);
                                                            final curvedAnimation = CurvedAnimation(parent: animation, curve: Curves.ease,);
                                                            return SlideTransition(position: tween.animate(curvedAnimation,),
                                                              child: child,
                                                            );
                                                          },
                                                      transitionDuration: const Duration(milliseconds: 1000,), // thời gian chuyển cảnh
                                                    ),
                                                  );
                                                },
                                                child: Container(
                                                  padding: EdgeInsets.symmetric(horizontal: 5.w,),
                                                  decoration: BoxDecoration(
                                                    color: Color(0xFFF99417),
                                                    shape: BoxShape.rectangle,
                                                    borderRadius: BorderRadius.circular(20.r,),
                                                  ),
                                                  child: Row(
                                                    children: [
                                                      Image.asset('assets/level/medal.png',),
                                                      customText(text: 'Platinum', color: Colors.white, fonSize: 12.sp, fonWeight: FontWeight.normal),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              SizedBox(height: 5.h),
                                              Row(
                                                children: [
                                                  SizedBox(width: 5.w),
                                                  customText(text: user.name, color: Colors.white, fonSize: 16.sp, fonWeight: FontWeight.bold,
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ],
                                      );
                                    } else if (state is InformationError) {
                                      return Text(state.message);
                                    } else {
                                      return Text('Không xác định');
                                    }
                                  },
                                ),
                              ),
                            ),
                      IconButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            PageRouteBuilder(
                              pageBuilder:
                                  (context, animation, secondaryAnimation) =>
                                      const EditProfile(),
                              transitionsBuilder:
                                  (
                                    context,
                                    animation,
                                    secondaryAnimation,
                                    child,
                                  ) {
                                    const begin = Offset(
                                      1.0,
                                      0.0,
                                    ); // Bắt đầu bên phải màn hình
                                    const end = Offset
                                        .zero; // Kết thúc ở vị trí hiện tại
                                    final tween = Tween(begin: begin, end: end);
                                    final curvedAnimation = CurvedAnimation(
                                      parent: animation,
                                      curve: Curves.ease,
                                    );

                                    return SlideTransition(
                                      position: tween.animate(curvedAnimation),
                                      child: child,
                                    );
                                  },
                              transitionDuration: const Duration(
                                milliseconds: 1000,
                              ), // thời gian chuyển cảnh
                            ),
                          );
                        },
                        icon: Icon(CupertinoIcons.pencil_circle_fill),
                        color: Colors.white,
                      ),
                    ],
                  ),
                  SizedBox(height: 20.h),
                  // phần email và vị trí
                  Row(
                    children: [
                      Icon(Icons.email, color: Colors.white),
                      SizedBox(width: 5.w),
                      _userModel == null
                          ? Center(child: CircularProgressIndicator())
                          : customText(
                              text: _userModel!.email,
                              color: Colors.white,
                              fonSize: 13.sp,
                              fonWeight: FontWeight.bold,
                            ),
                    ],
                  ),
                  SizedBox(height: 3.h),
                  Row(
                    children: [
                      Icon(Icons.location_on_rounded, color: Colors.white),
                      SizedBox(width: 5.w),
                      _userModel == null
                          ? customText(text: '', color: Colors.white, fonSize: 14.sp, fonWeight: FontWeight.normal)
                          : customText(text: _userModel!.provinceName, color: Colors.white, fonSize: 13.sp, fonWeight: FontWeight.bold,)
                    ],
                  ),
                ],
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: MediaQuery.of(context).size.height * 0.60,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(24.r),
                  ),
                ),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 15.h, horizontal: 15.w,),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        customText(text: 'Cài đặt', color: Color(0xFF8683A1), fonSize: 14.sp, fonWeight: FontWeight.normal,
                        ),
                        SizedBox(height: 10.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            customText(text: 'Thông báo', color: Color(0xFF363062), fonSize: 16.sp, fonWeight: FontWeight.normal,
                            ),
                            Switch(
                              value: isOn,
                              onChanged: (value) {
                                setState(() {
                                  isOn = value;
                                });
                              },
                              activeColor: Color(0xFF363062),
                              // màu nút gạt khi bật
                              inactiveThumbColor: Color(0xFF363062),
                              // màu nút gạt khi tắt
                              inactiveTrackColor:
                                  Colors.white, // màu nền khi tắt
                            ),
                          ],
                        ),
                        SizedBox(height: 5.h),
                        Container(
                          height: 1.h,
                          width: double.infinity,
                          color: Color(0xFFF4F4F5),
                        ),
                        _customActionButton('Tài khoản', () async {
                          Navigator.push(context, PageRouteBuilder(pageBuilder: (context, animation, secondaryAnimation) => const AccountPage(),
                              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                    const begin = Offset(1.0, 0.0,); // Bắt đầu bên phải màn hình
                                    const end = Offset.zero; // Kết thúc ở vị trí hiện tại
                                    final tween = Tween(begin: begin, end: end);
                                    final curvedAnimation = CurvedAnimation(parent: animation, curve: Curves.ease,);
                                    return SlideTransition(position: tween.animate(curvedAnimation), child: child,);
                                  },
                              transitionDuration: const Duration(milliseconds: 1000,), // thời gian chuyển cảnh
                          ),);
                        }),
                        _customActionButton('Ví của bạn', () {
                          Navigator.push(context, PageRouteBuilder(pageBuilder: (context, animation, secondaryAnimation) => const Wallet(),
                              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                    const begin = Offset(1.0, 0.0,); // Bắt đầu bên phải màn hình
                                    const end = Offset.zero; // Kết thúc ở vị trí hiện tại
                                    final tween = Tween(begin: begin, end: end);
                                    final curvedAnimation = CurvedAnimation(parent: animation, curve: Curves.ease,);
                                    return SlideTransition(position: tween.animate(curvedAnimation), child: child,);
                                  },
                              transitionDuration: const Duration(milliseconds: 1000,), // thời gian chuyển cảnh
                            ),
                          );
                        }),
                        _customActionButton('Bảo mật', () {
                          Navigator.push(context, PageRouteBuilder(pageBuilder: (context, animation, secondaryAnimation) => const SecurityPage(),
                            transitionsBuilder: (context, animation, secondaryAnimation, child,) {
                                    const begin = Offset(1.0, 0.0,); // Bắt đầu bên phải màn hình
                                    const end = Offset.zero; // Kết thúc ở vị trí hiện tại
                                    final tween = Tween(begin: begin, end: end);
                                    final curvedAnimation = CurvedAnimation(parent: animation, curve: Curves.ease,);
                                    return SlideTransition(position: tween.animate(curvedAnimation), child: child,);
                                  },
                              transitionDuration: const Duration(milliseconds: 1000,), // thời gian chuyển cảnh
                            ),
                          );
                        }),
                        _customActionButton('Chăm sóc khách hàng', () {
                          Navigator.push(context, PageRouteBuilder(pageBuilder: (context, animation, secondaryAnimation) => const HelpPage(),
                            transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                    const begin = Offset(1.0, 0.0,); // Bắt đầu bên phải màn hình
                                    const end = Offset.zero; // Kết thúc ở vị trí hiện tại
                                    final tween = Tween(begin: begin, end: end);
                                    final curvedAnimation = CurvedAnimation(parent: animation, curve: Curves.ease,);
                                    return SlideTransition(position: tween.animate(curvedAnimation), child: child,);
                                  },
                              transitionDuration: const Duration(milliseconds: 1000,), // thời gian chuyển cảnh
                            ),
                          );
                        }),
                        _customActionButton('Về chúng tôi', () async {
                          bool success = await FCMService.sendFCMNotification(
                            title: 'Chào mừng!',
                            body: 'Bạn có thông báo mới.',
                            fcmToken: 'e15Oz2tzSz2sa0TZomajlm:APA91bEnR-KXogpCrQqpH9ssowKGCiTTAJ9EH5lNVveJ6EIBgkMy-zwgOY_hu59TGdim0VH_0qenokrcncx8k0gQMgliwZAq1AMc0_t-52nU-tzfWlrtIWc', // Token của device nhận
                          );
                          if (success) {
                            print('Gửi thành công');
                          }
                          // Navigator.push(context, PageRouteBuilder(pageBuilder: (context, animation, secondaryAnimation) => const AboutPage(),
                          //     transitionsBuilder: (context, animation, secondaryAnimation, child,) {
                          //           const begin = Offset(1.0, 0.0,); // Bắt đầu bên phải màn hình
                          //           const end = Offset.zero; // Kết thúc ở vị trí hiện tại
                          //           final tween = Tween(begin: begin, end: end);
                          //           final curvedAnimation = CurvedAnimation(
                          //             parent: animation,
                          //             curve: Curves.ease,
                          //           );
                          //           return SlideTransition(position: tween.animate(curvedAnimation), child: child,
                          //           );
                          //         },
                          //     transitionDuration: const Duration(milliseconds: 1000,), // thời gian chuyển cảnh
                          //   ),
                          // );
                        }),
                        _customActionButton('Đăng ký doanh nghiệp', (){
                          Navigator.push(context, PageRouteBuilder(pageBuilder: (context, animation, secondaryAnimation) => const Form1Page(),
                            transitionsBuilder: (context, animation, secondaryAnimation, child,) {
                              const begin = Offset(1.0, 0.0,); // Bắt đầu bên phải màn hình
                              const end = Offset.zero; // Kết thúc ở vị trí hiện tại
                              final tween = Tween(begin: begin, end: end);
                              final curvedAnimation = CurvedAnimation(
                                parent: animation,
                                curve: Curves.ease,
                              );
                              return SlideTransition(position: tween.animate(curvedAnimation), child: child,
                              );
                            },
                            transitionDuration: const Duration(milliseconds: 1000,), // thời gian chuyển cảnh
                          ),
                          );
                        }),
                        SizedBox(height: 10.h),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () async {
                              showDialog(context: context, barrierDismissible: false, builder: (context) => const Center(child: CircularProgressIndicator(),),);
                              await UserPrefsService.clear();
                              if (context.mounted) {
                                Navigator.pop(context);
                                _signOut();
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.symmetric(vertical: 10.h),
                              backgroundColor: Color(0xFF363062),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                            ),
                            child: customText(text: 'Đăng xuất', color: Colors.white, fonSize: 16.sp, fonWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _customActionButton(String name, VoidCallback onPressed) {
    return Column(
      children: [
        InkWell(
          onTap: onPressed,
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 14.h),
            width: double.infinity,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                customText(text: name, color: Color(0xFF363062), fonSize: 16.sp, fonWeight: FontWeight.normal,
                ),
                Icon(Icons.navigate_next, color: Color(0xFF8683A1)),
              ],
            ),
          ),
        ),
        Container(
          height: 1.h,
          width: double.infinity,
          color: const Color(0xFFF4F4F5),
        ),
      ],
    );
  }

  Future<void> _signOut() async {
    try {
      await dtb.signOut();
      if (context.mounted) {
        print('Navigating to Authpage after sign out');
        Navigator.pushAndRemoveUntil(
          context,
          PageRouteBuilder(pageBuilder: (context, animation, secondaryAnimation) => const Authpage(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
                  return SlideTransition(
                    position: animation.drive(
                      Tween(begin: const Offset(1.0, 0.0), end: Offset.zero),
                    ),
                    child: child,
                  );
                },
            transitionDuration: const Duration(milliseconds: 1000),
          ),
          (Route<dynamic> route) => false, // Xóa toàn bộ stack
        );
      }
    } catch (e) {
      print('Error signing out: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Đã xảy ra lỗi khi đăng xuất: $e')),
        );
      }
    }
  }
}
