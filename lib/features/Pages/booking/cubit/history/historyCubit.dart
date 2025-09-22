import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:testrunflutter/data/models/BookingModel/BookingSchedules.dart';
import 'package:testrunflutter/data/models/BookingModel/BookingWithShop.dart';
import 'package:testrunflutter/data/models/ShopModel.dart';
import 'package:testrunflutter/features/Pages/booking/cubit/history/historyState.dart';

class HistoryCubit extends Cubit<HistoryState>{
  final String idUser;
  StreamSubscription? _subscription;
  HistoryCubit({required this.idUser}):super(HistoryLoading()){
    _loadBooking();
  }
  Future<void> _loadBooking() async {
    try {
      emit(HistoryLoading());
      _subscription = FirebaseFirestore.instance
          .collection('BookingSchedules')
          .where('idUser', isEqualTo: idUser)
          .where('status', whereIn: ['Hoàn thành1','Hoàn thành2'])
          .snapshots()
          .listen((snapshot) async {
        final bookings = snapshot.docs.map((doc) {
          final data = doc.data();
          return BookingSchedules.fromJson(data);
        }).toList();

        // Lấy thông tin shop cho từng booking
        final bookingWithShops = await Future.wait(bookings.map((b) async {
          final shopDoc = await FirebaseFirestore.instance
              .collection('Shops')
              .doc(b.idShop)
              .get();

          final shop = ShopModel.fromJson({
            'id': shopDoc.id,
            ...shopDoc.data()!,
          });

          return BookingWithShop(booking: b, shop: shop);
        }));

        emit(HistoryLoaded(list: bookingWithShops));
      }, onError: (error) {
        emit(HistoryError(message: 'Lỗi tải dịch vụ: ${error.toString()}'));
      });
    } catch (e) {
      emit(HistoryError(message: 'Lỗi không xác định: ${e.toString()}'));
    }
  }
}