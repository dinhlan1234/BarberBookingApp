import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:testrunflutter/data/models/BookingModel/BookingSchedules.dart';
import 'package:testrunflutter/data/models/BookingModel/BookingWithShop.dart';
import 'package:testrunflutter/data/models/ShopModel.dart';
import 'package:testrunflutter/features/Pages/booking/cubit/booking_state.dart';

class BookingCubit extends Cubit<BookingState> {
  final String idUser;
  StreamSubscription? _subscription;

  BookingCubit({required this.idUser}) : super(BookingLoading()) {
    _loadBooking();
  }

  Future<void> _loadBooking() async {
    try {
      emit(BookingLoading());
      _subscription = FirebaseFirestore.instance
          .collection('BookingSchedules')
          .where('idUser', isEqualTo: idUser)
          .where('status', whereIn: ['Chờ duyệt', 'Đã duyệt', 'Đã đến','Rủi ro'])
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

        emit(BookingLoaded(list: bookingWithShops));
      }, onError: (error) {
        emit(BookingError(message: 'Lỗi tải dịch vụ: ${error.toString()}'));
      });
    } catch (e) {
      emit(BookingError(message: 'Lỗi không xác định: ${e.toString()}'));
    }
  }
}
