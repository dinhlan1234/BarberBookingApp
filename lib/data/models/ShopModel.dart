import 'package:testrunflutter/data/models/BankInfoModel.dart';
import 'package:testrunflutter/data/models/LocationModel.dart';
import 'package:testrunflutter/data/models/cccdModel.dart';

class ShopModel {
  final String id;
  final String shopName;
  final String ownerName;
  final String email;
  final String phone;

  final String shopAvatarImageUrl;
  final String backgroundImageUrl;

  final LocationModel location;

  final String openHour;
  final String closeHour;
  final List<String> openDays;

  final String introduction; // note

  final String registeredDate;
  final String approvedStatus;
  final String ratingAvg;

  final CccdModel cccd;
  final String licenseImage;

  final BankInfoModel bankInfo;

  final String fcmToken;

  ShopModel(
      this.id,
      this.shopName,
      this.ownerName,
      this.cccd,
      this.email,
      this.phone,
      this.shopAvatarImageUrl,
      this.backgroundImageUrl,
      this.location,
      this.openHour,
      this.closeHour,
      this.openDays,
      this.introduction,
      this.registeredDate,
      this.approvedStatus,
      this.ratingAvg,
      this.licenseImage,
      this.bankInfo,
      this.fcmToken
      );

  factory ShopModel.fromJson(Map<String, dynamic> json) {
    return ShopModel(
      json['id'] as String,
      json['shopName'] as String,
      json['ownerName'] as String,
      CccdModel.fromJson(json['cccd']),
      json['email'] as String,
      json['phone'] as String,
      json['shopAvatarImageUrl'] as String,
      json['backgroundImageUrl'] as String,
      LocationModel.fromJson(json['location']),
      json['openHour'] as String,
      json['closeHour'] as String,
      List<String>.from(json['openDays']),
      json['introduction'] as String,
      json['registeredDate'] as String,
      json['approvedStatus'] as String,
      json['ratingAvg'] as String,
      json['licenseImage'] as String,
      BankInfoModel.fromJson(json['bankInfo']),
      json['fcmToken'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'shopName': shopName,
      'ownerName': ownerName,
      'cccd': cccd.toJson(),
      'email': email,
      'phone': phone,
      'shopAvatarImageUrl': shopAvatarImageUrl,
      'backgroundImageUrl': backgroundImageUrl,
      'location': location.toJson(),
      'openHour': openHour,
      'closeHour': closeHour,
      'openDays': openDays,
      'introduction': introduction,
      'registeredDate': registeredDate,
      'approvedStatus': approvedStatus,
      'ratingAvg': ratingAvg,
      'licenseImage': licenseImage,
      'bankInfo': bankInfo.toJson(),
      'fcmToken': fcmToken
    };
  }
}
