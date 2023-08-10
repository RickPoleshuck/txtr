import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

@immutable
abstract class MessagesEvent extends Equatable {
  const MessagesEvent();
}

class MessagesLoadEvent extends MessagesEvent {
  @override
  List<Object?> get props => [];
}

class MessagesCheckEvent extends MessagesEvent {
  @override
  List<Object?> get props => [];
}

class MessagesErrorEvent extends MessagesEvent {
  @override
  List<Object?> get props => [];
}
