import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:testrunflutter/core/widgets/TextBasic.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:testrunflutter/data/firebase/FireStore.dart';
import 'package:testrunflutter/data/models/UserModel.dart';
import 'package:testrunflutter/data/repositories/prefs/UserPrefsService.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final dateController = TextEditingController();
  UserModel? _userModel;
  FireStoreDatabase dtb = FireStoreDatabase();
  Future<void> getUser() async{
    final dataUser = await UserPrefsService.getUser();
    if(dataUser != null){
      setState(() {
        _userModel = dataUser;
        emailController.text = _userModel!.email;
        phoneController.text = _userModel!.phone;
        dateController.text = _userModel!.creationDate;
      });
    }else{
      final newData = await dtb.getUserByEmail();
      setState(() {
        _userModel = newData;
      });
    }
  }

  @override
  void initState() {
    getUser();
    super.initState();
  }
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
          text: 'Tài khoản',
          color: Color(0xFF111827),
          fonSize: 16.sp,
          fonWeight: FontWeight.bold,
        ),
      ),
      body: SafeArea(
          child: SingleChildScrollView(
              child: Center(
                child: Column(
                  children: [
                    SizedBox(height: 10.h,),
                    CircleAvatar(
                      backgroundImage: _userModel != null
                          ? _userModel!.avatarUrl == '0'
                                ? AssetImage('assets/images/avtMacDinh.jpg')
                                : CachedNetworkImageProvider(_userModel!.avatarUrl)
                          : AssetImage('assets/images/avtMacDinh.jpg'),
                      radius: 60,
                    ),
                    SizedBox(height: 10.h,),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 5.w,
                          ),
                          decoration: BoxDecoration(
                            color: Color(0xFFF99417),
                            shape: BoxShape.rectangle,
                            borderRadius: BorderRadius.circular(20.r),
                          ),
                          child: Row(
                            children: [
                              Image.asset('assets/level/medal.png'),
                              customText(
                                text: 'Platinum',
                                color: Colors.white,
                                fonSize: 12.sp,
                                fonWeight: FontWeight.normal,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10.h,),
                    customText(text: _userModel != null ? _userModel!.name: '...', color: Color(0xFF363062), fonSize: 16.sp, fonWeight: FontWeight.bold),
                    _buildTextEdit('Email','abcz@gmail.com',Icons.email,false,emailController),
                    _buildTextEdit('Số điện thoại','0123456789',Icons.phone,false,phoneController),
                    _buildTextEdit('Ngày tạo tài khoản','28/06/2025',Icons.calendar_month,false,dateController),
                  ],
                ),
              )
          )
      ),
    );
  }
  Widget _buildTextEdit(String name,String hintText,IconData icon, bool change,TextEditingController controller){
    return Padding(padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          customText(text: name, color: Color(0xFF363062), fonSize: 14.sp, fonWeight: FontWeight.bold),
          SizedBox(height: 5.h,),
          TextField(
            controller: controller,
            decoration: InputDecoration(
                enabled: change,
                prefixIcon: Icon(icon,color: Color(0XFF363062)),
                hintText: hintText,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r)
                )
            ),
          ),
        ],
      ),
    );
  }
}

