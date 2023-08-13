part of 'settings_bloc.dart';

sealed class SettingsEvent extends Equatable {
  const SettingsEvent();
}

class SettingsLoadEvent extends SettingsEvent {
  @override
  List<Object?> get props => [];
}

class SettingsSaveEvent extends SettingsEvent {
  final SettingsModel settings;

  @override
  List<Object?> get props => [settings];

  const SettingsSaveEvent(this.settings);
}

class SettingsChangedEvent extends SettingsEvent {
  final SettingsModel settings;

  @override
  List<Object?> get props => [settings];

  const SettingsChangedEvent(this.settings);
}
