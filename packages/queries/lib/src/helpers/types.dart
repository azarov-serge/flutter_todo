// Псевдонимы типов
typedef QueryParams = Map<String, dynamic>; // Параметры запроса
typedef StringifyOptions =
    Map<String, dynamic>; // Опции для строкового представления

// HTTP-методы
class QueryMethod {
  static const get = "GET";
  static const post = "POST";
  static const put = "PUT";
  static const patch = "PATCH";
  static const delete = "DELETE";
}
