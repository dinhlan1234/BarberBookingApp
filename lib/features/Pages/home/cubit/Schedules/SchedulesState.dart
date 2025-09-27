import 'package:equatable/equatable.dart';
import 'package:testrunflutter/data/models/BookingModel/BookingSchedules.dart';
import 'package:testrunflutter/data/models/BookingWithUser.dart';

abstract class SchedulesState extends Equatable{
  const SchedulesState();
  @override
  List<Object?> get props => [];
}

class SchedulesLoading extends SchedulesState{

}

class SchedulesLoaded extends SchedulesState{
  final List<BookingWithUser> listBooking;
  const SchedulesLoaded({required this.listBooking});
  @override
  List<Object?> get props => [listBooking];
}

class SchedulesError extends SchedulesState{
  final String message;
  const SchedulesError({required this.message});
  @override
  List<Object?> get props => [message];
}