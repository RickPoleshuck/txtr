import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:txtr_dsk/src/settings/settings_view.dart';
import 'package:txtr_dsk/src/views/error/error_bloc.dart';
import 'package:txtr_dsk/src/views/txtr_scaffold.dart';

class ErrorView extends StatelessWidget {
  ErrorView({
    super.key,
  });

  static const routeName = '/error';

  @override
  Widget build(BuildContext context) {
    final ErrorBloc errorBloc = ErrorBloc();
    return BlocProvider(
      create: (_) => ErrorBloc(),
      child: TxtrScaffold(
        bloc: errorBloc,
        context: context,
        appBar: AppBar(
          title: const Text('Error'),
          actions: [
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () {
                context.push(SettingsView.routeName);
              },
            ),
          ],
        ),
        body: BlocBuilder<ErrorBloc, ErrorState>(
          builder: (context, state) {
            return Center(
              child: Text((state as ErrorOccurred).message),
            );
          },
        ),
      ),
    );
  }
}
