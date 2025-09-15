import 'package:equatable/equatable.dart';
class MoneyState extends Equatable {
  final String money;
  const MoneyState({required this.money});
  @override
  List<Object?> get props => [money];
}