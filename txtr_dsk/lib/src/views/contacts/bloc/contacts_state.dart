import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:txtr_shared/txtr_shared.dart';

@immutable
sealed class ContactsState extends Equatable {}

enum ContactsStatus { ok, badHost, error }

class ContactsLoadingState extends ContactsState {
  @override
  List<Object?> get props => [];
}

class ContactsLoadedState extends ContactsState {
  final List<TxtrContactDTO> contacts;

  ContactsLoadedState(this.contacts);

  @override
  List<Object?> get props => [contacts];
}

class ContactsErrorState extends ContactsState {
  final ContactsStatus status;
  final String error;

  ContactsErrorState(this.status, {this.error = ''});

  @override
  List<Object?> get props => [status, error];
}
