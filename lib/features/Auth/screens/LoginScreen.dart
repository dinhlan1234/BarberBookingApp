import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:testrunflutter/core/helper/aleart.dart';
import 'package:testrunflutter/data/firebase/FireStore.dart';
import 'package:testrunflutter/data/models/UserModel.dart';
import 'package:testrunflutter/data/repositories/prefs/UserPrefsService.dart';
import 'package:testrunflutter/features/Auth/authPage.dart';
import 'package:testrunflutter/features/Auth/screens/ForgotPassword.dart';
import 'package:testrunflutter/features/Auth/screens/Register.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _obscurePassword = true;
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  FireStoreDatabase dtb = FireStoreDatabase();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: Image.asset("assets/images/login.png",
                fit: BoxFit.cover, width: 1.sw),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: double.infinity,
              height: 460.h,
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 19.h),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                  BorderRadius.vertical(top: Radius.circular(32.r))),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Welcome back 👋",
                          style: TextStyle(
                              fontSize: 28.sp,
                              fontWeight: FontWeight.bold,
                              color: Color(0XFF363062)),
                        ),
                        SizedBox(
                          height: 8.h,
                        ),
                        Text(
                          "Please enter your login information below to access your account",
                          style: TextStyle(
                              fontSize: 16.h, color: Color(0XFF6B7280)),
                        )
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 8.h,
                        ),
                        Text(
                          "UserName",
                          style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.bold,
                              color: const Color(0XFF111827)),
                        ),
                        SizedBox(
                          height: 5.h,
                        ),
                        TextField(
                          controller: emailController,
                          decoration: InputDecoration(
                              prefixIcon: const Icon(
                                  Icons.email_outlined,
                                  color: Color(0XFF363062)),
                              hintText: "dinhlan74qt@gmail.com",
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12.r)
                              )
                          ),
                        )
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 8.h,
                        ),
                        Text(
                          "PassWord",
                          style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.bold,
                              color: const Color(0XFF111827)),
                        ),
                        SizedBox(
                          height: 5.h,
                        ),
                        TextField(
                          controller: passwordController,
                          obscureText: _obscurePassword,
                          decoration: InputDecoration(
                              prefixIcon: const Icon(Icons.lock_outline_rounded,
                                  color: Color(0XFF363062)),
                              suffixIcon: IconButton(onPressed: (){
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                                icon:
                                _obscurePassword
                                    ? const Icon(Icons.visibility_off_outlined, color: Color(0XFF363062),)
                                    : const Icon(Icons.visibility, color: Color(0XFF363062),),
                              ),
                              hintText: "••••••••",
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12.r))),
                        )
                      ],
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                          onPressed: () {
                            Navigator.push(context, PageRouteBuilder(
                              pageBuilder: (context, animation, secondaryAnimation) => const ForgotPassword(),
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
                          },
                          child: const Text(
                            "Forgot password?",
                            style: TextStyle(
                              color: Color(0XFF363062),
                              fontWeight: FontWeight.bold,
                            ),
                          )),
                    ),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                          onPressed: () {
                            login();
                          },
                          style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0XFF363062),
                              padding: EdgeInsets.symmetric(vertical: 16.h),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.r))),
                          child: Text(
                            "Login",
                            style:
                            TextStyle(fontSize: 16.sp, color: Colors.white),
                          )),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          height: 40.h,
                        ),
                        Text(
                          "Don't have an account?",
                          style: TextStyle(
                              fontSize: 14.sp, color: const Color(0XFF6B7280)),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(context, PageRouteBuilder(
                              pageBuilder: (context, animation, secondaryAnimation) => const RegisterScreen(),
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
                          },
                          child: const Text(
                            " Register",
                            style: TextStyle(
                              color: Color(0xFF2E2157),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  Future<void> login() async{
    showDialog(context: context, barrierDismissible: false, builder: (context) => const Center(child: CircularProgressIndicator(),));
    if(emailController.text.isNotEmpty && passwordController.text.isNotEmpty ){
      try{
        final query = await FirebaseFirestore.instance.collection('Users').where('email',isEqualTo: emailController.text).limit(1).get();
        if(query.docs.isEmpty){
          displayMessageToUser(context, 'Không tìm thấy tài khoản này', isSuccess: false, onOk: () => Navigator.pop(context),);
          return;
        }
        final data = query.docs.first.data();
        final role = data['role'];
        if(role == 'Shop'){
          displayMessageToUser(context, 'Vui lòng đăng nhập tài khoản này ở app Shop GoBar', isSuccess: false, onOk: () => Navigator.pop(context),);
          return;
        }

        if(role == 'Client'){
          await FirebaseAuth.instance.signInWithEmailAndPassword(email: emailController.text, password: passwordController.text);

          UserModel? user = await dtb.getUserByEmail();
          if (user != null) {
            final result = await Future.wait([
              dtb.updateFcmToken(user.id),
              listenToken(user.id),
              UserPrefsService.saveUser(user)
            ]);
            // await dtb.updateFcmToken(user.id);
            // await UserPrefsService.saveUser(user);
          }
          if(context.mounted){
            Navigator.pop(context);
            Navigator.pushAndRemoveUntil(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) => const Authpage(),
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
        }


      } on FirebaseAuthException catch(e){
        print(e);
        if (context.mounted) {
          displayMessageToUser(
            context,
            'Tài khoản hoặc mật khẩu không đúng',
            isSuccess: false,
            onOk: () {
              Navigator.pop(context); // Tắt Alert Dialog khi nhấn OK
            },
          );
        }
      }
    }else {
      if (context.mounted) {
        displayMessageToUser(
          context,
          'Tài khoản hoặc mật khẩu không được để trống',
          isSuccess: false,
          onOk: () {
            Navigator.pop(context); // Chỉ tắt Alert Dialog
          },
        );
      }
    }

  }
  Future<void> listenToken(String id) async{
    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
      await FirebaseFirestore.instance
          .collection('Users')
          .doc(id)
          .update({'fcmToken': newToken});
    });
  }
}
