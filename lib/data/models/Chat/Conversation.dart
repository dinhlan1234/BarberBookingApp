import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:testrunflutter/data/models/Chat/ChatMessage.dart';

class Conversation {
  final String id;

  final String userId;
  final String userName;
  final String? userAvatar;

  final String shopId;
  final String shopName;
  final String? shopAvatar;
  final String? shopAddress;

  final ChatMessage? lastMessage;

  // ✅ Tách riêng unreadCount
  final int userUnreadCount;
  final int shopUnreadCount;

  final DateTime createdAt;
  final DateTime updatedAt;

  final bool isActive;

  final List<String> participants;

  Conversation({
    required this.id,
    required this.userId,
    required this.userName,
    this.userAvatar,
    required this.shopId,
    required this.shopName,
    this.shopAvatar,
    this.shopAddress,
    this.lastMessage,
    this.userUnreadCount = 0,
    this.shopUnreadCount = 0,
    required this.createdAt,
    required this.updatedAt,
    this.isActive = true,
    required this.participants,
  });

  factory Conversation.fromJson(Map<String, dynamic> json) {
    return Conversation(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      userName: json['userName'] ?? '',
      userAvatar: json['userAvatar'],
      shopId: json['shopId'] ?? '',
      shopName: json['shopName'] ?? '',
      shopAvatar: json['shopAvatar'],
      shopAddress: json['shopAddress'],
      lastMessage: json['lastMessage'] != null
          ? ChatMessage.fromJson(json['lastMessage'])
          : null,
      userUnreadCount: json['userUnreadCount'] ?? 0,
      shopUnreadCount: json['shopUnreadCount'] ?? 0,
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      updatedAt: (json['updatedAt'] as Timestamp).toDate(),
      isActive: json['isActive'] ?? true,
      participants: List<String>.from(json['participants'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'userAvatar': userAvatar,
      'shopId': shopId,
      'shopName': shopName,
      'shopAvatar': shopAvatar,
      'shopAddress': shopAddress,
      'lastMessage': lastMessage?.toJson(),
      'userUnreadCount': userUnreadCount,
      'shopUnreadCount': shopUnreadCount,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'isActive': isActive,
      'participants': participants,
    };
  }

  Conversation copyWith({
    String? id,
    String? userId,
    String? userName,
    String? userAvatar,
    String? shopId,
    String? shopName,
    String? shopAvatar,
    String? shopAddress,
    ChatMessage? lastMessage,
    int? userUnreadCount,
    int? shopUnreadCount,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
    List<String>? participants,
  }) {
    return Conversation(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userAvatar: userAvatar ?? this.userAvatar,
      shopId: shopId ?? this.shopId,
      shopName: shopName ?? this.shopName,
      shopAvatar: shopAvatar ?? this.shopAvatar,
      shopAddress: shopAddress ?? this.shopAddress,
      lastMessage: lastMessage ?? this.lastMessage,
      userUnreadCount: userUnreadCount ?? this.userUnreadCount,
      shopUnreadCount: shopUnreadCount ?? this.shopUnreadCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
      participants: participants ?? this.participants,
    );
  }
}
