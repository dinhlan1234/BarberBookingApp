import 'package:equatable/equatable.dart';
import 'package:testrunflutter/data/models/BookingModel/BookingSchedules.dart';
import 'package:testrunflutter/data/models/BookingModel/BookingWithShop.dart';

abstract class BookingState extends Equatable{
  const BookingState();
  @override
  List<Object?> get props => [];
}
class BookingLoading extends BookingState{}
class BookingLoaded extends BookingState{
  final List<BookingWithShop> list;
  const BookingLoaded({required this.list});
  @override
  List<Object?> get props => [list];
}
class BookingError extends BookingState{
  final String message;
  const BookingError({required this.message});
  @override
  List<Object?> get props => [message];
}