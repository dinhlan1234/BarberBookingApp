import 'package:equatable/equatable.dart';
import 'package:testrunflutter/data/models/TransactionHistory/TransactionHistory.dart';

abstract class DepositHistoryState extends Equatable{
  const DepositHistoryState();
  @override
  List<Object?> get props => [];
}

class DepositHistoryLoading extends DepositHistoryState{}

class DepositHistoryLoaded extends DepositHistoryState{
  final List<TransactionHistory> transactionHistory;
  const DepositHistoryLoaded({required this.transactionHistory});
  @override
  List<Object?> get props => [transactionHistory];
}
class DepositHistoryError extends DepositHistoryState{
  final String message;
  const DepositHistoryError({required this.message});
  @override
  List<Object?> get props => [message];
}