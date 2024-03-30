import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:txtr_app/src/settings/bloc/settings_model.dart';
import 'package:txtr_app/src/settings/bloc/settings_service.dart';

part 'settings_event.dart';
part 'settings_state.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  SettingsBloc() : super(SettingsLoading()) {
    on<SettingsLoadEvent>((event, emit) async {
      final settings = await SettingsService.load();
      final ip = await NetworkInfo().getWifiIP() ?? '127.0.0.1';
      emit(SettingsLoaded(settings, ip));
    });

    on<SettingsSaveEvent>((event, emit) async {
      await SettingsService.save(event.settings);
    });
  }
}
