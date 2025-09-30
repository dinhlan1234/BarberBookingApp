import 'package:testrunflutter/data/models/BookingModel/BookingSchedules.dart';
import 'package:testrunflutter/data/models/ShopModel.dart';

class BookingWithShop {
  final BookingSchedules booking;
  final ShopModel shop;

  BookingWithShop({
    required this.booking,
    required this.shop,
  });

  /// Convert object -> Map
  Map<String, dynamic> toJson() {
    return {
      'booking': booking.toJson(),
      'shop': shop.toJson(),
    };
  }

  /// Convert Map -> object
  factory BookingWithShop.fromJson(Map<String, dynamic> json) {
    return BookingWithShop(
      booking: BookingSchedules.fromJson(json['booking'] as Map<String, dynamic>),
      shop: ShopModel.fromJson(json['shop'] as Map<String, dynamic>),
    );
  }
}
