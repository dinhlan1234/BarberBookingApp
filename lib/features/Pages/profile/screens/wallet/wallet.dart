import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:testrunflutter/core/widgets/TextBasic.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:testrunflutter/data/firebase/FireStore.dart';
import 'package:testrunflutter/data/models/UserModel.dart';
import 'package:testrunflutter/features/Pages/profile/cubit/money/MoneyCubit.dart';
import 'package:testrunflutter/features/Pages/profile/cubit/money/MoneyState.dart';
import 'package:testrunflutter/features/Pages/profile/screens/wallet/History/Page/HistoryPage.dart';
import 'package:testrunflutter/features/Pages/profile/screens/wallet/Transaction/Page/TransactionPage.dart';
import 'package:testrunflutter/features/Pages/profile/screens/wallet/wallet_qrCode.dart';

class Wallet extends StatefulWidget {
  const Wallet({super.key});

  @override
  State<Wallet> createState() => _WalletState();
}

class _WalletState extends State<Wallet> {
  FireStoreDatabase dtb = FireStoreDatabase();
  UserModel? user;


  @override
  void initState() {
    super.initState();
    getUser();
  }

  Future<void> getUser() async {
    final data = await dtb.getUserByEmail();
    setState(() {
      user = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return BlocProvider(
      create: (context) => MoneyCubit(userId: user!.id),
      child: Scaffold(
        backgroundColor: const Color(0xFF363062),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.arrow_back),
            color: Colors.white,
          ),
          title: customText(
            text: 'Ví của bạn',
            color: Colors.white,
            fonSize: 16.sp,
            fonWeight: FontWeight.bold,
          ),
        ),
        extendBodyBehindAppBar: true,
        body: Stack(
          children: [
            Positioned.fill(
              child: Image.asset('assets/icons/setIcon.png', fit: BoxFit.cover),
            ),

            SafeArea(
              child: Column(
                children: [
                  customText(
                    text: 'Tài khoản chính',
                    color: Colors.white,
                    fonSize: 16.sp,
                    fonWeight: FontWeight.normal,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      BlocBuilder<MoneyCubit, MoneyState>(
                        builder: (context, state) {
                          String money = state.money;
                          List<String> parts = money.split('.');
                          final intMoney = int.tryParse(parts[0]) ?? 0;
                          final formatted = NumberFormat.decimalPattern(
                            'vi',
                          ).format(intMoney);
                          return customText(
                            text: formatted,
                            color: Colors.white,
                            fonSize: 17.sp,
                            fonWeight: FontWeight.bold,
                          );
                        },
                      ),

                      SizedBox(width: 2.w),
                      Baseline(
                        baseline: 16,
                        baselineType: TextBaseline.alphabetic,
                        child: customText(
                          text: 'đ',
                          color: Colors.white,
                          fonSize: 14.sp,
                          fonWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  Container(
                    padding: EdgeInsets.symmetric(
                      vertical: 15.h,
                      horizontal: 40.w,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.07),
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        GestureDetector(
                          onTap: () async {
                            _showInputAmountDialog(context);
                          },
                          child: Column(
                            children: [
                              Icon(
                                Icons.wallet,
                                size: 30.r,
                                color: const Color(0xFFFFD700),
                              ),
                              customText(
                                text: 'Nạp tiền',
                                color: Colors.white,
                                fonSize: 16.sp,
                                fonWeight: FontWeight.bold,
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 50.w),
                        GestureDetector(
                          onTap: () {},
                          child: Column(
                            children: [
                              Icon(
                                Icons.wallet_membership_sharp,
                                size: 30.r,
                                color: Colors.amberAccent.shade200,
                              ),
                              customText(
                                text: 'Rút tiền',
                                color: Colors.white,
                                fonSize: 16.sp,
                                fonWeight: FontWeight.bold,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            /// Phần dưới cùng
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: MediaQuery.of(context).size.height * 0.66,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(24.r),
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: 15.h,
                    horizontal: 15.w,
                  ),
                  child: Column(
                    children: [
                      _customElevatedButton('Giao dịch', () {
                        Navigator.push(context, PageRouteBuilder(pageBuilder: (context, animation, secondaryAnimation)
                        => TransactionPage(userId: user!.id),
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
                      SizedBox(height: 15.h),
                      _customElevatedButton('Lịch sử nạp rút tiền', () {
                        Navigator.push(context, PageRouteBuilder(pageBuilder: (context, animation, secondaryAnimation)
                        => HistoryPage(id: user!.id),
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
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _customElevatedButton(String name, VoidCallback onTab) {
    return ElevatedButton(
      onPressed: onTab,
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 15.w),
        backgroundColor: const Color(0xFFF1F4F8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          customText(
            text: name,
            color: const Color(0xFF111827),
            fonSize: 16.sp,
            fonWeight: FontWeight.bold,
          ),
          const Icon(Icons.keyboard_arrow_right),
        ],
      ),
    );
  }

  void _showInputAmountDialog(BuildContext context) {
    final TextEditingController _amountController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nhập số tiền'),
        content: TextField(
          controller: _amountController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(hintText: 'VD: 100000'),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Đóng dialog
            },
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () async {
              final text = _amountController.text.trim();
              if (text.isNotEmpty && int.tryParse(text) != null) {
                final random = Random();
                final authNum = 10000 + random.nextInt(90000);
                final amount = int.parse(text);
                user = (await dtb.getUserByEmail())!;
                Navigator.pop(context); // Đóng dialog
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => QRCode(
                      amount: amount,
                      description: 'naptien$authNum ${user!.id}',
                    ),
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Vui lòng nhập số hợp lệ')),
                );
              }
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
