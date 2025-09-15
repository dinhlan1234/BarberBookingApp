import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:testrunflutter/core/helper/aleart.dart';
import 'package:testrunflutter/core/widgets/TextBasic.dart';
import 'package:testrunflutter/data/repositories/services/CloudinaryService.dart';
import 'package:testrunflutter/features/Pages/profile/screens/registrationForm/form5Page.dart';

class Form4Page extends StatefulWidget {
  final Map<String,dynamic> tempData;
  const Form4Page({super.key,required this.tempData});

  @override
  State<Form4Page> createState() => _Form4PageState();
}

class _Form4PageState extends State<Form4Page> {
  File? cccdFrontImage;
  File? cccdBackImage;
  File? businessDocImage;
  File? shopAvatarImage;
  File? backgroundImage;

  // Lưu URL sau khi upload
  String? cccdFrontImageUrl;
  String? cccdBackImageUrl;
  String? businessDocImageUrl;
  String? shopAvatarImageUrl;
  String? backgroundImageUrl;

  // Trạng thái upload cho từng ảnh
  bool isUploadingCccdFront = false;
  bool isUploadingCccdBack = false;
  bool isUploadingBusinessDoc = false;
  bool isUploadingShopAvatar = false;
  bool isUploadingBackground = false;

  final ImagePicker _picker = ImagePicker();
  final CloudinarySignedUploader _uploader = CloudinarySignedUploader();

  Future<void> _pickAndUploadImage(Function(File) onPicked, Function(String) onUploaded, Function(bool) setUploading) async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final file = File(pickedFile.path);
      onPicked(file);

      // Upload ngay sau khi pick
      setUploading(true);
      try {
        final url = await _uploader.uploadImage(file);
        onUploaded(url.toString());
      } catch (e) {
        if (mounted) {
          displayMessageToUser(context, 'Lỗi khi tải ảnh: $e', isSuccess: false);
        }
      } finally {
        setUploading(false);
      }
    }
  }

  Widget buildImageSection(String label, List<File?> images, List<String?> imageUrls, List<bool> uploadingStates, List<VoidCallback> onPickCallbacks) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: customText(
              text: label,
              color: const Color(0xFF111827),
              fonSize: 14.sp,
              fonWeight: FontWeight.bold,
            ),
          ),
          Expanded(
            flex: 7,
            child: Wrap(
              spacing: 10.w,
              runSpacing: 10.h,
              children: List.generate(images.length, (index) {
                return GestureDetector(
                  onTap: uploadingStates[index] ? null : onPickCallbacks[index], // Disable khi đang upload
                  child: Container(
                    width: 100.w,
                    height: 100.w,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: imageUrls[index] != null ? Colors.green : Colors.grey,
                        width: imageUrls[index] != null ? 2 : 1,
                      ),
                      borderRadius: BorderRadius.circular(8.r),
                      image: images[index] != null
                          ? DecorationImage(
                        image: FileImage(images[index]!),
                        fit: BoxFit.cover,
                      )
                          : null,
                    ),
                    child: Stack(
                      children: [
                        if (images[index] == null)
                          const Center(
                            child: Icon(Icons.add_a_photo, color: Colors.grey),
                          ),
                        if (uploadingStates[index])
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.black54,
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            child: const Center(
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            ),
                          ),
                        if (imageUrls[index] != null && !uploadingStates[index])
                          Positioned(
                            top: 5,
                            right: 5,
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: const BoxDecoration(
                                color: Colors.green,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildBackgroundSection() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: customText(
              text: "Ảnh bìa Shop",
              color: const Color(0xFF111827),
              fonSize: 14.sp,
              fonWeight: FontWeight.bold,
            ),
          ),
          Expanded(
            flex: 7,
            child: Center(
              child: GestureDetector(
                onTap: isUploadingBackground
                    ? null
                    : () => _pickAndUploadImage(
                      (file) => setState(() => backgroundImage = file),
                      (url) => setState(() => backgroundImageUrl = url),
                      (uploading) => setState(() => isUploadingBackground = uploading),
                ),
                child: Container(
                  width: double.infinity,
                  height: 120.h,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: backgroundImageUrl != null ? Colors.green : Colors.grey,
                      width: backgroundImageUrl != null ? 3 : 2,
                    ),
                    borderRadius: BorderRadius.circular(12.r),
                    image: backgroundImage != null
                        ? DecorationImage(
                      image: FileImage(backgroundImage!),
                      fit: BoxFit.cover,
                    )
                        : null,
                  ),
                  child: Stack(
                    children: [
                      if (backgroundImage == null)
                        const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.landscape, color: Colors.grey, size: 40),
                              SizedBox(height: 8),
                              Text(
                                'Thêm ảnh bìa',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      if (isUploadingBackground)
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: const Center(
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          ),
                        ),
                      if (backgroundImageUrl != null && !isUploadingBackground)
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.green,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool get allImagesUploaded {
    return cccdFrontImageUrl != null &&
        cccdBackImageUrl != null &&
        businessDocImageUrl != null &&
        shopAvatarImageUrl != null &&
        backgroundImageUrl != null;
  }

  bool get anyImageUploading {
    return isUploadingCccdFront ||
        isUploadingCccdBack ||
        isUploadingBusinessDoc ||
        isUploadingShopAvatar ||
        isUploadingBackground;
  }

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
        padding: EdgeInsets.all(12.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildAvatarSection(),
            SizedBox(height: 20.h),
            buildBackgroundSection(),
            SizedBox(height: 20.h),
            buildImageSection(
              "Hình ảnh 2 mặt căn cước công dân",
              [cccdFrontImage, cccdBackImage],
              [cccdFrontImageUrl, cccdBackImageUrl],
              [isUploadingCccdFront, isUploadingCccdBack],
              [
                    () => _pickAndUploadImage(
                      (file) => setState(() => cccdFrontImage = file),
                      (url) => setState(() => cccdFrontImageUrl = url),
                      (uploading) => setState(() => isUploadingCccdFront = uploading),
                ),
                    () => _pickAndUploadImage(
                      (file) => setState(() => cccdBackImage = file),
                      (url) => setState(() => cccdBackImageUrl = url),
                      (uploading) => setState(() => isUploadingCccdBack = uploading),
                ),
              ],
            ),
            SizedBox(height: 20.h),
            buildImageSection(
              "Giấy tờ đăng ký kinh doanh",
              [businessDocImage],
              [businessDocImageUrl],
              [isUploadingBusinessDoc],
              [
                    () => _pickAndUploadImage(
                      (file) => setState(() => businessDocImage = file),
                      (url) => setState(() => businessDocImageUrl = url),
                      (uploading) => setState(() => isUploadingBusinessDoc = uploading),
                ),
              ],
            ),
            SizedBox(height: 20.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: allImagesUploaded && !anyImageUploading ? _navigateToNextPage : null,
                style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 10.h),
                    backgroundColor: allImagesUploaded && !anyImageUploading
                        ? Color(0xFF363062)
                        : Colors.grey,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.r),
                    )
                ),
                child: customText(
                  text: anyImageUploading
                      ? 'Đang tải ảnh...'
                      : allImagesUploaded
                      ? 'Tiếp'
                      : 'Vui lòng tải đầy đủ ảnh',
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

  void _navigateToNextPage() {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => Form5Page(
          tempData: {
            ...widget.tempData,
            'urlFront': cccdFrontImageUrl!,
            'urlBackSide': cccdBackImageUrl!,
            'licenseImage': businessDocImageUrl!,
            'shopAvatarImageUrl': shopAvatarImageUrl!,
            'backgroundImageUrl': backgroundImageUrl!,
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
        transitionDuration: const Duration(milliseconds: 1000),
      ),
    );
  }

  Widget buildAvatarSection() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: customText(
              text: "Avatar Shop",
              color: const Color(0xFF111827),
              fonSize: 14.sp,
              fonWeight: FontWeight.bold,
            ),
          ),
          Expanded(
            flex: 7,
            child: Center(
              child: GestureDetector(
                onTap: isUploadingShopAvatar
                    ? null
                    : () => _pickAndUploadImage(
                      (file) => setState(() => shopAvatarImage = file),
                      (url) => setState(() => shopAvatarImageUrl = url),
                      (uploading) => setState(() => isUploadingShopAvatar = uploading),
                ),
                child: Container(
                  width: 120.w,
                  height: 120.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: shopAvatarImageUrl != null ? Colors.green : Colors.grey,
                      width: shopAvatarImageUrl != null ? 3 : 2,
                    ),
                    image: shopAvatarImage != null
                        ? DecorationImage(
                      image: FileImage(shopAvatarImage!),
                      fit: BoxFit.cover,
                    )
                        : null,
                  ),
                  child: Stack(
                    children: [
                      if (shopAvatarImage == null)
                        const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.store, color: Colors.grey, size: 40),
                              SizedBox(height: 8),
                              Text(
                                'Thêm avatar',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      if (isUploadingShopAvatar)
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            shape: BoxShape.circle,
                          ),
                          child: const Center(
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          ),
                        ),
                      if (shopAvatarImageUrl != null && !isUploadingShopAvatar)
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.green,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}