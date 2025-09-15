import 'package:equatable/equatable.dart';
import 'package:testrunflutter/data/models/ServiceModel.dart';

abstract class ServiceState extends Equatable{
  const ServiceState();
  @override
  List<Object?> get props => [];
}
class ServiceLoading extends ServiceState{}
class ServiceLoaded extends ServiceState{
  final List<ServiceModel> listServices;
  const ServiceLoaded({required this.listServices});
  @override
  List<Object?> get props => [listServices];
}
class ServiceError extends ServiceState{
  final String message;
  const ServiceError({required this.message});
  @override
  List<Object?> get props => [message];
}