import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:testrunflutter/core/helper/aleart.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  TextEditingController emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 25.w),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Forgot password?",
                    style: TextStyle(
                        fontSize: 28.sp,
                        fontWeight: FontWeight.bold,
                        color: const Color(0XFF363062)),
                  ),
                  Text(
                    "Please enter your email for the password reset process",
                    style: TextStyle(
                        fontSize: 16.sp, color: const Color(0XFF6B7280)),
                  ),
                ],
              ),
              SizedBox(
                height: 32.h,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Email",
                    style: TextStyle(
                        fontSize: 14.sp, color: const Color(0XFF111827)),
                  ),
                  TextField(
                    controller: emailController,
                    decoration: InputDecoration(
                        prefixIcon: const Icon(
                          Icons.email_outlined,
                          color: Color(0XFF363062),
                        ),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.r))),
                  )
                ],
              ),
              SizedBox(
                height: 32.h,
              ),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                    onPressed: () async {
                      if(isValidEmail(emailController.text)){
                        showDialog(context: context, barrierDismissible: false, builder: (context) => const Center(child: CircularProgressIndicator(),));
                        final snapshot = await FirebaseFirestore.instance
                            .collection('Users')
                            .where('email', isEqualTo: emailController.text)
                            .get();
                        if (snapshot.docs.isNotEmpty) {
                          await FirebaseAuth.instance.sendPasswordResetEmail(email: emailController.text);
                          Navigator.pop(context);
                          displayMessageToUser(context, 'Gửi link đổi mật khẩu đến email thành công!!', isSuccess: true, onOk: () {
                            Navigator.pop(context);
                          });
                        } else {
                          displayMessageToUser(context, 'Không tìm thấy email!', isSuccess: false, onOk: () {
                            Navigator.pop(context);
                          });
                        }
                      }else{
                        showDialog(context: context, barrierDismissible: false, builder: (context) => const Center(child: CircularProgressIndicator(),));
                        displayMessageToUser(context, 'Định dạng email không chính xác!', isSuccess: false, onOk: () {
                          Navigator.pop(context);
                        });
                      }
                    },
                    style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r)),
                        backgroundColor: const Color(0XFF363062)),
                    child: Text(
                      "Send",
                      style: TextStyle(fontSize: 16.sp, color: Colors.white),
                    )),
              )
            ],
          ),
        ),
      ),
    );
  }

  Future<void> getRecentTransactions() async {
    final accountNumber = '2806201009';
    final url = Uri.parse(
      'https://my.sepay.vn/userapi/transactions/list?account_number=$accountNumber&limit=20',
    );

    final response = await http.get(url, headers: {
      'Authorization':
      'Bearer XJ775I43YAGDGDFHYQKJNPOIK0LXZBPQCA18BLLCFASCEWVJZNV8PSTDDMOVH349',
      'Content-Type': 'application/json',
    });

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final transactions = data['transactions'] as List;
      for (var i = 0; i < transactions.length; i++) {
        if (transactions[i]['transaction_content'] == "id17363601072025") {
          const url =
              'https://img.vietqr.io/image/MBBANK-2806201009-compact.png?amount=50000&addInfo=Thanh Toan Lucifer&accountName=NGUYEN%20DINH%20LAN';
          print('Ok');
        }
        print(
            'Danh sách noi dung giao dịch: ${transactions[i]['transaction_content']}');
      }
      // Giả sử data['transactions'] chứa danh sách giao dịch
    } else {
      print('Lỗi: ${response.statusCode} - ${response.body}');
    }
  }

  bool isValidEmail(String email) {
    final regex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return regex.hasMatch(email);
  }
}
