import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:txtr_dsk/src/net/net_repository.dart';
import 'package:txtr_dsk/src/views/message/bloc/message_event.dart';
import 'package:txtr_dsk/src/views/message/bloc/message_state.dart';
import 'package:txtr_dsk/src/views/messages/bloc/messages_event.dart';
import 'package:txtr_shared/txtr_shared.dart';

class MessageBloc extends Bloc<MessageEvent, MessageState> {
  final NetRepository _netRepository = NetRepository();

  MessageBloc() : super(MessageLoadedState(TxtrMessageDTO.empty())) {
    on<MessageSendEvent>((event, emit) async {
      emit(MessageSendingEvent());
      await _netRepository
          .postMessage(event.message)
          .onError((error, stackTrace) {
        debugPrint(error.toString()); // @TODO - handle error
      });
    });

    on<MessageLoadedEvent>((event, emit) async {});
  }
}
