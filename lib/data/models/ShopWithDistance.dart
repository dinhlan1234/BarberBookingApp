import 'package:testrunflutter/data/models/RatingModel.dart';
import 'package:testrunflutter/data/models/ShopModel.dart';

class ShopWithDistance {
  final ShopModel shop;
  final RatingModel ratingModel;
  final double distanceKm;

  ShopWithDistance({required this.shop,required this.ratingModel, required this.distanceKm});
}
