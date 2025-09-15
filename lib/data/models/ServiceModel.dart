class ServiceModel {
  final String serviceId;
  final String shopID;
  final String name;
  final double price;
  final String avatarUrl;
  final bool activeStatus;
  final String note;

  ServiceModel({
    required this.serviceId,
    required this.shopID,
    required this.name,
    required this.price,
    required this.avatarUrl,
    required this.activeStatus,
    required this.note,
  });

  // Chuyển từ JSON sang ServiceModel
  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    return ServiceModel(
      serviceId: json['serviceId'] ?? '',
      shopID: json['shopID'] ?? '',
      name: json['name'] ?? '',
      price: (json['price'] is int)
          ? (json['price'] as int).toDouble()
          : (json['price'] ?? 0.0).toDouble(),
      avatarUrl: json['avatarUrl'] ?? '',
      activeStatus: json['activeStatus'] ?? false,
      note: json['note'] ?? '',
    );
  }

  // Chuyển từ ServiceModel sang JSON
  Map<String, dynamic> toJson() {
    return {
      'serviceId': serviceId,
      'shopID': shopID,
      'name': name,
      'price': price,
      'avatarUrl': avatarUrl,
      'activeStatus': activeStatus,
      'note': note,
    };
  }
}
