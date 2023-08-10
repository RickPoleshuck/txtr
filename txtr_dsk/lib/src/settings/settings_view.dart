import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:txtr_dsk/src/settings/bloc/settings_bloc.dart';
import 'package:txtr_dsk/src/settings/bloc/settings_model.dart';

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
          child: BlocBuilder<SettingsBloc, SettingsState>(
              builder: (context, state) {
            switch (state) {
              case SettingsLoading():
                return const Center(
                  child: CircularProgressIndicator(),
                );
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
                          initialValue: state.settings.phoneIp,
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
                                      SettingsModel.fromJson(formData);
                                  settings.phoneName = state.phones
                                      .firstWhere(
                                          (p) => p.ip == settings.phoneIp)
                                      .name; // @TODO get this from the value of the field???
                                  context
                                      .read<SettingsBloc>()
                                      .add(SettingsSaveEvent(settings));
                                  Navigator.pop(context);
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
            }
          }),
        ),
      ),
    );
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
