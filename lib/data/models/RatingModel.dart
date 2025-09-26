class RatingModel {
  final String idShop;
  final int quantity;
  final double rating;

  RatingModel({
    required this.idShop,
    required this.quantity,
    required this.rating,
  });

  factory RatingModel.fromJson(Map<String, dynamic> json) {
    return RatingModel(
      idShop: json['idShop'] as String,
      quantity: json['quantity'] is int
          ? json['quantity'] as int
          : int.tryParse(json['quantity'].toString()) ?? 0,
      rating: json['rating'] is double
          ? json['rating'] as double
          : double.tryParse(json['rating'].toString()) ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idShop': idShop,
      'quantity': quantity,
      'rating': rating,
    };
  }
}
