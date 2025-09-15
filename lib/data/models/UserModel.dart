class UserModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String provinceName;
  final String provinceCode;
  final String money;
  final String avatarUrl;
  final String creationDate;
  final String role;
  final String fcmToken;

  UserModel(
      this.id,
      this.name,
      this.email,
      this.phone,
      this.provinceName,
      this.provinceCode,
      this.money,
      this.avatarUrl,
      this.creationDate,
      this.role,
      this.fcmToken
      );

  // Tạo từ Firestore DocumentSnapshot
  factory UserModel.fromFireStore(Map<String, dynamic> json, String id) {
    return UserModel(
      id,
      json['name'] ?? '',
      json['email'] ?? '',
      json['phone'] ?? '',
      json['provinceName'] ?? '',
      json['provinceCode'] ?? '',
      json['money'] ?? '0',
      json['avatarUrl'] ?? '',
      json['creationDate'] ?? '',
      json['role'] ?? '',
      json['fcmToken'] ?? ''
    );
  }

  // Chuyển về Map để lưu vào Firestore
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'provinceName': provinceName,
      'provinceCode': provinceCode,
      'money': money,
      'avatarUrl': avatarUrl,
      'creationDate': creationDate,
      'role': role,
      'fcmToken': fcmToken
    };
  }
}
