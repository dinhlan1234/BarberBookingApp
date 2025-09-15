import 'package:flutter/material.dart';
import 'package:testrunflutter/core/helper/aleart.dart';
import 'package:testrunflutter/core/widgets/TextBasic.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:testrunflutter/data/firebase/FireStore.dart';

class SecurityPage extends StatefulWidget {
  const SecurityPage({super.key});

  @override
  State<SecurityPage> createState() => _SecurityPageState();
}

class _SecurityPageState extends State<SecurityPage> {
  FireStoreDatabase dtb = FireStoreDatabase();
  bool _obscurePassword1 = true;
  bool _obscurePassword2 = true;
  TextEditingController oldPasswordController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
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
          text: 'Đổi mật khẩu',
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
              customText(text: 'Nhập mật khẩu cũ', color: Color(0xFF111827), fonSize: 16.sp, fonWeight: FontWeight.bold),
              SizedBox(height: 5.h,),
              TextField(
                controller: oldPasswordController,
                decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    prefixIcon: Icon(Icons.key,color: Color(0XFF363062)),
                    hintText: '******',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r)
                    )
                ),
              ),
              SizedBox(height: 10.h,),
              customText(text: 'Nhập mật khẩu mới', color: Color(0xFF111827), fonSize: 16.sp, fonWeight: FontWeight.bold),
              SizedBox(height: 5.h,),
              _buildPasswordField(true),
              SizedBox(height: 10.h,),
              customText(text: 'Xác nhận mật khẩu mới', color: Color(0xFF111827), fonSize: 16.sp, fonWeight: FontWeight.bold),
              SizedBox(height: 5.h,),
              _buildPasswordField(false),
              SizedBox(height: 20.h,),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                    onPressed: () async{
                      changePw(oldPasswordController.text, passwordController.text,confirmPasswordController.text);
                    },
                    style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 10.h),
                        backgroundColor: Color(0xFF363062),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.r)
                        )
                    ),
                    child: customText(text: 'Lưu', color: Colors.white, fonSize: 16.sp, fonWeight: FontWeight.bold)),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordField(bool isFirstField) {
    bool obscureText = isFirstField ? _obscurePassword1 : _obscurePassword2;
    return TextField(
      controller: isFirstField ? passwordController : confirmPasswordController,
      obscureText: obscureText,
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.vpn_key, color: Color(0xFF363062)),
        suffixIcon: IconButton(
          icon: Icon(
            obscureText ? Icons.visibility_off : Icons.visibility,
            color: Colors.grey,
          ),
          onPressed: () {
            setState(() {
              if (isFirstField) {
                _obscurePassword1 = !_obscurePassword1;
              } else {
                _obscurePassword2 = !_obscurePassword2;
              }
            });
          },
        ),
        hintText: "********",
        filled: true,
        fillColor: Colors.white,
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Future<void> changePw(String oldPw, String newPw,String confirmNewPw) async{
    showDialog(context: context, barrierDismissible: false, builder: (context) => const Center(child: CircularProgressIndicator(),));
    if(newPw != confirmNewPw){
      displayMessageToUser(context, 'Mật khẩu nhập lại không đúng', isSuccess: false, onOk: () {
        Navigator.pop(context);
      });
    }else{
      final String? check = await dtb.changePassword(oldPw, newPw);
      if(check == null){
        if(context.mounted){
          displayMessageToUser(context, 'Thay đổi mật khẩu thành công', isSuccess: true, onOk: () {
            Navigator.pop(context);
            Navigator.pop(context);
          });
        }
      }else if(check == 'Không có người dùng đăng nhập'){
        displayMessageToUser(context, 'Có lỗi, vui lòng thử lại sau', isSuccess: false, onOk: () {
          Navigator.pop(context);
        });
      }else if(check == 'Mật khẩu cũ không đúng'){
        displayMessageToUser(context, 'Mật khẩu cũ không chính xác', isSuccess: false, onOk: () {
          Navigator.pop(context);
        });
      }else if(check == 'Mật khẩu mới quá yếu'){
        displayMessageToUser(context, 'Mật khẩu mới phải có ít nhất 6 k tự', isSuccess: false, onOk: () {
          Navigator.pop(context);
        });
      }else{
        displayMessageToUser(context,  'Mật khẩu cũ không chính xác', isSuccess: false, onOk: () {
          Navigator.pop(context);
        });
      }
    }
  }
}
