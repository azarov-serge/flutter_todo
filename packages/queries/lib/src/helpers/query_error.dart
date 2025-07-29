class QueryError {
  final int status; // HTTP-статус
  final String message; // Сообщение об ошибке

  QueryError({required this.status, required this.message});
}
