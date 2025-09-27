import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:testrunflutter/data/models/BookingModel/BookingSchedules.dart';
import 'package:testrunflutter/data/models/BookingWithUser.dart';
import 'package:testrunflutter/data/models/UserModel.dart';
import 'package:testrunflutter/features/Pages/home/cubit/Schedules/SchedulesState.dart';
import 'package:intl/intl.dart';

class SchedulesCubit extends Cubit<SchedulesState> {
  final String idShop;
  StreamSubscription? _streamSubscription;

  SchedulesCubit({required this.idShop}) : super(SchedulesLoading());

  /// Load danh sách booking theo ngày
  Future<void> loadBookingByDate(DateTime date) async {
    try {
      emit(SchedulesLoading());

      // Format theo định dạng trong Firestore: dd/MM/yyyy
      final dateStr = DateFormat('dd/MM/yyyy').format(date);

      _streamSubscription?.cancel(); // huỷ stream cũ

      _streamSubscription = FirebaseFirestore.instance
          .collection('BookingSchedules')
          .where('idShop', isEqualTo: idShop)
          .where('bookingDateModel.date', isEqualTo: dateStr) // lọc theo ngày
          .snapshots()
          .listen((snapshot) async {
        final bookings = snapshot.docs.map((doc) {
          final booking = doc.data();
          return BookingSchedules.fromJson(booking);
        }).toList();

        final bookingWithUser = await Future.wait(bookings.map((b) async {
          final userDoc = await FirebaseFirestore.instance
              .collection('Users')
              .doc(b.idUser)
              .get();

          final user = UserModel.fromFireStore(userDoc.data()!, userDoc.id);
          return BookingWithUser(booking: b, userModel: user);
        }));

        emit(SchedulesLoaded(listBooking: bookingWithUser));
      }, onError: (err) {
        emit(SchedulesError(message: 'Lỗi tải dịch vụ: ${err.toString()}'));
      });
    } catch (e) {
      emit(SchedulesError(message: 'Lỗi không xác định: ${e.toString()}'));
    }
  }

  @override
  Future<void> close() {
    _streamSubscription?.cancel();
    return super.close();
  }
}