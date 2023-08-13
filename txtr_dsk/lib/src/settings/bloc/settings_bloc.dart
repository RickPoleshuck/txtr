import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:txtr_dsk/src/services/phone_finder.dart';
import 'package:txtr_dsk/src/settings/bloc/settings_model.dart';
import 'package:txtr_dsk/src/settings/bloc/settings_service.dart';
import 'package:txtr_shared/txtr_shared.dart';

part 'settings_event.dart';

part 'settings_state.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  SettingsBloc() : super(SettingsLoading()) {
    on<SettingsLoadEvent>((event, emit) async {
      final phoneFinder = PhoneFinder();
      final settings = SettingsService.load();
      final phones = await phoneFinder.findPhones();
      emit(SettingsLoaded(settings, phones));
    });

    on<SettingsSaveEvent>((event, emit) async {
      await SettingsService.save(event.settings);
      emit(SettingsSaved(event.settings));
    });
  }
}
