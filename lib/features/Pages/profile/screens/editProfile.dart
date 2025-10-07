import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:testrunflutter/core/widgets/TextBasic.dart';
import 'package:testrunflutter/data/firebase/FireStore.dart';
import 'package:testrunflutter/data/models/UserModel.dart';
import 'package:testrunflutter/data/repositories/prefs/UserPrefsService.dart';
import 'package:testrunflutter/data/repositories/services/CloudinaryService.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class EditProfile extends StatefulWidget {
  const EditProfile({super.key});

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  String? _avtUrl;
  final uploader = CloudinarySignedUploader();
  File? _imageFile;
  UserModel? _userModel;
  FireStoreDatabase dtb = FireStoreDatabase();

  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController dateController = TextEditingController();


  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }
  @override
  void initState() {
    super.initState();
    getUser();
  }

  Future<void> getUser() async{
    final dataUser = await UserPrefsService.getUser();
    if(dataUser != null){
      setState(() {
        _userModel = dataUser;
        nameController.text = _userModel!.name;
        emailController.text = _userModel!.email;
        phoneController.text = _userModel!.phone;
        dateController.text = _userModel!.creationDate;
        _avtUrl = _userModel!.avatarUrl;
      });
    }else{
      final newData = await dtb.getUserByEmail();
      if(newData != null){
        setState(() {
          _userModel = newData;
          nameController.text = _userModel!.name;
          emailController.text = _userModel!.email;
          phoneController.text = _userModel!.phone;
          dateController.text = _userModel!.creationDate;
        });
      }
    }
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
          text: 'Chỉnh sửa thông tin',
          color: Color(0xFF111827),
          fonSize: 16.sp,
          fonWeight: FontWeight.bold,
        ),
      ),
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              children: [
                SizedBox(height: 10.h,),
                CircleAvatar(
                  backgroundImage: _imageFile != null
                      ? FileImage(_imageFile!)
                      : _avtUrl != '0' && _avtUrl != null
                            ? CachedNetworkImageProvider(_avtUrl!)
                            : const AssetImage('assets/images/avtMacDinh.jpg'),
                  radius: 60,
                ),
                TextButton(
                  onPressed: _pickImage,
                  child: const Text(
                    'Chỉnh sửa ảnh đại diện mới',
                    style: TextStyle(color: Colors.blue),
                  ),
                ),
                _buildTextEdit('Tên của bạn','Nguyen Van A',Icons.person,true,nameController),
                _buildTextEdit('Email','abcz@gmail.com',Icons.email,false,emailController),
                _buildTextEdit('Số điện thoại','0123456789',Icons.phone,true,phoneController),
                _buildTextEdit('Ngày tạo tài khoản','28/06/2025',Icons.calendar_month,false,dateController),


                Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.h,horizontal: 8.w),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                        onPressed: () async{
                          saveUser();
                        },
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 10.h),
                          backgroundColor: Color(0xFF363062),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r)
                          )
                        ),
                        child: customText(text: 'Lưu', color: Colors.white, fonSize: 16.sp, fonWeight: FontWeight.bold),
                    ),
                  )
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
  Widget _buildTextEdit(String name,String hintText,IconData icon, bool change, TextEditingController controller){
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
  Future<void> saveUser() async{
    showDialog(context: context,barrierDismissible: false, builder: (context) => Center(child: CircularProgressIndicator(),));
    if(_imageFile != null){
      String? url = await uploader.uploadImage(_imageFile!);
      print('URL ảnh: $url');
      if(_userModel != null){
        final user = UserModel(_userModel!.id, nameController.text, emailController.text, phoneController.text,_userModel!.provinceName, _userModel!.provinceCode, _userModel!.money,  url.toString(),  _userModel!.creationDate, 'Client',_userModel!.fcmToken);
        await dtb.saveUser(user);
        if(context.mounted){
          Navigator.pop(context);
          Navigator.pop(context);
        }
      }
    }else{
      if(_userModel != null){
        final user = UserModel(_userModel!.id, nameController.text, emailController.text, phoneController.text,_userModel!.provinceName, _userModel!.provinceCode, _userModel!.money,  _userModel!.avatarUrl,  _userModel!.creationDate, 'Client',_userModel!.fcmToken);
        await dtb.saveUser(user);
        if(context.mounted){
          Navigator.pop(context);
          Navigator.pop(context);
        }
      }
    }
  }

}
