import 'package:flutter/material.dart';
import 'package:testrunflutter/core/helper/aleart.dart';
import 'package:testrunflutter/core/widgets/TextBasic.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:testrunflutter/features/Pages/profile/screens/registrationForm/emailConfirmation.dart';
import 'package:testrunflutter/features/Pages/profile/screens/registrationForm/form2Page.dart';

class Form1Page extends StatefulWidget {
  const Form1Page({super.key});

  @override
  State<Form1Page> createState() => _Form1PageState();
}

class _Form1PageState extends State<Form1Page> {
  TextEditingController nameController = TextEditingController();
  TextEditingController cccdController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back),
          color: Color(0xFF111827),
        ),
        title: customText(
          text: 'Đăng ký doanh nghiệp',
          color: Color(0xFF111827),
          fonSize: 16.sp,
          fonWeight: FontWeight.bold,
        ),
      ),
      body: Padding(
          padding: EdgeInsets.all(12.r),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              customText(text: 'Thông tin cá nhân', color: Color(0xFF111827), fonSize: 16.sp, fonWeight: FontWeight.bold),
              SizedBox(height: 30.h,),
              customLabelAndTextField('Tên của bạn', nameController,false),
              SizedBox(height: 20.h,),
              customLabelAndTextField('Số căn cước công dân', cccdController,true),
              SizedBox(height: 20.h,),
              customLabelAndTextField('Email của bạn', emailController,false),
              SizedBox(height: 20.h,),
              customLabelAndTextField('Số điện thoại', phoneController,true),
              SizedBox(height: 20.h,),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                    onPressed: (){
                      showDialog(context: context,barrierDismissible: false, builder: (context) => Center(child: CircularProgressIndicator(),));
                      if(nameController.text == '' || cccdController.text == '' || emailController.text == '' || phoneController.text == ''){
                        displayMessageToUser(context, 'Vui lòng nhập đầy đủ thông tin',isSuccess: false, onOk: (){Navigator.pop(context);});
                      }else if(!isValidEmail(emailController.text)){
                        displayMessageToUser(context, 'Định dạng email không chính xác',isSuccess: false, onOk: (){Navigator.pop(context);});
                      }else if(!_validateVietnamesePhone(phoneController.text)){
                        displayMessageToUser(context, 'Định dạng số điện thoại không chính xác',isSuccess: false, onOk: (){Navigator.pop(context);});
                      }else if(!isCccd(cccdController.text)){
                        displayMessageToUser(context, 'Định dạng căn cước công dân không chính xác',isSuccess: false, onOk: (){Navigator.pop(context);});
                      }else{
                        if(context.mounted) Navigator.pop(context);
                        Navigator.push(context, PageRouteBuilder(pageBuilder: (context, animation, secondaryAnimation)
                        => EmailConfirmation(
                          tempData: {
                            'ownerName': nameController.text,
                            'cccd': cccdController.text,
                            'email': emailController.text,
                            'phone': phoneController.text
                          },
                        ),
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
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 10.h),
                      backgroundColor: Color(0xFF363062),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.r),
                      )
                    ),
                    child: customText(text: 'Tiếp', color: Colors.white, fonSize: 16.sp, fonWeight: FontWeight.bold)),
              )
            ],
          ),
        ),
      ),
    );
  }
  Widget customLabelAndTextField(String label,TextEditingController controller,bool check){
    return Column(
      children: [
        TextField(
          controller: controller,
          keyboardType: check ? TextInputType.number : TextInputType.text,
          decoration: InputDecoration(
            labelText: label,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12), // Bo tròn viền
            ),
            contentPadding: EdgeInsets.all(16),
          ),
        )
      ],
    );
  }
  bool isValidEmail(String email) {
    final regex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return regex.hasMatch(email);
  }
  bool _validateVietnamesePhone(String phone) {
    final regex = RegExp(r'^(0)(3|5|7|8|9)[0-9]{8}$');
    return regex.hasMatch(phone);
  }
  bool isCccd(String cccd){
    final regex = RegExp(r'^([0-9]{9}|[0-9]{12})$');
    return regex.hasMatch(cccd);
  }
}
