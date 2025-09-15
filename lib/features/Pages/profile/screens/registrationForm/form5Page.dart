import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:testrunflutter/core/helper/aleart.dart';
import 'package:testrunflutter/core/widgets/Main_bottom_nav.dart';
import 'package:testrunflutter/core/widgets/TextBasic.dart';
import 'package:testrunflutter/data/firebase/FireStore.dart';
import 'package:testrunflutter/data/models/BankInfoModel.dart';
import 'package:testrunflutter/data/models/LocationModel.dart';
import 'package:testrunflutter/data/models/cccdModel.dart';
import 'package:testrunflutter/features/Pages/profile/screens/ProfilePage.dart';

class Form5Page extends StatefulWidget {
  final Map<String, dynamic> tempData;
  const Form5Page({super.key, required this.tempData});

  @override
  State<Form5Page> createState() => _Form5PageState();
}

class _Form5PageState extends State<Form5Page> {
  final List<String> bankNames = [
    'Ngân hàng Vietcombank',
    'Ngân hàng BIDV',
    'Ngân hàng VietinBank',
    'Ngân hàng Agribank',
    'Ngân hàng ACB',
    'Ngân hàng Techcombank',
    'Ngân hàng MB Bank',
    'Ngân hàng VPBank',
    'Ngân hàng Sacombank',
    'Ngân hàng TPBank',
    'Ngân hàng SHB',
    'Ngân hàng VIB',
    'Ngân hàng HDBank',
    'Ngân hàng Eximbank',
    'Ngân hàng SeABank',
    'Ngân hàng Nam Á Bank',
    'Ngân hàng OCB',
    'Ngân hàng SCB',
    'Ngân hàng ABBank',
    'Ngân hàng LienVietPostBank',
    'Ngân hàng Maritime Bank',
    'Ngân hàng Bắc Á Bank',
    'Ngân hàng PVcomBank',
    'Ngân hàng BaoViet Bank',
    'Ngân hàng VietBank',
  ];
  FireStoreDatabase dtb = FireStoreDatabase();

  String? selectedBank;
  final TextEditingController accountIdController = TextEditingController();
  final TextEditingController ownerNameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back),
          color: const Color(0xFF111827),
        ),
        title: customText(
          text: 'Đăng ký doanh nghiệp',
          color: const Color(0xFF111827),
          fonSize: 16.sp,
          fonWeight: FontWeight.bold,
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(20.r),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF363062), Color(0xFF4C4C7D)],
                ),
                borderRadius: BorderRadius.circular(16.r),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF363062).withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8.r),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Icon(
                      Icons.account_balance,
                      color: Colors.white,
                      size: 24.sp,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        customText(
                          text: 'Thông tin thanh toán',
                          color: Colors.white,
                          fonSize: 16.sp,
                          fonWeight: FontWeight.bold,
                        ),
                        SizedBox(height: 4.h),
                        customText(
                            text: 'Vui lòng cung cấp thông tin tài khoản ngân hàng',
                            color: Colors.white.withOpacity(0.8),
                            fonSize: 12.sp,
                            fonWeight: FontWeight.normal
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16.h),
            buildBankDropdown(),
            SizedBox(height: 16.h),
            buildInputField("Số tài khoản", accountIdController, TextInputType.number,Icons.credit_card),
            SizedBox(height: 16.h),
            buildInputField("Tên chủ tài khoản", ownerNameController,TextInputType.text,Icons.person,),
            SizedBox(height: 30.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async{
                  if(await _onContinue()){
                    displayMessageToUser(context, 'Gửi đơn thành công, vui lòng chờ hệ thống xác nhận đơn',isSuccess: true,onOk: (){
                      Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (context)=> MainNavigationScreen(initialIndex: 3,)),
                          (Route<dynamic> route) => false
                      );
                    });
                  }else{
                    displayMessageToUser(context, 'Có lỗi trong lúc gửi đơn vui lòng liên hệ 0832235031 để được xử lý',isSuccess: false,onOk: (){Navigator.pop(context);});
                  }
                },
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  backgroundColor: const Color(0xFF363062),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                ),
                child: customText(
                  text: 'Tiếp',
                  color: Colors.white,
                  fonSize: 16.sp,
                  fonWeight: FontWeight.bold,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget buildBankDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        customText(text: "Ngân hàng", color: const Color(0xFF111827), fonSize: 14.sp, fonWeight: FontWeight.w500,),
        SizedBox(height: 6.h),
        DropdownButtonFormField<String>(
          value: selectedBank,
          items: bankNames.map((bank) {
            return DropdownMenuItem(value: bank, child: Text(bank),);
          }).toList(),
          onChanged: (value) {
            setState(() {
              selectedBank = value;
            });
          },
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
            prefixIcon: Container(
              padding: EdgeInsets.all(12.r),
              child: Icon(Icons.account_balance, color: const Color(0xFF363062), size: 20.sp,),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16.r),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16.r),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16.r),
              borderSide: BorderSide(color: const Color(0xFF363062), width: 2,),
            ),
            hintText: 'Chọn ngân hàng của bạn',
            hintStyle: TextStyle(
              color: Colors.grey[500],
              fontSize: 14.sp,
            ),
          ),
          dropdownColor: Colors.white,
          icon: Icon(
            Icons.keyboard_arrow_down,
            color: const Color(0xFF363062),
            size: 24.sp,
          ),
          menuMaxHeight: 300.h,
          isExpanded: true,
        ),
      ],
    );
  }

  Widget buildInputField(String label, TextEditingController controller, TextInputType inputType,IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 4.w, bottom: 8.h),
          child: customText(text: label, color: const Color(0xFF374151), fonSize: 14.sp, fonWeight: FontWeight.w600,),
        ),
        SizedBox(height: 6.h),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: controller,
            keyboardType: inputType,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              prefixIcon: Container(
                padding: EdgeInsets.all(12.r),
                child: Icon(icon, color: const Color(0xFF363062), size: 20.sp,),
              ),
              hintText: 'Nhập $label',
              hintStyle: TextStyle(
                color: Colors.grey[500],
                fontSize: 14.sp,
              ),
              contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16.r),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16.r),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16.r),
                borderSide: BorderSide(
                  color: const Color(0xFF363062),
                  width: 2,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<bool> _onContinue() async{
    showDialog(context: context, builder: (context)=> Center(child: CircularProgressIndicator(),));
    if (selectedBank == null || accountIdController.text.isEmpty || ownerNameController.text.isEmpty) {
      displayMessageToUser(context, 'Vui lòng nhập đầy đủ thông tin thanh toán',isSuccess: false,onOk: (){Navigator.pop(context);});
      return false;
    }

    try{
      final bankModel = BankInfoModel(
          bankName: selectedBank!,
          accountNumber: accountIdController.text.trim(),
          ownerName: ownerNameController.text.trim()
      );
      final locationModel = LocationModel(
          widget.tempData['provinceName'],
          widget.tempData['provinceCode'],
          widget.tempData['districtName'],
          widget.tempData['wardName'],
          widget.tempData['address'],
          double.parse(widget.tempData['lat']),
          double.parse(widget.tempData['long'])
      );
      final cccdModel = CccdModel(
          widget.tempData['cccd'],
          widget.tempData['urlFront'],
          widget.tempData['urlBackSide']
      );

      await dtb.registerShop(
          widget.tempData['shopName'],
          widget.tempData['ownerName'],
          widget.tempData['email'],
          widget.tempData['phone'],
          widget.tempData['shopAvatarImageUrl'],
          widget.tempData['backgroundImageUrl'],
          locationModel,
          widget.tempData['openHour'],
          widget.tempData['closeHour'],
          widget.tempData['openDays'],
          cccdModel,
          widget.tempData['licenseImage'],
          bankModel
      );
      return true;
    }catch(e){
      print(e);
      return false;
    }


  }
}
