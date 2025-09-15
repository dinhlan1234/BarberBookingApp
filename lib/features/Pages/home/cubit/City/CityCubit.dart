import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:testrunflutter/features/Pages/home/cubit/City/CityState.dart';

class CityCubit extends Cubit<CityState>{
  CityCubit() : super(CityInitial());
  Future<void> fetchCity() async {
    emit(CityLoading());
    try {
      final position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high,);

      final lat = position.latitude;
      final lon = position.longitude;



      final url = Uri.parse(
        'https://nominatim.openstreetmap.org/reverse?lat=$lat&lon=$lon&format=json&zoom=10&addressdetails=1',
      );

      final response = await http.get(url, headers: {
        'User-Agent': 'FlutterApp/1.0 (dinhlan74qt@gmail.com)'
      });

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final address = data['address'];
        final cityName = address['city'] ??
            address['town'] ??
            address['village'] ??
            address['state'] ??
            'Không xác định';
        print(jsonEncode(address));
        emit(CityLoaded(cityName));
      } else {
        emit(CityError('Lỗi HTTP: ${response.statusCode}'));
      }
    } catch (e) {
      emit(CityError('Lỗi: $e'));
    }
  }
}