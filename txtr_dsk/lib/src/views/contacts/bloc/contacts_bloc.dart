import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:txtr_dsk/src/net/net_repository.dart';
import 'package:txtr_dsk/src/services/contact_service.dart';
import 'package:txtr_dsk/src/services/phone_finder.dart';
import 'package:txtr_dsk/src/views/contacts/bloc/contacts_event.dart';
import 'package:txtr_dsk/src/views/contacts/bloc/contacts_state.dart';

class ContactsBloc extends Bloc<ContactsEvent, ContactsState> {
  final NetRepository _netRepository = NetRepository();

  ContactsBloc() : super(ContactsLoadingState()) {
    on<ContactsLoadEvent>((event, emit) async {
      // @TODO - should only checkPrevious on error
      final checkPrevious = await PhoneFinder().checkPreviousPhone();
      if (!checkPrevious) {
        // bring up settings view
        emit(ContactsErrorState(ContactsStatus.badHost));
        return;
      }
      emit(ContactsLoadingState());
      try {
        final contacts = await ContactService().contacts();
        emit(ContactsLoadedState(contacts));
      } catch (e) {
        emit(ContactsErrorState(ContactsStatus.error, error: e.toString()));
      }
    });
    on<ContactsCheckEvent>((event, emit) async {
      final updateType = await _netRepository.getUpdates();
      switch (updateType) {
        case 'both':
        case 'contacts':
        case 'messages':
          add(ContactsLoadEvent());
          break;
        case 'none':
        default:
          break;
      }
    });
  }
}
