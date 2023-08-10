import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:txtr_app/src/settings/bloc/settings_bloc.dart';
import 'package:txtr_app/src/settings/bloc/settings_model.dart';

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
                        FormBuilderTextField(
                          name: 'phoneName',
                          validator: FormBuilderValidators.match('^.{4,}\$',
                              errorText: 'Requires at least 4 characters'),
                          decoration: const SmsInputDecoration('Phone Name'),
                          initialValue: state.settings.phoneName,
                        ),
                        FormBuilderTextField(
                          name: 'login',
                          validator: FormBuilderValidators.match('^.{4,}\$',
                              errorText: 'Requires at least 4 characters'),
                          decoration: const SmsInputDecoration('Login'),
                          initialValue: state.settings.login,
                        ),
                        FormBuilderTextField(
                          name: 'passwd',
                          obscureText: true,
                          validator: FormBuilderValidators.match('^.{8,}\$',
                              errorText: 'Requires at least 8 characters'),
                          decoration: const SmsInputDecoration('Password'),
                          initialValue: state.settings.passwd,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ElevatedButton(
                                onPressed: () {
                                  _formKey.currentState!.save();
                                  final formData = _formKey.currentState!.value;
                                  context.read<SettingsBloc>().add(
                                      SettingsSaveEvent(
                                          SettingsModel.fromJson(formData)));
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

class SmsInputDecoration extends InputDecoration {
  const SmsInputDecoration(String hintText)
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
