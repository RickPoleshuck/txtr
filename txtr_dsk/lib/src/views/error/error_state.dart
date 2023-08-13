part of 'error_bloc.dart';

abstract class ErrorState extends Equatable {
  const ErrorState();
}

class ErrorInitial extends ErrorState {
  @override
  List<Object> get props => [];
}

class ErrorOccurred extends ErrorState {
  final String message;

  @override
  List<Object> get props => [message];

  const ErrorOccurred(this.message);
}
