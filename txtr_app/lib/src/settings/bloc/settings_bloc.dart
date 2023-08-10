import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:txtr_app/src/settings/bloc/settings_model.dart';
import 'package:txtr_app/src/settings/bloc/settings_service.dart';

part 'settings_event.dart';
part 'settings_state.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  SettingsBloc() : super(SettingsLoading()) {
    on<SettingsLoadEvent>((event, emit) async {
      final settings = await SettingsService.load();
      emit(SettingsLoaded(settings));
    });

    on<SettingsSaveEvent>((event, emit) async {
      await SettingsService.save(event.settings);
    });
  }
}
