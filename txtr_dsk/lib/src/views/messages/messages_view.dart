import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:go_router/go_router.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:txtr_dsk/src/settings/bloc/settings_bloc.dart';
import 'package:txtr_dsk/src/settings/bloc/settings_service.dart';
import 'package:txtr_dsk/src/settings/settings_view.dart';
import 'package:txtr_dsk/src/utils/datetime_utils.dart';
import 'package:txtr_dsk/src/views/message/message_view.dart';
import 'package:txtr_dsk/src/views/messages/bloc/messages_bloc.dart';
import 'package:txtr_dsk/src/views/messages/bloc/messages_event.dart';
import 'package:txtr_dsk/src/views/txtr_scaffold.dart';
import 'package:txtr_shared/txtr_shared.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:window_manager/window_manager.dart';

import 'bloc/messages_state.dart';

class MessagesView extends StatelessWidget with WindowListener {
  MessagesView({
    super.key,
    required this.messagesBloc,
  });

  Timer? refreshTimer;
  static const routeName = '/messages';
  final MessagesBloc messagesBloc;

  @override
  void onWindowFocus() {
    messagesBloc.add(MessagesCheckEvent());
    refreshTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      messagesBloc.add(MessagesCheckEvent());
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
    String phoneName = SettingsService.load().phone.name;
    return TxtrScaffold(
      bloc: messagesBloc,
      context: context,
      appBar: AppBar(
        title: BlocConsumer<SettingsBloc, SettingsState>(
          listener: (context, state) {
            if (state is SettingsSaved) {
              phoneName = state.settings.phone.name;
            }
          },
          builder: (context, state) {
            return Text('SMS Messages - $phoneName');
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              context.push(SettingsView.routeName);
            },
          ),
        ],
      ),
      body: BlocBuilder<MessagesBloc, MessagesState>(
        builder: (context, state) {
          switch (state) {
            case MessagesLoadingState():
              return const Center(
                child: CircularProgressIndicator(),
              );
            case MessagesLoadedState():
              final messages = state.messages;
              return ScrollablePositionedList.builder(
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final messagesPerContact = messages[index];
                    return _ContactTile(messagesPerContact, context);
                  });
            case MessagesErrorState():
              return Center(
                child: Text('Error: ${state.error}'),
              );
          }
        },
      ),
    );
  }
}

class _ContactTile extends StatefulWidget {
  _ContactTile(this.contactMessages, this.context, {super.key});

  final List<TxtrMessageDTO> contactMessages;
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
            context.push(MessageView.routeName,
                extra: _contactFromMessage(widget.contactMessages[0]));
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
                '${widget.contactMessages[0].name} - (${widget.contactMessages.length})',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Visibility(
                visible: !widget.expanded,
                child: _MessageView(
                  widget.contactMessages[0],
                  title: true,
                ),
              ),
              children: widget.contactMessages
                  .map(
                    (m) => SizedBox(
                      width: double.infinity,
                      child: _MessageView(m),
                    ),
                  )
                  .toList()),
        ),
      ],
    );
  }

  TxtrContactDTO _contactFromMessage(final TxtrMessageDTO message) {
    final TxtrPhoneDTO phone = TxtrPhoneDTO(message.address, '', true);
    return TxtrContactDTO(message.name, message.name, [phone]);
  }
}

class _MessageView extends StatelessWidget {
  final TxtrMessageDTO message;
  final bool title;

  const _MessageView(this.message, {this.title = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: title
          ? EdgeInsets.zero
          : const EdgeInsets.only(left: 16.0, right: 48.0),
      child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment:
              message.sent ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(DateTimeUtils.prettyDate(message.date)),
            SelectableLinkify(
              onOpen: (link) async {
                final uri = Uri.parse(link.url);
                if (!await launchUrl(uri)) {
                  throw Exception('Could not launch $link');
                }
                debugPrint('link: $link');
              },
              style: const TextStyle(color: Colors.black),
              text: message.body,
            ),
            const Text(''),
          ]),
    );
  }
}
