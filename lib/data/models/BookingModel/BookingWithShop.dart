import 'package:testrunflutter/data/models/BookingModel/BookingSchedules.dart';
import 'package:testrunflutter/data/models/ShopModel.dart';

class BookingWithShop {
  final BookingSchedules booking;
  final ShopModel shop;

  BookingWithShop({
    required this.booking,
    required this.shop,
  });
}
