import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

@immutable
abstract class ContactsEvent extends Equatable {
  const ContactsEvent();
}

class ContactsLoadEvent extends ContactsEvent {
  @override
  List<Object?> get props => [];
}

class ContactsCheckEvent extends ContactsEvent {
  @override
  List<Object?> get props => [];
}

class ContactsErrorEvent extends ContactsEvent {
  @override
  List<Object?> get props => [];
}
