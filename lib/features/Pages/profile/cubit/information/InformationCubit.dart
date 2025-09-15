import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:testrunflutter/data/models/UserModel.dart';
import 'package:testrunflutter/data/repositories/prefs/UserPrefsService.dart';
import 'InformationState.dart';

class InformationCubit extends Cubit<InformationState> {
  final String id;
  StreamSubscription? _subscription; // dùng để lắng nghe

  InformationCubit({required this.id}) : super(InformationLoading()) {
    _init();
  }

  Future<void> _init() async {
    // Bước 1: Lấy từ local trước
    final localUser = await UserPrefsService.getUser();
    if (localUser != null) {
      emit(InformationLoaded(user: localUser));
    }

    // Bước 2: Lắng nghe thay đổi từ Firestore
    _subscription = FirebaseFirestore.instance
        .collection('Users')
        .doc(id)
        .snapshots()
        .listen((snapshot) async {
      if (snapshot.exists && snapshot.data() != null) {
        final updatedUser = UserModel.fromFireStore(snapshot.data() as Map<String, dynamic>, id);

        // Cập nhật local
        // await UserPrefsService.saveUser(updatedUser);

        // Emit để cập nhật UI
        emit(InformationLoaded(user: updatedUser));
      } else {
        emit(const InformationError('Không tìm thấy người dùng.'));
      }
    }, onError: (e) {
      emit(InformationError(e.toString()));
    });
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
