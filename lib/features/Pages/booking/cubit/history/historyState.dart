import 'package:equatable/equatable.dart';
import 'package:testrunflutter/data/models/BookingModel/BookingWithShop.dart';

abstract class HistoryState extends Equatable{
  const HistoryState();
  @override
  List<Object?> get props => [];
}
class HistoryLoading extends HistoryState{}
class HistoryLoaded extends HistoryState{
  final List<BookingWithShop> list;
  const HistoryLoaded({required this.list});
  @override
  List<Object?> get props => [list];
}
class HistoryError extends HistoryState{
  final String message;
  const HistoryError({required this.message});
  @override
  List<Object?> get props => [message];
}