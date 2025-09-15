import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:testrunflutter/core/helper/aleart.dart';
import 'package:testrunflutter/data/models/UserModel.dart';
import 'package:vietnam_provinces/vietnam_provinces.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  String provinceCode = '';
  Province? selectedProvince;
  List<Province> provinces = [];

  bool _obscurePassword1 = true;
  bool _obscurePassword2 = true;
  bool _isPhoneValid = false;
  String _phoneNumber = '';
  TextEditingController nameController =TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passWordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();

  Future<void> _loadProvinces() async {
    final data = await VietnamProvinces.getProvinces();
    setState(() {
      provinces = data;
    });
  }
  @override
  void initState() {
    super.initState();
    _loadProvinces();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 32.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Register here",
                style: TextStyle(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF363062),
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                "Please enter your data to complete your\naccount registration process",
                style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
              ),
              SizedBox(height: 24.h),

              // Name
              Text("Name", style: _labelStyle()),
              SizedBox(height: 6.h),
              _buildTextField("Joe Samanta", Icons.person,nameController),

              SizedBox(height: 16.h),

              // Email
              Text("Email", style: _labelStyle()),
              SizedBox(height: 6.h),
              _buildTextField("Joesamanta@gmail.com", Icons.email,emailController),

              SizedBox(height: 16.h),

              // Province
              Text("Chọn tỉnh/thành phố đang ở", style: _labelStyle()),
              SizedBox(height: 6.h,),
              DropdownButton<Province>(
                isExpanded: true,
                hint: const Text(
                  'Tỉnh/Thành',
                  style: TextStyle(
                    fontSize: 16.0,
                    color: Colors.grey,
                  ),
                ),
                value: selectedProvince,
                items: provinces.map((province) {
                  return DropdownMenuItem<Province>(
                    value: province,
                    child: Text(
                      province.name,
                      style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedProvince = value;
                  });
                  if (value != null) {
                    provinceCode = value.code.toString();
                  }
                },
                style: TextStyle(
                  fontSize: 16.0,
                  color: Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
                dropdownColor: Colors.white,
                icon: const Icon(Icons.arrow_drop_down, color: Colors.black87, size: 30.0),
                underline: Container(
                  height: 2.0,
                  color: Colors.grey.shade400,
                ),
                elevation: 8,
                padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                borderRadius: BorderRadius.circular(12.0),
              ),
              SizedBox(height: 16.h),

              // Phone
              Text("Phone number", style: _labelStyle()),
              SizedBox(height: 6.h),
              _buildPhoneField(),

              SizedBox(height: 16.h),

              // Password
              Text("Create password", style: _labelStyle()),
              SizedBox(height: 6.h),
              _buildPasswordField(true),

              SizedBox(height: 16.h),

              // Confirm Password
              Text("Confirm password", style: _labelStyle()),
              SizedBox(height: 6.h),
              _buildPasswordField(false),

              SizedBox(height: 32.h),

              // Register button
              SizedBox(
                width: double.infinity,
                height: 50.h,
                child: ElevatedButton(
                  onPressed: () {
                    registerUser();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF363062),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  child: Text("Register", style: TextStyle(color: Colors.white,fontSize: 16.sp)),
                ),
              ),

              SizedBox(height: 24.h),

              // Login
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Already have an account?"),
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: const Text(
                      " Login",
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
    );
  }

  Widget _buildTextField(String hint, IconData icon,TextEditingController controller) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: const Color(0xFF363062)),
        hintText: hint,
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

  Widget _buildPasswordField(bool isFirstField) {
    bool obscureText = isFirstField ? _obscurePassword1 : _obscurePassword2;
    return TextField(
      controller: isFirstField ? passWordController : confirmPasswordController,
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

  Widget _buildPhoneField() {
    return Row(
      children: [
        Container(
          width: 60.w,
          height: 50.h,
          padding: EdgeInsets.symmetric(horizontal: 8.w),
          decoration: BoxDecoration(
            color: const Color(0XFFD1D5DB),
            borderRadius: BorderRadius.horizontal(left: Radius.circular(10.r)),
            border: Border.all(color: Colors.transparent),
          ),
          child: Center(
            child: Text("+84", style: TextStyle(fontSize: 16.sp)),
          ),
        ),
        Expanded(
          child: Container(
            height: 50.h,
            padding: EdgeInsets.only(left: 8.w,top: 4.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius:
              BorderRadius.horizontal(right: Radius.circular(10.r)),
            ),
            child: TextField(
              keyboardType: TextInputType.phone,
              onChanged: (value){
                setState(() {
                  _phoneNumber = value;
                  _isPhoneValid = _validateVietnamesePhone(value);
                });
              },
              decoration: InputDecoration(
                hintText: "832235031",
                suffixIcon:
                Icon(
                    Icons.check_circle,
                    color: _isPhoneValid ? Colors.green : Colors.grey
                ),
                border: InputBorder.none,
              ),
            ),
          ),
        ),
      ],
    );
  }
  bool _validateVietnamesePhone(String phone) {
    final regex = RegExp(r'^(3|5|7|8|9)\d{8}$');
    return regex.hasMatch(phone);
  }
  bool isValidEmail(String email) {
    final regex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return regex.hasMatch(email);
  }

  TextStyle _labelStyle() {
    return TextStyle(
      fontSize: 14.sp,
      fontWeight: FontWeight.w500,
      color: Colors.grey[800],
    );
  }

  Future<void> registerUser() async {
    showDialog(context: context, barrierDismissible: false, builder: (context) => const Center(child: CircularProgressIndicator(),));
    if(!_isPhoneValid){
      displayMessageToUser(context, 'Định dạng số điện thoại không đúng',isSuccess: false,onOk: (){
        Navigator.pop(context);
      });
      return;
    }
    if(passWordController.text != confirmPasswordController.text){
      displayMessageToUser(context, 'Mật khẩu nhập lại không đúng',isSuccess: false,onOk: (){
        Navigator.pop(context);
      });
      return;
    }
    if(!isValidEmail(emailController.text)){
      displayMessageToUser(context, 'Định dạng email không đúng',isSuccess: false,onOk: (){
        Navigator.pop(context);
      });
      return;
    }
    if(passWordController.text.length < 6){
      displayMessageToUser(context, 'Mật khẩu ít nhất 6 ký tự',isSuccess: false,onOk: (){
        Navigator.pop(context);
      });
      return;
    }
    if(provinceCode == ''){
      displayMessageToUser(context, 'Vui lòng chọn tỉnh/thành phố đang ở',isSuccess: false,onOk: (){
        Navigator.pop(context);
      });
      return;
    }
    try{
      UserCredential? userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(email: emailController.text, password: passWordController.text);
      if (context.mounted) {
        Navigator.pop(context);
        displayMessageToUser(context, 'Tạo tài khoản thành công', isSuccess: true, onOk: () {
          Navigator.pop(context); // Về màn hình trước
        });
      }
      createUserDocument(userCredential);
    } on FirebaseAuthException catch (e){
      displayMessageToUser(context, '$e',isSuccess: false,onOk: (){Navigator.pop(context);});
      print('Lỗi: $e');
    }

  }
  Future<void> createUserDocument(UserCredential? userCredential) async{
    if(userCredential != null && userCredential.user != null){
      String email = userCredential.user!.email!;
      final docRef= FirebaseFirestore.instance.collection('Users').doc();
      String randomId = docRef.id;
      String today = getCurrentDate();
      final user = UserModel(randomId, nameController.text, email, _phoneNumber,selectedProvince!.name, provinceCode, '0', '0', today, 'Client','0');
      await docRef.set(user.toJson());
    }
  }
  String getCurrentDate() {
    final now = DateTime.now();
    final formatter = DateFormat('dd/MM/yyyy');
    return formatter.format(now);
  }
}
