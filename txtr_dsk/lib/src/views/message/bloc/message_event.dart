import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:txtr_shared/txtr_shared.dart';

@immutable
abstract class MessageEvent extends Equatable {
  const MessageEvent();
}

class MessageSendEvent extends MessageEvent {
  final TxtrMessageDTO message;

  const MessageSendEvent(this.message);

  @override
  List<Object?> get props => [message];
}

class MessageErrorEvent extends MessageEvent {
  final String errorMessage;

  const MessageErrorEvent(this.errorMessage);

  @override
  List<Object> get props => [errorMessage];
}

class MessageLoadedEvent extends MessageEvent {
  final TxtrMessageDTO message;
  final BuildContext context;

  const MessageLoadedEvent(this.context, this.message);

  @override
  List<Object?> get props => [context, message];
}

class MessageLoadingEvent extends MessageEvent {
  const MessageLoadingEvent();

  @override
  List<Object?> get props => [];
}
