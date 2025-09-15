import 'package:cloud_firestore/cloud_firestore.dart';

class ReviewModel {
  final String userId;
  final String shopId;
  final double rating;
  final String comment;
  final Timestamp time;

  ReviewModel({
    required this.userId,
    required this.shopId,
    required this.rating,
    required this.comment,
    required this.time,
  });

  // fromJson
  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      userId: json['userId'] as String,
      shopId: json['shopId'] as String,
      rating: (json['rating'] as num).toDouble(),
      comment: json['comment'] as String,
      time: json['time'] as Timestamp,
    );
  }

  // toJson
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'shopId': shopId,
      'rating': rating,
      'comment': comment,
      'time': time,
    };
  }
}
