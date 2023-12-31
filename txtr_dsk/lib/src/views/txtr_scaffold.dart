import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:txtr_dsk/src/views/contacts/contacts_view.dart';
import 'package:txtr_dsk/src/views/message/message_view.dart';
import 'package:txtr_dsk/src/views/messages/bloc/messages_event.dart';
import 'package:txtr_shared/txtr_shared.dart';

class TxtrScaffold extends Scaffold {
  TxtrScaffold(
      {super.key,
      required Widget body,
      required BuildContext context,
      required Bloc bloc,
      AppBar? appBar,
      BottomNavigationBar? bottomNavigationBar})
      : super(
            appBar: appBar,
            body: body,
            bottomNavigationBar: _TxtrNavigationBar(bloc, context));
}

class _TxtrNavigationBar extends BottomNavigationBar {
  _TxtrNavigationBar(final Bloc bloc, final BuildContext context)
      : super(
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.edit),
              label: '',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.refresh),
              label: '',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.people),
              label: '',
            ),
          ],
          showSelectedLabels: false,
          showUnselectedLabels: false,
          onTap: (index) {
            switch (index) {
              case 0:
                context.push(MessageView.routeName, extra: TxtrContactDTO.empty());
                break;
              case 1:
                bloc.add(MessagesLoadEvent());
                break;
              case 2:
                context.push(ContactsView.routeName);
                break;
            }
          },
        );
}
