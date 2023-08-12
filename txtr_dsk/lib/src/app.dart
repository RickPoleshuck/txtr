import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:txtr_dsk/src/settings/bloc/settings_bloc.dart';
import 'package:txtr_dsk/src/views/contacts/contacts_view.dart';
import 'package:txtr_dsk/src/views/error/error_bloc.dart';
import 'package:txtr_dsk/src/views/error/error_view.dart';
import 'package:txtr_dsk/src/views/message/message_view.dart';
import 'package:txtr_dsk/src/views/messages/messages_view.dart';

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
          create: (_) =>
          SettingsBloc()
            ..add(SettingsLoadEvent()),
        ),
        BlocProvider(
          create: (_) => ErrorBloc(),
        ),
      ],
      child: MaterialApp(
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
        onGenerateRoute: (RouteSettings routeSettings) {
          return MaterialPageRoute<void>(
            settings: routeSettings,
            builder: (BuildContext context) {
              switch (routeSettings.name) {
                case SettingsView.routeName:
                  return SettingsView();
                case MessageView.routeName:
                  return MessageView();
                case ContactsView.routeName:
                  return ContactsView();
                case ErrorView.routeName:
                  return ErrorView();
                case MessagesView.routeName:
                default:
                  return MessagesView();
              }
            },
          );
        },
        theme: ThemeData(),
        darkTheme: ThemeData.dark(),
      ),
    );
  }
}
