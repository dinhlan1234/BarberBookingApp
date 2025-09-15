import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:testrunflutter/core/helper/aleart.dart';
import 'package:testrunflutter/core/widgets/TextBasic.dart';
import 'package:testrunflutter/features/Pages/profile/screens/registrationForm/form3Page.dart';
import 'package:vietnam_provinces/vietnam_provinces.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class Form2Page extends StatefulWidget {
  final Map<String,dynamic> tempData;
  const Form2Page({super.key,required this.tempData});

  @override
  State<Form2Page> createState() => _Form2PageState();
}

class _Form2PageState extends State<Form2Page> {
  TextEditingController nameShopController = TextEditingController();
  // Text controllers
  final TextEditingController addressController = TextEditingController();
  final TextEditingController latitudeController = TextEditingController();
  final TextEditingController longitudeController = TextEditingController();

  // Location data
  List<Province> provinces = [];
  List<District> districts = [];
  List<Ward> wards = [];

  Province? selectedProvince;
  District? selectedDistrict;
  Ward? selectedWard;

  @override
  void initState() {
    super.initState();
    _loadProvinces();
  }

  Future<void> _loadProvinces() async {
    final data = await VietnamProvinces.getProvinces();
    setState(() {
      provinces = data;
    });
  }

  Future<void> _loadDistricts(int provinceCode) async {
    final data = await VietnamProvinces.getDistricts(provinceCode: provinceCode);
    setState(() {
      districts = data;
      selectedDistrict = null;
      wards = [];
      selectedWard = null;
    });
  }

  Future<void> _loadWards(int provinceCode, int districtCode) async {
    final data = await VietnamProvinces.getWards(
      provinceCode: provinceCode,
      districtCode: districtCode,
    );
    setState(() {
      wards = data;
      selectedWard = null;
    });
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
          text: 'Đăng ký doanh nghiệp',
          color: Color(0xFF111827),
          fonSize: 16.sp,
          fonWeight: FontWeight.bold,
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(12.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            customText(text: 'Thông tin địa chỉ quán', color: Color(0xFF111827), fonSize: 16.sp, fonWeight: FontWeight.bold),
            SizedBox(height: 20.h,),
            customLabelAndTextField('Tên quán', nameShopController),
            SizedBox(height: 15.h,),
            //lat long
            customText(text: 'Vui lòng đứng tại quán để lấy vị trí chính xác!', color: Colors.red, fonSize: 14.sp, fonWeight: FontWeight.bold),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    customText(text: 'Lat', color: Color(0xFF111827), fonSize: 14.sp, fonWeight: FontWeight.bold),
                    SizedBox(width: 10.w,),
                    SizedBox(
                      width: 70.w,
                      height: 40.h,
                      child: TextField(
                        controller: latitudeController,
                        enabled: false,
                        style: TextStyle(fontSize: 12.sp),
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.r), // Bo tròn viền
                          ),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                        ),
                      ),
                    )
                  ],
                ),
                Container(
                  height: 1.h,
                  width: 20.w,
                  color: Color(0xFF111827),
                ),
                Row(
                  children: [
                    customText(text: 'Long', color: Color(0xFF111827), fonSize: 14.sp, fonWeight: FontWeight.bold),
                    SizedBox(width: 10.w,),
                    SizedBox(
                      width: 70.w,
                      height: 40.h,
                      child: TextField(
                        controller: longitudeController,
                        enabled: false,
                        style: TextStyle(fontSize: 12.sp),
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.r), // Bo tròn viền
                          ),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),

                        ),
                      ),
                    )
                  ],
                ),
                ElevatedButton(
                    onPressed: () async{
                      await _getCurrentLocation();
                    },
                    style: ElevatedButton.styleFrom(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50.r)
                        )
                    ),
                    child: Icon(Icons.search_outlined))
              ],
            ),
            SizedBox(height: 15.h,),
            const Text('Chọn tỉnh/thành phố'),
            SizedBox(height: 5.h,),
            DropdownButton<Province>(
              isExpanded: true,
              hint: const Text('Tỉnh/Thành'),
              value: selectedProvince,
              items: provinces.map((province) {
                return DropdownMenuItem(
                  value: province,
                  child: Text(province.name),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedProvince = value;
                  selectedDistrict = null;
                  selectedWard = null;
                  districts = [];
                  wards = [];
                });
                if (value != null) {
                  _loadDistricts(value.code);
                }
              },
            ),
            SizedBox(height: 15.h),
            const Text('Chọn quận/huyện'),
            SizedBox(height: 5.h,),
            DropdownButton<District>(
              isExpanded: true,
              hint: const Text('Quận/Huyện'),
              value: selectedDistrict,
              items: districts.map((district) {
                return DropdownMenuItem(
                  value: district,
                  child: Text(district.name),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedDistrict = value;
                  selectedWard = null;
                  wards = [];
                });
                if (value != null && selectedProvince != null) {
                  _loadWards(selectedProvince!.code, value.code);
                }
              },
            ),
            SizedBox(height: 15.h),
            const Text('Chọn phường/xã'),
            SizedBox(height: 5.h,),
            DropdownButton<Ward>(
              isExpanded: true,
              hint: const Text('Phường/Xã'),
              value: selectedWard,
              items: wards.map((ward) {
                return DropdownMenuItem(
                  value: ward,
                  child: Text(ward.name),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedWard = value;
                });
              },
            ),

            SizedBox(height: 15.h),
            customLabelAndTextField('Địa chỉ quán', addressController),
            SizedBox(height: 20.h,),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                  onPressed: () async{
                    int? provinceCode = selectedProvince?.code;
                    if(validateForm() && context.mounted){
                      Navigator.pop(context);
                      Navigator.push(context, PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) => Form3Page(
                          tempData: {
                            'ownerName': widget.tempData['ownerName'],
                            'cccd': widget.tempData['cccd'],
                            'email': widget.tempData['email'],
                            'phone': widget.tempData['phone'],
                            'shopName': nameShopController.text,
                            'lat': latitudeController.text,
                            'long': longitudeController.text,
                            'provinceName': selectedProvince?.name,
                            'provinceCode': provinceCode.toString(),
                            'districtName': selectedDistrict?.name,
                            'wardName': selectedWard?.name,
                            'address': addressController.text
                          },
                        ),
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
    );
  }

  Widget customLabelAndTextField(String label,TextEditingController controller){
    return Column(
      children: [
        TextField(
          controller: controller,
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

  Future<void> _getCurrentLocation() async {
    showDialog(context: context,barrierDismissible: false, builder: (context) => Center(child: CircularProgressIndicator(),));
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng bật định vị GPS')),
      );
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Quyền truy cập vị trí bị từ chối')),
        );
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Quyền truy cập vị trí bị từ chối vĩnh viễn')),
      );
      return;
    }
    Navigator.pop(context);
    final position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    if(context.mounted){
      latitudeController.text = position.latitude.toString();
      longitudeController.text = position.longitude.toString();
    }
  }

  bool validateForm() {
    showDialog(context: context,barrierDismissible: false, builder: (context) => Center(child: CircularProgressIndicator(),));
    if (nameShopController.text.isEmpty) {
      showError('Vui lòng nhập tên quán');
      return false;
    } else if (latitudeController.text.isEmpty) {
      showError('Vui lòng nhấn tìm kiếm để lấy vị trí Lat');
      return false;
    } else if (longitudeController.text.isEmpty) {
      showError('Vui lòng nhấn tìm kiếm để lấy vị trí Long');
      return false;
    } else if (selectedProvince == null) {
      showError('Vui lòng chọn tỉnh/thành phố');
      return false;
    } else if (selectedDistrict == null) {
      showError('Vui lòng chọn quận/huyện');
      return false;
    } else if (selectedWard == null) {
      showError('Vui lòng chọn phường/xã');
      return false;
    } else if(addressController.text.isEmpty){
      showError('Vui lòng nhập địa chỉ chi tiết');
      return false;
    }
    return true;
  }

  void showError(String message) {
    displayMessageToUser(context, message, isSuccess: false, onOk: () {
      Navigator.pop(context);
    });
  }


}
