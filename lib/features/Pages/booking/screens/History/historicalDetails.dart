import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:testrunflutter/core/widgets/TextBasic.dart';
import 'package:testrunflutter/data/firebase/FireStore.dart';
import 'package:testrunflutter/data/models/BookingModel/BookingWithShop.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:testrunflutter/data/models/BookingModel/ReviewModel.dart';

class HistoryDetail extends StatefulWidget {
  final BookingWithShop booking;
  const HistoryDetail({super.key, required this.booking});

  @override
  State<HistoryDetail> createState() => _HistoryDetailState();
}

class _HistoryDetailState extends State<HistoryDetail> {
  double sliderValue = 1.0;
  bool _isLoading = false;
  bool _isShow = true;
  FireStoreDatabase dtb = FireStoreDatabase();
  final TextEditingController _commentController = TextEditingController();
  ReviewModel? _reviewModel;
  @override
  void initState() {
    super.initState();
    _reviewModel = widget.booking.booking.reviewModel;
    if(_reviewModel == null){
      _isShow = true;
    }else{
      _isShow = false;
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back),
          color: Color(0xFF363062),
        ),
        title: customText(
          text: 'Chi tiết lịch sử',
          color: Color(0xFF363062),
          fonSize: 16.sp,
          fonWeight: FontWeight.bold,
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Banner
            _buildStatusBanner(),

            SizedBox(height: 16.h),

            // Shop Information
            _buildShopInfo(),

            SizedBox(height: 16.h),

            // Booking Details
            _buildBookingDetails(),

            SizedBox(height: 16.h),

            // Services Information
            _buildServicesInfo(),

            SizedBox(height: 16.h),

            // Review Section (if exists)
              _buildReviewSection(widget.booking.booking.reviewModel),
            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBanner() {
    Color statusColor;
    IconData statusIcon;

    switch (widget.booking.booking.status) {
      case 'Hoàn thành1':
        statusColor = Colors.green;
        statusIcon = Icons.verified;
        break;
      case 'Hoàn thành2':
        statusColor = Colors.red;
        statusIcon = Icons.cancel;
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.help_outline;
    }

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: statusColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(statusIcon, color: statusColor, size: 24.sp),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                customText(
                  text: 'Trạng thái',
                  color: Colors.grey[600]!,
                  fonSize: 12.sp,
                  fonWeight: FontWeight.normal,
                ),
                customText(
                  text: widget.booking.booking.status == 'Hoàn thành1'
                      ? 'Hoàn thành'
                      :  widget.booking.booking.status == 'Hoàn thành2'
                      ? 'Đã hoàn thành đơn rủi ro'
                      : 'Rủi ro',
                  color: statusColor,
                  fonSize: 16.sp,
                  fonWeight: FontWeight.bold,
                ),
              ],
            ),
          ),
          customText(
            text: DateFormat('dd/MM/yyyy HH:mm').format(widget.booking.booking.time.toDate()),
            color: Colors.grey[600]!,
            fonSize: 12.sp,
            fonWeight: FontWeight.normal,
          ),
        ],
      ),
    );
  }

  Widget _buildShopInfo() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.store, color: Color(0xFF363062), size: 20.sp),
              SizedBox(width: 8.w),
              customText(
                text: 'Thông tin cửa hàng',
                color: Color(0xFF363062),
                fonSize: 16.sp,
                fonWeight: FontWeight.bold,
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8.r),
                child: CachedNetworkImage(
                  imageUrl: widget.booking.shop.shopAvatarImageUrl,
                  width: 60.w,
                  height: 60.w,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    width: 60.w,
                    height: 60.w,
                    color: Colors.grey[200],
                    child: Icon(Icons.store, color: Colors.grey[400]),
                  ),
                  errorWidget: (context, url, error) => Container(
                    width: 60.w,
                    height: 60.w,
                    color: Colors.grey[200],
                    child: Icon(Icons.store, color: Colors.grey[400]),
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    customText(
                      text: widget.booking.shop.shopName,
                      color: Color(0xFF111827),
                      fonSize: 16.sp,
                      fonWeight: FontWeight.bold,
                    ),
                    SizedBox(height: 4.h),
                    Row(
                      children: [
                        Icon(Icons.location_on, color: Colors.grey[600], size: 14.sp),
                        SizedBox(width: 4.w),
                        Expanded(
                          child: customText(
                            text: '${widget.booking.shop.location.address}, ${widget.booking.shop.location.wardName}',
                            color: Colors.grey[600]!,
                            fonSize: 12.sp,
                            fonWeight: FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 2.h),
                    Row(
                      children: [
                        Icon(Icons.phone, color: Colors.grey[600], size: 14.sp),
                        SizedBox(width: 4.w),
                        customText(
                          text: widget.booking.shop.phone,
                          color: Colors.grey[600]!,
                          fonSize: 12.sp,
                          fonWeight: FontWeight.normal,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBookingDetails() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.calendar_month, color: Color(0xFF363062), size: 20.sp),
              SizedBox(width: 8.w),
              customText(
                text: 'Chi tiết lịch hẹn',
                color: Color(0xFF363062),
                fonSize: 16.sp,
                fonWeight: FontWeight.bold,
              ),
            ],
          ),
          SizedBox(height: 12.h),

          _buildDetailRow('Mã lịch hẹn', widget.booking.booking.idSchedules),
          _buildDetailRow('Ngày đặt', widget.booking.booking.bookingDateModel.date),
          _buildDetailRow('Thời gian', widget.booking.booking.bookingDateModel.time),
          _buildDetailRow('Thứ', widget.booking.booking.bookingDateModel.weekdayName),

          SizedBox(height: 12.h),
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: Color(0xFF363062).withOpacity(0.05),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Row(
              children: [
                Icon(Icons.attach_money, color: Color(0xFF363062), size: 18.sp),
                SizedBox(width: 8.w),
                customText(
                  text: 'Tổng tiền: ${_calculateTotalPrice().toStringAsFixed(0)}đ',
                  color: Color(0xFF363062),
                  fonSize: 14.sp,
                  fonWeight: FontWeight.bold,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100.w,
            child: customText(
              text: label,
              color: Colors.grey[600]!,
              fonSize: 12.sp,
              fonWeight: FontWeight.normal,
            ),
          ),
          customText(
            text: ': ',
            color: Colors.grey[600]!,
            fonSize: 12.sp,
            fonWeight: FontWeight.normal,
          ),
          Expanded(
            child: customText(
              text: value,
              color: Color(0xFF111827),
              fonSize: 12.sp,
              fonWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServicesInfo() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.cut, color: Color(0xFF363062), size: 20.sp),
              SizedBox(width: 8.w),
              customText(
                text: 'Dịch vụ đã chọn',
                color: Color(0xFF363062),
                fonSize: 16.sp,
                fonWeight: FontWeight.bold,
              ),
            ],
          ),
          SizedBox(height: 12.h),

          ListView.separated(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: widget.booking.booking.servicesSelected.services.length,
            separatorBuilder: (context, index) => SizedBox(height: 12.h),
            itemBuilder: (context, index) {
              final service = widget.booking.booking.servicesSelected.services[index];
              return Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6.r),
                      child: CachedNetworkImage(
                        imageUrl: service.avatarUrl,
                        width: 40.w,
                        height: 40.w,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          width: 40.w,
                          height: 40.w,
                          color: Colors.grey[200],
                          child: Icon(Icons.cut, color: Colors.grey[400], size: 20.sp),
                        ),
                        errorWidget: (context, url, error) => Container(
                          width: 40.w,
                          height: 40.w,
                          color: Colors.grey[200],
                          child: Icon(Icons.cut, color: Colors.grey[400], size: 20.sp),
                        ),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          customText(
                            text: service.name,
                            color: Color(0xFF111827),
                            fonSize: 14.sp,
                            fonWeight: FontWeight.bold,
                          ),
                          if (service.note.isNotEmpty)
                            customText(
                              text: service.note,
                              color: Colors.grey[600]!,
                              fonSize: 12.sp,
                              fonWeight: FontWeight.normal,
                            ),
                        ],
                      ),
                    ),
                    customText(
                      text: '${service.price.toStringAsFixed(0)}đ',
                      color: Color(0xFF363062),
                      fonSize: 14.sp,
                      fonWeight: FontWeight.bold,
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildReviewSection(ReviewModel? review) {
    if(review != null){
     setState(() {
       sliderValue = review.rating;
       _commentController.text = review.comment;
     });
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        customText(
          text: 'Đánh giá của quán',
          color: Color(0XFF111827),
          fonSize: 14.sp,
          fonWeight: FontWeight.bold,
        ),
        SizedBox(height: 10.h),

        // Stars hiển thị
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Icon(Icons.star, color: sliderValue >= 1 ? Color(0XFFF99417) : Color(0XFFE5E7EB), size: 32.r),
            Icon(Icons.star, color: sliderValue >= 2 ? Color(0XFFF99417) : Color(0XFFE5E7EB), size: 32.r),
            Icon(Icons.star, color: sliderValue >= 3 ? Color(0XFFF99417) : Color(0XFFE5E7EB), size: 32.r),
            Icon(Icons.star, color: sliderValue >= 4 ? Color(0XFFF99417) : Color(0XFFE5E7EB), size: 32.r),
            Icon(Icons.star, color: sliderValue == 5 ? Color(0XFFF99417) : Color(0XFFE5E7EB), size: 32.r),
            SizedBox(width: 5.w),
            customText(
              text: '($sliderValue)',
              color: Color(0XFF363062),
              fonSize: 12.sp,
              fonWeight: FontWeight.normal,
            ),
          ],
        ),

        // Slider chọn số sao
        review == null ? SizedBox(
          width: 270.w,
          child: Slider(
            value: sliderValue,
            min: 1.0,
            max: 5.0,
            divisions: 4,
            onChanged: (value) {
              setState(() {
                sliderValue = value;
              });
            },
          ),
        ) : SizedBox(),

        SizedBox(height: 10.h),

        // Label
        customText(
          text: 'Ghi ý kiến của bạn:',
          color: Color(0XFF111827),
          fonSize: 14.sp,
          fonWeight: FontWeight.bold,
        ),
        SizedBox(height: 8.h),
        TextField(
          controller: _commentController,
          maxLines: 3,
          readOnly: !_isShow,
          decoration: InputDecoration(
            hintText: "Nhập ý kiến tại đây...",
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
            ),
            contentPadding: EdgeInsets.all(12.w),
          ),
        ),
        SizedBox(height: 8.h),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
              onPressed: _isShow ? () async{
                final review = ReviewModel(userId: widget.booking.booking.idUser, shopId: widget.booking.booking.idShop, rating: sliderValue, comment: _commentController.text , time: Timestamp.now());
                setState(() {
                  _isLoading = true;
                });
                if(await dtb.review(widget.booking.booking, review)){
                  setState(() {
                    _isLoading = false;
                    _isShow = false;
                  });
                }
              } : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: EdgeInsets.symmetric(vertical: 10.h),

                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(13.r),
                )
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_isLoading) ...[
                    SizedBox(
                      width: 16.w,
                      height: 16.w,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(width: 8.w),
                  ],
                  customText(
                    text: 'Đánh giá',
                    color: Colors.black,
                    fonSize: 14.sp,
                    fonWeight: FontWeight.normal,
                  ),
                ],
              ),
          ),
        )
      ],
    );
  }


  double _calculateTotalPrice() {
    return widget.booking.booking.servicesSelected.services
        .fold(0.0, (sum, service) => sum + service.price);
  }
}