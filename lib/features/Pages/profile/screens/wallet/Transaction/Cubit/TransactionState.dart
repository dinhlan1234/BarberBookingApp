import 'package:equatable/equatable.dart';
import 'package:testrunflutter/data/models/TransactionHistory/TransactionHistory.dart';
import 'package:testrunflutter/data/models/TransactionHistory/TransactionUser.dart';

abstract class TransactionState extends Equatable{
  const TransactionState();
  @override
  List<Object?> get props => [];
}

class TransactionLoading extends TransactionState{}
class TransactionLoaded extends TransactionState{
  final List<TransactionUser> transactionHistory;
  const TransactionLoaded({required this.transactionHistory});
  @override
  List<Object?> get props => [transactionHistory];
}
class TransactionError extends TransactionState{
  final String message;
  const TransactionError({required this.message});
  @override
  List<Object?> get props => [message];
}