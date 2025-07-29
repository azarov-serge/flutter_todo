class QueryStatus {
  final bool isFetching;
  final bool isFetched;
  final String error;

  QueryStatus({
    this.isFetching = false,
    this.isFetched = false,
    this.error = '',
  });

  QueryStatus copyWith({
    bool? isFetching,
    bool? isFetched,
    String? error,
  }) {
    return QueryStatus(
      isFetching: isFetching ?? this.isFetching,
      isFetched: isFetched ?? this.isFetched,
      error: error ?? this.error,
    );
  }

  @override
  String toString() {
    return 'QueryStatus(isFetching: $isFetching, isFetched: $isFetched, error: $error)';
  }
}
