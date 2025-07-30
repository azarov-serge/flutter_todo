import 'dart:convert';

import 'types.dart';

// Данные об ошибке запроса

// Абстрактный базовый класс для запросов
class QueryState<T> {
  String id; // Уникальный идентификатор
  final String baseUrl; // Базовый URL
  final String method; // HTTP-метод
  QueryParams params; // Параметры запроса
  QueryParams? defaultParams; // Параметры по умолчанию
  String urlParam; // Параметр URL
  String? _key; // Внутреннее поле для ключа
  T? data;

  // Конструктор
  QueryState({
    this.id = "",
    required this.baseUrl,
    this.method = QueryMethod.get,
    QueryParams? params,
    this.defaultParams,
    this.urlParam = "",
    String? key,
    this.data,
  }) : params = params ?? {} {
    if (key != null) {
      _key = key;
    }
  }

  // Уникальный ключ ресурса
  String get key {
    if (_key != null) {
      return _key!;
    }
    return createKey();
  }

  // Короткий ключ (без параметров)
  String get keyShort => '[${method}]:$baseUrl';

  // Полный URL
  String get url => createUrl();

  // Получение значения параметра
  T getParamsValue<T>(String key, [T? defaultValue]) {
    return (params[key] ?? defaultValue) as T;
  }

  // Метод для копирования (должен быть реализован в наследниках)
  QueryState<T> copyWith({
    String? id,
    String? baseUrl,
    String? method,
    QueryParams? params,
    QueryParams? defaultParams,
    String? urlParam,
    String? key,
    T? data,
  }) {
    return QueryState<T>(
      id: id ?? this.id,
      baseUrl: baseUrl ?? this.baseUrl,
      method: method ?? this.method,
      params: params ?? Map.from(this.params),
      defaultParams: defaultParams ?? this.defaultParams,
      urlParam: urlParam ?? this.urlParam,
      key: key ?? _key,
      data: data ?? this.data,
    );
  }

  // Создание URL
  String createUrl([QueryParams? params]) {
    // Объединяем параметры: по умолчанию + текущие + переданные
    final mergedParams = {...?defaultParams, ...this.params, ...?params};
    final query = QueryState.createParams(mergedParams);
    return '$baseUrl$urlParam${query.isNotEmpty ? '?$query' : ''}';
  }

  // Создание ключа
  String createKey([String? url, QueryParams? params]) {
    final idPart = id.isNotEmpty ? '/$id' : '';
    return '[${method}]:${url ?? createUrl(params)}$idPart';
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
}
