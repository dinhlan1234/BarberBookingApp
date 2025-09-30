
import 'package:testrunflutter/data/models/BookingModel/BookingSchedules.dart';
import 'package:testrunflutter/data/models/UserModel.dart';

class BookingUser {
  final BookingSchedules booking;
  final UserModel user;

  BookingUser({
    required this.booking,
    required this.user,
  });

  // fromJson
  factory BookingUser.fromJson(Map<String, dynamic> json) {
    final userMap = json['user'] as Map<String, dynamic>? ?? {};
    return BookingUser(
      booking: BookingSchedules.fromJson(
          json['booking'] as Map<String, dynamic>),
      user: UserModel.fromFireStore(
        userMap,
        userMap['id'] ?? '',
      ),
    );
  }

  // toJson
  Map<String, dynamic> toJson() {
    return {
      'booking': booking.toJson(),
      'user': user.toJson(), // key trùng với fromJson
    };
  }
}
