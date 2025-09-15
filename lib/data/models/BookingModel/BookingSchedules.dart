import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:testrunflutter/data/models/BookingModel/BookingDateModel.dart';
import 'package:testrunflutter/data/models/BookingModel/ReviewModel.dart';
import 'package:testrunflutter/data/models/BookingModel/ServicesSelected.dart';

class BookingSchedules {
  final String idSchedules;
  final String idUser;
  final String idShop;

  final ServicesSelected servicesSelected;

  final Timestamp time;
  final BookingDateModel bookingDateModel;

  final String status;

  final ReviewModel? reviewModel;

  BookingSchedules({
    required this.idSchedules,
    required this.idUser,
    required this.idShop,
    required this.servicesSelected,
    required this.time,
    required this.bookingDateModel,
    required this.status,
    this.reviewModel, // cho phép null
  });

  factory BookingSchedules.fromJson(Map<String, dynamic> json) {
    return BookingSchedules(
      idSchedules: json['idSchedules'] as String,
      idUser: json['idUser'] as String,
      idShop: json['idShop'] as String,
      servicesSelected: ServicesSelected.fromJson(json['servicesSelected']),
      time: json['time'] as Timestamp,
      bookingDateModel: BookingDateModel.fromJson(json['bookingDateModel']),
      status: json['status'] as String,
      reviewModel: json['reviewModel'] != null
          ? ReviewModel.fromJson(json['reviewModel'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idSchedules': idSchedules,
      'idUser': idUser,
      'idShop': idShop,
      'servicesSelected': servicesSelected.toJson(),
      'time': time,
      'bookingDateModel': bookingDateModel.toJson(),
      'status': status,
      if (reviewModel != null) 'reviewModel': reviewModel!.toJson(),
    };
  }
}
