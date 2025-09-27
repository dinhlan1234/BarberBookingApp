import 'package:cloud_firestore/cloud_firestore.dart';

class LikeModel {
  final String idUser;
  final Timestamp timestamp;

  LikeModel({
    required this.idUser,
    required this.timestamp,
  });

  // Chuyển từ Firestore -> LikeModel
  factory LikeModel.fromJson(Map<String, dynamic> json) {
    return LikeModel(
      idUser: json['idUser'] ?? '',
      timestamp: json['timestamp'] ?? Timestamp.now(),
    );
  }

  // Chuyển LikeModel -> Map để lưu vào Firestore
  Map<String, dynamic> toJson() {
    return {
      'idUser': idUser,
      'timestamp': timestamp,
    };
  }
}
