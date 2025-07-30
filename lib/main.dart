import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';

import 'app/app.dart';
import 'shared/shared.dart';

Future<void> run() async {
  await DISetup.setup();

  runApp(ProviderScope(child: const App()));
}

void main() async {
  runZonedGuarded(
    () => run(),
    (error, stack) => SafeArea(
      child: Scaffold(body: Center(child: Text('$error \n $stack'))),
    ),
  );
}
