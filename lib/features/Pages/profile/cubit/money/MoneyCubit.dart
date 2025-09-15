import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:testrunflutter/data/firebase/FireStore.dart';
import 'package:testrunflutter/features/Pages/profile/cubit/money/MoneyState.dart';

class MoneyCubit extends Cubit<MoneyState>{
  final String userId;
  final FireStoreDatabase firestore = FireStoreDatabase();
  late final Stream<DocumentSnapshot> _userStream;
  late final StreamSubscription _subscription;

  MoneyCubit({required this.userId}) : super (const MoneyState(money: '0')) {
    _userStream = FirebaseFirestore.instance
        .collection('Users')
        .doc(userId)
        .snapshots();
    _subscription = _userStream.listen((snapshot) {
      if (snapshot.exists) {
        final data = snapshot.data() as Map<String, dynamic>;
        final String newMoney = data['money'] ?? '0';
        if (!isClosed) emit(MoneyState(money: newMoney));
      }
    });
  _fetchMoneyOnce();
  }

    Future<void> _fetchMoneyOnce() async {
      final result = await firestore.getMoney(userId);
      if (result != null) {
        emit(MoneyState(money: result));
      }
    }
  }