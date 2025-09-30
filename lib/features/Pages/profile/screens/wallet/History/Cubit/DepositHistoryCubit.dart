import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:testrunflutter/data/models/TransactionHistory/TransactionHistory.dart';
import 'package:testrunflutter/features/Pages/profile/screens/wallet/History/Cubit/DepositHistoryState.dart';

class DepositHistoryCubit extends Cubit<DepositHistoryState> {
  final String id;

  DepositHistoryCubit({required this.id}) : super(DepositHistoryLoading()) {
    loadHistory();
  }

  Future<void> loadHistory() async {
    try {
      emit(DepositHistoryLoading());

      final querySnapshot = await FirebaseFirestore.instance
          .collection('TransactionHistory')
          .where('userId', isEqualTo: id)
          .where('status', whereIn: ['Nạp tiền','Rút tiền'])
          .get();

      final listHistory = querySnapshot.docs.map((doc) {
        final data = doc.data();

        return TransactionHistory.fromJson({
          ...data,
          'id': doc.id,
        });
      }).whereType<TransactionHistory>().toList();
      emit(DepositHistoryLoaded(transactionHistory: listHistory));
    } catch (e) {
      emit(DepositHistoryError(message: 'Lỗi không xác định: ${e.toString()}'));
      print("TransactionCubit error: $e");
    }
  }
}
