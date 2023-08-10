import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:txtr_dsk/src/settings/settings_view.dart';
import 'package:txtr_dsk/src/views/message/bloc/message_bloc.dart';
import 'package:txtr_dsk/src/views/message/bloc/message_event.dart';
import 'package:txtr_dsk/src/views/message/bloc/message_state.dart';
import 'package:txtr_dsk/src/views/messages/bloc/messages_bloc.dart';
import 'package:txtr_shared/txtr_shared.dart';

import '../messages/bloc/messages_event.dart';

class MessageView extends StatelessWidget {
  final _formKey = GlobalKey<FormBuilderState>();

  MessageView({
    super.key,
  });

  static const routeName = '/message';

  @override
  Widget build(BuildContext context) {
    final contact =
        ModalRoute.of(context)!.settings.arguments as TxtrContactDTO?;
    return BlocProvider(
      create: (context) => MessageBloc()
        ..add(MessageLoadedEvent(context, TxtrMessageDTO.empty())),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('TXTR Message'),
          actions: [
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () {
                Navigator.restorablePushNamed(context, SettingsView.routeName);
              },
            ),
          ],
        ),
        body: BlocBuilder<MessageBloc, MessageState>(
          builder: (context, state) {
            switch (state) {
              case MessageSendingEvent():
                return const Center(
                  child: CircularProgressIndicator(),
                );
              case MessageLoadedState():
                return FormBuilder(
                    key: _formKey,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    child: Column(
                      children: [
                        FormBuilderTextField(
                          name: 'name',
                          validator: FormBuilderValidators.match('^.{4,}\$',
                              errorText: 'Requires at least 4 characters'),
                          decoration: const TxtrInputDecoration('Name'),
                          initialValue: contact?.name ?? '',
                        ),
                        FormBuilderTextField(
                          name: 'address',
                          validator: FormBuilderValidators.match('^.{4,}\$',
                              errorText: 'Requires at least 4 characters'),
                          decoration: const TxtrInputDecoration('Address'),
                          initialValue: contact?.phones[0].number ?? '',
                        ),
                        FormBuilderTextField(
                          name: 'body',
                          maxLines: 6,
                          validator: FormBuilderValidators.match('^.{1,}\$\$',
                              errorText: 'Cannot be empty'),
                          decoration: const TxtrInputDecoration('Message'),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ElevatedButton(
                                onPressed: () {
                                  _formKey.currentState!.save();
                                  final formData = _formKey.currentState!.value;
                                  context.read<MessageBloc>().add(
                                      MessageSendEvent(
                                          TxtrMessageDTO.fromJson(formData)));
                                  Navigator.pop(context);
                                },
                                child: const Text('Send')),
                            ElevatedButton(
                                onPressed: () {
                                  _formKey.currentState!.reset();
                                },
                                child: const Text('Reset')),
                          ],
                        )
                      ],
                    ));
              case MessageErrorState():
                return const Center(
                  child: Text("Error"),
                );
            }
          },
        ),
      ),
    );
  }
}
