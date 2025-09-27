import 'package:testrunflutter/data/models/BookingModel/BookingSchedules.dart';
import 'package:testrunflutter/data/models/UserModel.dart';

class BookingWithUser {
  final BookingSchedules booking;
  final UserModel userModel;

  BookingWithUser({
    required this.booking,
    required this.userModel,
  });

  factory BookingWithUser.fromJson(Map<String, dynamic> json) {
    return BookingWithUser(
      booking: BookingSchedules.fromJson(json['booking'] ?? {}),
      userModel: UserModel.fromFireStore(
        json['userModel'] ?? {},
        json['userModel']['id'] ?? '',
      ),
    );
  }


  /// toJson: chuyển đối tượng thành Map để lưu vào Firestore hoặc API
  Map<String, dynamic> toJson() {
    return {
      'booking': booking.toJson(),
      'userModel': userModel.toJson(),
    };
  }
}
