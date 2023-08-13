import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:go_router/go_router.dart';
import 'package:txtr_dsk/src/settings/bloc/settings_bloc.dart';
import 'package:txtr_dsk/src/settings/bloc/settings_model.dart';
import 'package:txtr_dsk/src/views/messages/messages_view.dart';
import 'package:txtr_shared/txtr_shared.dart';

class SettingsView extends StatelessWidget {
  SettingsView({super.key});

  static const routeName = '/settings';

  final _formKey = GlobalKey<FormBuilderState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: BlocProvider(
          create: (_) => SettingsBloc()..add(SettingsLoadEvent()),
          child: BlocConsumer<SettingsBloc, SettingsState>(
              listener: (context, state) {
                debugPrint('SettingsView.blocConsumer: state = $state');
            if (state is SettingsSaved) {
              context.pop();
            }
          }, builder: (context, state) {
            switch (state) {
              case SettingsLoaded():
                return FormBuilder(
                    key: _formKey,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    child: Column(
                      children: [
                        FormBuilderDropdown(
                          name: 'phoneIp',
                          items: List<DropdownMenuItem>.from(state.phones.map(
                            (p) => DropdownMenuItem(
                              value: p.ip,
                              child: Text(
                                p.name,
                              ),
                            ),
                          )),
                          decoration: const TxtrInputDecoration('Phone Name'),
                          initialValue: state.settings.phone.ip,
                          dropdownColor: Colors.white,
                        ),
                        FormBuilderTextField(
                          name: 'login',
                          validator: FormBuilderValidators.match('^.{4,}\$',
                              errorText: 'Requires at least 4 characters'),
                          decoration: const TxtrInputDecoration('Login'),
                          initialValue: state.settings.login,
                        ),
                        FormBuilderTextField(
                          name: 'passwd',
                          obscureText: true,
                          validator: FormBuilderValidators.match('^.{8,}\$',
                              errorText: 'Requires at least 8 characters'),
                          decoration: const TxtrInputDecoration('Password'),
                          initialValue: state.settings.passwd,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ElevatedButton(
                                onPressed: () {
                                  _formKey.currentState!.save();
                                  final formData = _formKey.currentState!.value;
                                  final SettingsModel settings =
                                      _settingsFromForm(formData, state.phones);
                                  context
                                      .read<SettingsBloc>()
                                      .add(SettingsSaveEvent(settings));
                                },
                                child: const Text('Save')),
                            ElevatedButton(
                                onPressed: () {
                                  _formKey.currentState!.reset();
                                },
                                child: const Text('Reset')),
                          ],
                        )
                      ],
                    ));
              default:
                return const Center(
                  child: CircularProgressIndicator(),
                );
            }
          }),
        ),
      ),
    );
  }

  SettingsModel _settingsFromForm(
      final Map formData, final List<PhoneDTO> phones) {
    final String ip = formData['phoneIp'];
    PhoneDTO phone = phones.firstWhere((p) => p.ip == ip);
    SettingsModel settings =
        SettingsModel(formData['login'], formData['passwd'], phone, '');
    return settings;
  }
}

class TxtrInputDecoration extends InputDecoration {
  const TxtrInputDecoration(String hintText)
      : super(
          hintText: hintText,
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.greenAccent, width: 3.0),
          ),
          enabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.blueAccent, width: 3.0),
          ),
          errorBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.red, width: 3.0),
          ),
        );
}
