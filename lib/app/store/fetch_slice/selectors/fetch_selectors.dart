import 'package:queries/queries.dart';
import '../state/fetch_state.dart';

/// Селекторы для удобного доступа к статусам
extension FetchSelectors on FetchState {
  QueryStatus status(String key) => statuses[key] ?? QueryStatus();
}
