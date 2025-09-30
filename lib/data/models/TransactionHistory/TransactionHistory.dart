import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:testrunflutter/data/models/BookingModel/BookingWithShop.dart';

class TransactionHistory {
  final String transactionCode;
  final String userId;
  final BookingWithShop? bookingWithShop;
  final Timestamp timestamp;
  final double totalAmount;
  final double balance;
  final String status;

  TransactionHistory({
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

  factory TransactionHistory.fromJson(Map<String, dynamic> json) {
    return TransactionHistory(
      transactionCode: json['transactionCode'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      bookingWithShop: json['bookingWithShop'] != null
          ? BookingWithShop.fromJson(json['bookingWithShop'] as Map<String, dynamic>)
          : null,
      timestamp: json['timestamp'] as Timestamp? ?? Timestamp.now(),
      totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0.0,
      balance: (json['balance'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] as String? ?? 'pending',
    );
  }
}
