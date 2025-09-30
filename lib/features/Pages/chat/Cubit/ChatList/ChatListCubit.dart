import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:testrunflutter/data/firebase/ChatRepository.dart';
import 'dart:async';

import 'package:testrunflutter/features/Pages/chat/Cubit/ChatList/ChatListState.dart';

class ChatListCubit extends Cubit<ChatListState> {
  final ChatRepository _repository;
  final String userId;
  StreamSubscription? _conversationsSubscription;

  ChatListCubit({
    required ChatRepository repository,
    required this.userId,
  })  : _repository = repository, super(ChatListInitial()) {
    loadConversations();
  }

  void loadConversations() {
    emit(ChatListLoading());

    _conversationsSubscription?.cancel();
    _conversationsSubscription = _repository
        .getUserConversations(userId)
        .listen(
          (conversations) {
        emit(ChatListLoaded(conversations));
      },
      onError: (error) {
        emit(ChatListError('Không thể tải danh sách: $error'));
      },
    );
  }

  Future<void> searchConversations(String keyword) async {
    try {
      emit(ChatListLoading());
      final results = await _repository.searchConversations(
        userId: userId,
        keyword: keyword,
      );
      emit(ChatListLoaded(results));
    } catch (e) {
      emit(ChatListError('Không thể tìm kiếm: $e'));
    }
  }

  Future<void> deleteConversation(String conversationId) async {
    try {
      await _repository.deleteConversation(conversationId);
      // Stream sẽ tự động cập nhật
    } catch (e) {
      emit(ChatListError('Không thể xóa: $e'));
    }
  }

  @override
  Future<void> close() {
    _conversationsSubscription?.cancel();
    return super.close();
  }

}