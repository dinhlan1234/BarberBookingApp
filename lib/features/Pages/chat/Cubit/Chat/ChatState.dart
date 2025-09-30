import 'package:equatable/equatable.dart';
import 'package:testrunflutter/data/models/Chat/ChatMessage.dart';
import 'package:testrunflutter/data/models/Chat/Conversation.dart';

abstract class ChatState extends Equatable {
  @override
  List<Object?> get props => [];
}

class ChatInitial extends ChatState {}

class ChatLoading extends ChatState {}

class ChatLoaded extends ChatState {
  final List<ChatMessage> messages;
  final Conversation conversation;

  ChatLoaded({
    required this.messages,
    required this.conversation,
  });

  @override
  List<Object?> get props => [messages, conversation];
}

class ChatError extends ChatState {
  final String message;

  ChatError(this.message);

  @override
  List<Object?> get props => [message];
}