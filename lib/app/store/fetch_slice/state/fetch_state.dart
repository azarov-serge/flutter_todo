import 'package:queries/queries.dart';

/// Состояние для хранения статусов всех запросов
class FetchState {
  final Map<String, QueryStatus> statuses;

  const FetchState({this.statuses = const {}});

  /// Создание копии с изменениями
  FetchState copyWith({Map<String, QueryStatus>? statuses}) {
    return FetchState(statuses: statuses ?? this.statuses);
  }

  /// Создание пустого состояния
  factory FetchState.initial() => const FetchState();

  /// Получить статус по ключу
  QueryStatus status(String key) {
    return statuses[key] ?? QueryStatus();
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FetchState && other.statuses == statuses;
  }

  @override
  int get hashCode => statuses.hashCode;

  @override
  String toString() => 'FetchState(statuses: $statuses)';
}
