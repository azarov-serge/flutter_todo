import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';

import '../get_it/get_it.dart';

/// Main app provider that initializes all dependencies
final appProvider = Provider<GetIt>((ref) {
  return getIt;
});

/// Provider for dependency injection container
final getItProvider = Provider<GetIt>((ref) {
  return GetIt.instance;
});
