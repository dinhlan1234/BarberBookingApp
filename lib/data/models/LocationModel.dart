class LocationModel {
  final String provinceName;
  final String provinceCode;
  final String districtName;
  final String wardName;
  final String address;
  final double latitude;
  final double longitude;

  LocationModel(
      this.provinceName,
      this.provinceCode,
      this.districtName,
      this.wardName,
      this.address,
      this.latitude,
      this.longitude,
      );

  /// Chuyển từ JSON (Map) sang LocationModel
  factory LocationModel.fromJson(Map<String, dynamic> json) {
    return LocationModel(
      json['provinceName'] ?? '',
      json['provinceCode'] ?? '',
      json['districtName'] ?? '',
      json['wardName'] ?? '',
      json['address'] ?? '',
      (json['latitude'] as num?)?.toDouble() ?? 0.0,
      (json['longitude'] as num?)?.toDouble() ?? 0.0,
    );
  }

  /// Chuyển từ LocationModel sang JSON (Map)
  Map<String, dynamic> toJson() {
    return {
      'provinceName': provinceName,
      'provinceCode': provinceCode,
      'districtName': districtName,
      'wardName': wardName,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}
