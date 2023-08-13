import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:txtr_dsk/src/settings/bloc/settings_model.dart';
import 'package:txtr_dsk/src/settings/bloc/settings_service.dart';
import 'package:txtr_dsk/src/settings/settings_view.dart';
import 'package:txtr_dsk/src/views/contacts/bloc/contacts_bloc.dart';
import 'package:txtr_dsk/src/views/contacts/bloc/contacts_event.dart';
import 'package:txtr_dsk/src/views/message/message_view.dart';
import 'package:txtr_dsk/src/views/txtr_scaffold.dart';
import 'package:txtr_shared/txtr_shared.dart';
import 'package:window_manager/window_manager.dart';

import 'bloc/contacts_state.dart';

class ContactsView extends StatelessWidget with WindowListener {
  ContactsView({
    super.key,
  });

  Timer? refreshTimer;
  static const routeName = '/contacts';
  static final ContactsBloc _contactsBloc = ContactsBloc()
    ..add(ContactsLoadEvent());

  @override
  void onWindowFocus() {
    _contactsBloc.add(ContactsCheckEvent());
    refreshTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      _contactsBloc.add(ContactsCheckEvent());
    });
  }

  @override
  void onWindowBlur() {
    if (refreshTimer != null) {
      refreshTimer!.cancel();
    }
  }

  @override
  Widget build(BuildContext context) {
    windowManager.addListener(this);
    final SettingsModel settings = SettingsService.load();
    return BlocProvider(
      create: (context) => _contactsBloc,
      child: TxtrScaffold(
        bloc: _contactsBloc,
        context: context,
        appBar: AppBar(
          title: Text('SMS Contacts - ${settings.phone.name}'),
          actions: [
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () {
                context.push(SettingsView.routeName);
              },
            ),
          ],
        ),
        body: BlocBuilder<ContactsBloc, ContactsState>(
          builder: (context, state) {
            switch (state) {
              case ContactsLoadingState():
                return const Center(
                  child: CircularProgressIndicator(),
                );
              case ContactsLoadedState():
                final contacts = state.contacts;
                return ScrollablePositionedList.builder(
                    itemCount: contacts.length,
                    itemBuilder: (context, index) {
                      final contact = contacts[index];
                      return _ContactTile(contact, context);
                    });
              case ContactsErrorState():
                return Center(
                  child: Text('Error: ${state.error}'),
                );
            }
          },
        ),
      ),
    );
  }
}

class _ContactTile extends StatefulWidget {
  _ContactTile(this.contact, this.context, {super.key});

  final TxtrContactDTO contact;
  final BuildContext context;
  bool expanded = false;

  @override
  State<_ContactTile> createState() => _ContactTileState();
}

class _ContactTileState extends State<_ContactTile> {
  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        IconButton(
          onPressed: () {
            context.push(MessageView.routeName, extra: widget.contact);
          },
          icon: const Icon(Icons.reply),
        ),
        Expanded(
          child: ExpansionTile(
              onExpansionChanged: (expanded) {
                setState(() {
                  widget.expanded = expanded;
                });
                debugPrint('expanded: $expanded');
              },
              title: Text(
                '${widget.contact.name}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              children: widget.contact.phones
                  .map(
                    (m) => SizedBox(
                      width: double.infinity,
                      child: Text('${m.number} - ${m.label}'),
                    ),
                  )
                  .toList()),
        ),
      ],
    );
  }
}
