import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:testrunflutter/data/firebase/ChatRepository.dart';
import 'package:testrunflutter/data/models/Chat/ChatMessage.dart';
import 'package:testrunflutter/data/models/Chat/Conversation.dart';
import 'package:testrunflutter/features/Pages/chat/Cubit/Chat/ChatState.dart';

class ChatCubit extends Cubit<ChatState> {
  final ChatRepository _repository;
  final String conversationId;
  final String currentUserId;
  final String currentUserType;

  StreamSubscription? _messagesSubscription;
  StreamSubscription? _conversationSubscription;

  ChatCubit({
    required ChatRepository repository,
    required this.conversationId,
    required this.currentUserId,
    required this.currentUserType,
  })  : _repository = repository, super(ChatInitial()) {
    loadMessages();
    markAsRead();
  }

  void loadMessages() {
    // Chỉ emit loading khi chưa có dữ liệu
    if (state is! ChatLoaded) {
      emit(ChatLoading());
    }

    _messagesSubscription?.cancel();
    _conversationSubscription?.cancel();

    // Stream messages
    _messagesSubscription = _repository
        .getMessages(conversationId)
        .listen(
          (messages) {
        // Nếu đã có conversation trong state, giữ nguyên
        if (state is ChatLoaded) {
          final currentState = state as ChatLoaded;
          emit(ChatLoaded(messages: messages, conversation: currentState.conversation,));
        } else {
          // Lần đầu load, cần lấy conversation
          _loadConversationData(messages);
        }
      },
      onError: (error) {
        emit(ChatError('Không thể tải tin nhắn: $error'));
      },
    );

    // Stream conversation để cập nhật thông tin real-time
    _conversationSubscription = FirebaseFirestore.instance
        .collection('conversations')
        .doc(conversationId)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists && state is ChatLoaded) {
        final currentState = state as ChatLoaded;
        final conversation = Conversation.fromJson(snapshot.data()!);

        emit(ChatLoaded(
          messages: currentState.messages,
          conversation: conversation,
        ));
      }
    });
  }

  Future<void> _loadConversationData(List<ChatMessage> messages) async {
    try {
      final conversationDoc = await FirebaseFirestore.instance
          .collection('conversations')
          .doc(conversationId)
          .get();

      if (conversationDoc.exists) {
        final conversation = Conversation.fromJson(conversationDoc.data()!);
        emit(ChatLoaded(
          messages: messages,
          conversation: conversation,
        ));
      }
    } catch (e) {
      emit(ChatError('Không thể tải thông tin cuộc trò chuyện: $e'));
    }
  }

  Future<void> sendMessage({
    required String text,
    required String senderType,
    String? imageUrl,
    String? fileUrl,
    String? fileName,
    MessageType type = MessageType.text,
  }) async {
    try {
      await _repository.sendMessage(
        conversationId: conversationId,
        senderId: currentUserId,
        senderType: senderType,
        text: text,
        imageUrl: imageUrl,
        fileUrl: fileUrl,
        fileName: fileName,
        type: type,
      );

    } catch (e) {
      emit(ChatError('Không thể gửi tin nhắn: $e'));
    }
  }

  Future<void> markAsRead() async {
    try {
      await _repository.markMessagesAsRead(
        conversationId: conversationId,
        currentUserId: currentUserId,
        currentUserType: currentUserType,
      );
    } catch (e) {
      print('Không thể đánh dấu đã đọc: $e');
    }
  }

  @override
  Future<void> close() {
    _messagesSubscription?.cancel();
    _conversationSubscription?.cancel();
    return super.close();
  }
}