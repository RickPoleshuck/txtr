import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:txtr_shared/txtr_shared.dart';

@immutable
sealed class MessageState extends Equatable {}

class MessageSendingEvent extends MessageState {
  @override
  List<Object?> get props => [];
}

class MessageLoadedState extends MessageState {
  final TxtrMessageDTO message;

  MessageLoadedState(this.message);

  @override
  List<Object?> get props => [message];
}

class MessageErrorState extends MessageState {
  final String error;

  MessageErrorState(this.error);

  @override
  List<Object?> get props => [error];
}
