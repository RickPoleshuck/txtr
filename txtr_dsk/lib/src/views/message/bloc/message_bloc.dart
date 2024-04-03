import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:txtr_dsk/src/services/net_service.dart';
import 'package:txtr_dsk/src/views/message/bloc/message_event.dart';
import 'package:txtr_dsk/src/views/message/bloc/message_state.dart';
import 'package:txtr_shared/txtr_shared.dart';

class MessageBloc extends Bloc<MessageEvent, MessageState> {
  final NetService _netRepository = NetService();

  MessageBloc() : super(MessageLoadedState(TxtrMessageDTO.empty())) {
    on<MessageSendEvent>((event, emit) async {
      emit(MessageSendingState());
      try {
        await _netRepository.postMessage(event.message);
        emit(MessageSentState());
      } catch (e) {
        if (e is DioException && e.response!.statusCode! == 404) {
          add(MessageErrorEvent(e.message ?? 'not found'));
          return;
        }
        add(MessageErrorEvent(e.toString()));
        return;
      }
    });

    on<MessageLoadedEvent>((event, emit) async {});
    on<MessageErrorEvent>((event, emit) async {
      emit(MessageErrorState(event.errorMessage));
    });
  }
}
