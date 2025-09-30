import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:testrunflutter/data/models/TransactionHistory/TransactionHistory.dart';
import 'package:testrunflutter/data/models/TransactionHistory/TransactionUser.dart';
import 'package:testrunflutter/features/Pages/profile/screens/wallet/Transaction/Cubit/TransactionState.dart';

class TransactionCubit extends Cubit<TransactionState> {
  final String id;
  final String status;

  TransactionCubit({required this.id, required this.status})
      : super(TransactionLoading()) {
    loadHistory();
  }

  Future<void> loadHistory() async {
    try {
      emit(TransactionLoading());

      final querySnapshot = await FirebaseFirestore.instance
          .collection('TransactionHistory')
          .where('userId', isEqualTo: id)
          .where('status', isEqualTo: status)
          .get();

      final listHistory = querySnapshot.docs.map((doc) {
        final data = doc.data();
        if (data == null) {
          print("⚠️ Warning: TransactionHistory document ${doc.id} có data null");
          return null;
        }

        return TransactionUser.fromJson({
          ...data,
          'id': doc.id, // ép thêm id vào map
        });
      }).whereType<TransactionUser>().toList();


      emit(TransactionLoaded(transactionHistory: listHistory));
    } catch (e) {
      emit(TransactionError(message: 'Lỗi không xác định: ${e.toString()}'));
      print("TransactionCubit error: $e");
    }
  }
}
