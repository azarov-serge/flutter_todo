import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'dart:async';
import 'shared/get_it/di_setup.dart';

import 'app/store/app_slice/app_slice.dart';
import 'app/app.dart';
import 'shared/get_it/get_it.dart';

Future<void> run() async {
  await DISetup.setup();

  runApp(StoreProvider<AppState>(store: getIt(), child: const App()));
}

void main() async {
  runZonedGuarded(
    () => run(),
    (error, stack) => SafeArea(
      child: Scaffold(body: Center(child: Text('$error \n $stack'))),
    ),
  );
}
