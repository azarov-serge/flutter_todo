import 'dart:convert';

import 'helpers/types.dart';

import 'helpers/query_state.dart';

// Абстрактный базовый класс для запросов
abstract class AbstractQuery<T> {
  QueryState<T> state;
  QueryState<T> initialState;

  AbstractQuery(
      {required this.state,
      QueryState<T>? initialState,
      QueryState<T> Function(QueryState<T>? data)? build})
      : initialState = initialState ?? state.copyWith();

  // Получение значения параметра
  T getParamsValue<T>(String key, [T? defaultValue]) {
    return (state.params[key] ?? defaultValue) as T;
  }

  // Метод для копирования (должен быть реализован в наследниках)
  Query<T> copyWith(QueryState<T> data);

  // Создание URL
  String createUrl([QueryParams? params]) {
    final mergedParams = {...?state.defaultParams, ...state.params, ...?params};
    final query = AbstractQuery.createParams(mergedParams);
    return '${state.baseUrl}${state.urlParam}${query.isNotEmpty ? '?$query' : ''}';
  }

  // Создание ключа
  String createKey([String? url, QueryParams? params]) {
    final idPart = state.id.isNotEmpty ? '/${state.id}' : '';
    return '[${state.method}]:${url ?? createUrl(params)}$idPart';
  }

  // Создание строки URL из строки
  static String createUrlString(String data) {
    final uri = Uri.parse(data);
    if (uri.queryParameters.isEmpty) {
      return uri.path;
    }
    return '${uri.path}?${createParams(uri.queryParameters)}';
  }

  // Преобразование параметров в строку запроса
  static String createParams(QueryParams params, [StringifyOptions? options]) {
    if (params.isEmpty) {
      return '';
    }

    // Фильтрация пустых параметров
    final filteredParams = Map.fromEntries(
      params.entries.where((entry) => entry.value != null && entry.value != ''),
    );

    // Сортировка ключей
    final sortedKeys = filteredParams.keys.toList()..sort();

    // Обработка значений параметров
    final processedParams = Map.fromEntries(
      sortedKeys.map((key) {
        dynamic value = filteredParams[key];
        if (value is List) {
          // Сортировка элементов массива
          value = List.from(value)
            ..sort((a, b) => jsonEncode(a).compareTo(jsonEncode(b)));
        }
        return MapEntry(key, value);
      }),
    );

    // Преобразование в строку запроса
    final queryPairs = processedParams.entries.map((entry) {
      final key = Uri.encodeComponent(entry.key);
      final value = Uri.encodeComponent(entry.value.toString());
      return '$key=$value';
    });

    return queryPairs.join('&');
  }

  reset() {
    state = initialState.copyWith();
  }
}

// Конкретная реализация запроса
class Query<T> extends AbstractQuery<T> {
  Query({required super.state, super.initialState});

  @override
  Query<T> copyWith(QueryState<T>? data) {
    return Query(
      state: state.copyWith(
        id: data?.id ?? state.id,
        baseUrl: data?.baseUrl ?? state.baseUrl,
        method: data?.method ?? state.method,
        params: data?.params ?? state.params,
        defaultParams: data?.defaultParams ?? state.defaultParams,
        urlParam: data?.urlParam ?? state.urlParam,
        key: data?.key ?? state.key,
      ),
      initialState: initialState,
    );
  }

  // Проверка типа
  static bool isInstance(dynamic value) {
    return value is Query;
  }
}
