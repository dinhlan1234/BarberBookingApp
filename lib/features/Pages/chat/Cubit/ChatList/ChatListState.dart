import 'package:equatable/equatable.dart';
import 'package:testrunflutter/data/models/Chat/Conversation.dart';

abstract class ChatListState extends Equatable {
  @override
  List<Object?> get props => [];
}

class ChatListInitial extends ChatListState {}

class ChatListLoading extends ChatListState {}

class ChatListLoaded extends ChatListState {
  final List<Conversation> conversations;

  ChatListLoaded(this.conversations);

  @override
  List<Object?> get props => [conversations];
}

class ChatListError extends ChatListState {
  final String message;

  ChatListError(this.message);

  @override
  List<Object?> get props => [message];
}