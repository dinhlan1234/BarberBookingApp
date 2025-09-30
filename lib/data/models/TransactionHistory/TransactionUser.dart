import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:testrunflutter/data/models/BookingModel/BookingWithShop.dart';
import 'package:testrunflutter/data/models/BookingWithUser.dart';
import 'package:testrunflutter/data/models/TransactionHistory/BookingUser.dart';

class TransactionUser {
  final String transactionCode;
  final String userId;
  final BookingUser? bookingWithShop;
  final Timestamp timestamp;
  final double totalAmount;
  final double balance;
  final String status;

  TransactionUser({
    required this.transactionCode,
    required this.userId,
    this.bookingWithShop,
    required this.timestamp,
    required this.totalAmount,
    required this.balance,
    required this.status,
  });

  Map<String, dynamic> toJson() {
    return {
      'transactionCode': transactionCode,
      'userId': userId,
      'bookingWithShop': bookingWithShop?.toJson(),
      'timestamp': timestamp,
      'totalAmount': totalAmount,
      'balance': balance,
      'status': status,
    };
  }

  factory TransactionUser.fromJson(Map<String, dynamic> json) {
    final bookingData = json['bookingWithShop'];

    return TransactionUser(
      transactionCode: json['transactionCode'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      bookingWithShop: (bookingData != null && bookingData is Map<String, dynamic>)
          ? BookingUser.fromJson(bookingData)
          : null,
      timestamp: json['timestamp'] is Timestamp ? json['timestamp'] as Timestamp : Timestamp.now(),
      totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0.0,
      balance: (json['balance'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] as String? ?? 'pending',
    );
  }
}
