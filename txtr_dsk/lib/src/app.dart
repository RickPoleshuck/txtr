import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:txtr_dsk/src/settings/bloc/settings_bloc.dart';
import 'package:txtr_dsk/src/views/contacts/contacts_view.dart';
import 'package:txtr_dsk/src/views/error/error_bloc.dart';
import 'package:txtr_dsk/src/views/error/error_view.dart';
import 'package:txtr_dsk/src/views/message/message_view.dart';
import 'package:txtr_dsk/src/views/messages/bloc/messages_bloc.dart';
import 'package:txtr_dsk/src/views/messages/bloc/messages_event.dart';
import 'package:txtr_dsk/src/views/messages/messages_view.dart';
import 'package:txtr_shared/txtr_shared.dart';

import 'settings/settings_view.dart';

class App extends StatelessWidget {
  const App({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => SettingsBloc()..add(SettingsLoadEvent()),
        ),
        BlocProvider(
          create: (_) => ErrorBloc(),
        ),
        BlocProvider(
          create: (_) => MessagesBloc(),
        ),
      ],
      child: MaterialApp.router(
        restorationScopeId: 'app',
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('en', ''), // English, no country code
        ],
        onGenerateTitle: (BuildContext context) =>
            AppLocalizations.of(context)!.appTitle,
        routerConfig: GoRouter(
          routes: [
            GoRoute(
                path: MessagesView.routeName,
                builder: (context, state) {
                  MessagesBloc bloc = BlocProvider.of<MessagesBloc>(context);
                  bloc.add(MessagesLoadEvent());
                  return MessagesView(messagesBloc: bloc);
                }),
            GoRoute(
              path: MessageView.routeName,
              builder: (context, state) {
                final TxtrContactDTO contact = state.extra as TxtrContactDTO;
                return MessageView(
                  contact: contact,
                );
              },
            ),
            GoRoute(
              path: SettingsView.routeName,
              builder: (context, state) => SettingsView(),
            ),
            GoRoute(
              path: ContactsView.routeName,
              builder: (context, state) => ContactsView(),
            ),
            GoRoute(
              path: ErrorView.routeName,
              builder: (context, state) => ErrorView(),
            ),
          ],
          initialLocation: '/messages',
        ),
        theme: ThemeData(),
        darkTheme: ThemeData.dark(),
      ),
    );
  }
}
