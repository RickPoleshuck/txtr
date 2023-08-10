part of 'settings_bloc.dart';

sealed class SettingsState extends Equatable {
  const SettingsState();
}

class SettingsLoading extends SettingsState {
  @override
  List<Object> get props => [];
}

class SettingsLoaded extends SettingsState {
  final SettingsModel settings;
  final List<PhoneDTO> phones;

  @override
  List<Object> get props => [settings, phones];

  const SettingsLoaded(this.settings, this.phones);
}
