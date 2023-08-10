import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:txtr_dsk/src/net/net_repository.dart';
import 'package:txtr_dsk/src/services/phone_finder.dart';
import 'package:txtr_dsk/src/views/messages/bloc/messages_event.dart';
import 'package:txtr_dsk/src/views/messages/bloc/messages_state.dart';

class MessagesBloc extends Bloc<MessagesEvent, MessagesState> {
  final NetRepository _netRepository = NetRepository();

  MessagesBloc() : super(MessagesLoadingState()) {
    on<MessagesLoadEvent>((event, emit) async {
      // @TODO - should only checkPrevious on error
      final checkPrevious = await PhoneFinder().checkPreviousPhone();
      if (!checkPrevious) {
        // bring up settings view
        emit(MessagesErrorState(MessagesStatus.badHost));
        return;
      }
      emit(MessagesLoadingState());
      try {
        final messages = await _netRepository.getMessages();
        emit(MessagesLoadedState(messages));
      } catch (e) {
        emit(MessagesErrorState(MessagesStatus.error, error: e.toString()));
      }
    });
    on<MessagesCheckEvent>((event, emit) async {
      final updateType = await _netRepository.getUpdates();
      switch (updateType) {
        case 'both':
        case 'contacts':
        case 'messages':
          add(MessagesLoadEvent());
          break;
        case 'none':
        default:
          break;
      }
    });
  }
}
