import 'package:testrunflutter/data/models/ServiceModel.dart';

class ServicesSelected {
  final List<ServiceModel> services;
  final double total;
  final double discount;

  ServicesSelected({
    required this.services,
    required this.total,
    required this.discount,
  });

  // fromJson
  factory ServicesSelected.fromJson(Map<String, dynamic> json) {
    return ServicesSelected(
      services: (json['services'] as List<dynamic>)
          .map((e) => ServiceModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      total: (json['total'] as num).toDouble(),
      discount: (json['discount'] as num).toDouble(),
    );
  }

  // toJson
  Map<String, dynamic> toJson() {
    return {
      'services': services.map((e) => e.toJson()).toList(),
      'total': total,
      'discount': discount,
    };
  }
}
