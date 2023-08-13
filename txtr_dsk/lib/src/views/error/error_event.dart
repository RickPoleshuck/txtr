part of 'error_bloc.dart';

abstract class ErrorEvent extends Equatable {
  const ErrorEvent();
}

class ErrorOccurEvent extends ErrorEvent {
  @override
  List<Object?> get props => [];
}
