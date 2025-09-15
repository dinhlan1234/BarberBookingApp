import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:testrunflutter/core/widgets/TextBasic.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:testrunflutter/data/firebase/FireStore.dart';
import 'package:testrunflutter/data/repositories/services/TelegramService.dart';
import 'package:testrunflutter/features/Pages/profile/screens/wallet/wallet.dart';

class QRCode extends StatefulWidget {
  final int amount;
  final String description;

  const QRCode({super.key, required this.amount, required this.description});

  @override
  State<QRCode> createState() => _QRCodeState();
}

class _QRCodeState extends State<QRCode> {
  TelegramServices tele = TelegramServices();
  FireStoreDatabase dtb = FireStoreDatabase();
  late Future<String> url;

  @override
  void initState() {
    super.initState();
    url = _createQRCode();
  }

  Future<String> _createQRCode() async {
    final bankId = 'mbbank';
    final stk = '2806201009';
    return "https://img.vietqr.io/image/$bankId-$stk-compact2.png"
        "?amount=${widget.amount}&addInfo=${widget.description}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // hoặc màu nền khác bạn muốn
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back),
          color: Colors.black,
        ),
        title: customText(
          text: 'Mã QR thanh toán',
          color: Colors.black,
          fonSize: 16.sp,
          fonWeight: FontWeight.bold,
        ),
      ),
      extendBodyBehindAppBar: true,
      body: Padding(
        padding: EdgeInsets.only(top: 80.h), // Đẩy xuống dưới AppBar
        child: Center(
          child: FutureBuilder<String>(
            future: url,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              } else if (snapshot.hasError) {
                return Text("Lỗi tạo mã QR: ${snapshot.error}");
              } else if (snapshot.hasData) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    customText(
                      text: "Quét mã để thanh toán",
                      color: Colors.black,
                      fonSize: 16.sp,
                      fonWeight: FontWeight.normal,
                    ),
                    SizedBox(height: 5.h),
                    Text(
                      '❗Vui lòng nhập đúng nội dung và giá tiền theo mã QR. Phát hiện chỉnh sửa sẽ trừ 20% số tiền',
                      style: TextStyle(
                      color: Colors.red,
                      fontSize: 14.sp,
                      ),
                      textAlign: TextAlign.center, // canh giữa từng dòng
                      maxLines: null, // không giới hạn số dòng
                      overflow: TextOverflow.visible, // cho phép xuống dòng mềm
                      softWrap: true, // không cắt bớt nội dung
                    ),
                    SizedBox(height: 20.h),
                    Image.network(
                      snapshot.data!,
                      width: 250.w,
                      height: 250.w,
                      fit: BoxFit.cover,
                    ),
                    SizedBox(height: 20.h),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        Future.delayed(const Duration(seconds: 5), () {
                          getRecentTransactions();
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                          vertical: 7.h,
                          horizontal: 20.w,
                        ),
                        backgroundColor: Color(0xFF363062),
                      ),
                      child: customText(
                        text: 'Xác nhận đã thanh toán',
                        color: Colors.white,
                        fonSize: 16.sp,
                        fonWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                );
              }
              return const Text("Không có dữ liệu");
            },
          ),
        ),
      ),
    );
  }

  Future<void> getRecentTransactions() async {
    final accountNumber = '2806201009';
    final url = Uri.parse(
      'https://my.sepay.vn/userapi/transactions/list?account_number=$accountNumber&limit=10',
    );

    final response = await http.get(
      url,
      headers: {
        'Authorization':
            'Bearer XJ775I43YAGDGDFHYQKJNPOIK0LXZBPQCA18BLLCFASCEWVJZNV8PSTDDMOVH349',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final String time = getCurrentDateTime();
      final data = jsonDecode(response.body);
      final transactions = data['transactions'] as List;
      bool check = false;
      for (var transaction in transactions) {
        final String money = transaction['amount_in'];
        final List<String> splitMoney = money.split('.');

        String content = transaction['transaction_content'];

        List<String> contentParts = content.split(RegExp(r'[\s\-\.]'));
        List<String> contentSplit = widget.description.split(' ');
        if (contentParts.contains(contentSplit[0]) &&
            contentParts.contains(contentSplit[1])) {
          try {
            await dtb.rechargeUser(money, contentSplit[1]);
            tele.sendMessage(
              '$time - ${widget.description} - ${splitMoney[0]}',
            );
            check = true;
          } on FirebaseException catch (e) {
            print(e.message);
            tele.sendMessage('❌ Chưa xử lý');
          }
        }
      }
      if (!check) {
        tele.sendMessage('$time - ${widget.description} - ${widget.amount}');
        Future.delayed(const Duration(seconds: 3), () {
          tele.sendMessage('❌ Chưa xử lý');
        });
      } else {
        Future.delayed(const Duration(seconds: 3), () {
          tele.sendMessage('✅ Đã xử lý');
        });
      }
    } else {
      Future.delayed(const Duration(seconds: 5), () {
        tele.sendMessage('❗Lỗi khi gửi tin nhắn');
      });
    }
  }

  String getCurrentDateTime() {
    final now = DateTime.now();
    final formatted =
        '${now.day.toString().padLeft(2, '0')}/'
        '${now.month.toString().padLeft(2, '0')}/'
        '${now.year} '
        '${now.hour.toString().padLeft(2, '0')}:'
        '${now.minute.toString().padLeft(2, '0')}:'
        '${now.second.toString().padLeft(2, '0')}';
    return formatted;
  }
}
