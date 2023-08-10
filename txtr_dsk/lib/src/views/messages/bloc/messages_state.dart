import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:txtr_shared/txtr_shared.dart';

@immutable
sealed class MessagesState extends Equatable {}

enum MessagesStatus { ok, badHost, error }

class MessagesLoadingState extends MessagesState {
  @override
  List<Object?> get props => [];
}

class MessagesLoadedState extends MessagesState {
  final List<List<TxtrMessageDTO>> messages;

  MessagesLoadedState(this.messages);

  @override
  List<Object?> get props => [messages];
}

class MessagesErrorState extends MessagesState {
  final MessagesStatus status;
  final String error;

  MessagesErrorState(this.status, {this.error = ''});

  @override
  List<Object?> get props => [status, error];
}
