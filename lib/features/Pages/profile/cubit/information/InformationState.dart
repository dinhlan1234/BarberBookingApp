import 'package:equatable/equatable.dart';
import 'package:testrunflutter/data/models/UserModel.dart';

abstract class InformationState extends Equatable{
  const InformationState();
  @override
  List<Object?> get props => [];
}
class InformationLoading extends InformationState {}
class InformationLoaded extends InformationState {
  final UserModel user;
  const InformationLoaded({required this.user});

  @override
  List<Object?> get props => [user];
}

class InformationError extends InformationState {
  final String message;
  const InformationError(this.message);

  @override
  List<Object?> get props => [message];
}