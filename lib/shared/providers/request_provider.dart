import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Request state for tracking API calls
class RequestState {
  final bool isLoading;
  final bool isCompleted;
  final String error;

  const RequestState({
    this.isLoading = false,
    this.isCompleted = false,
    this.error = '',
  });

  RequestState copyWith({bool? isLoading, bool? isCompleted, String? error}) {
    return RequestState(
      isLoading: isLoading ?? this.isLoading,
      isCompleted: isCompleted ?? this.isCompleted,
      error: error ?? this.error,
    );
  }

  @override
  String toString() {
    return 'RequestState(isLoading: $isLoading, isCompleted: $isCompleted, error: $error)';
  }
}

/// Notifier for managing request states across the app
class RequestNotifier extends StateNotifier<Map<String, RequestState>> {
  RequestNotifier() : super({});

  /// Set loading state for a request
  void setLoading(String key) {
    state = {...state, key: const RequestState(isLoading: true)};
  }

  /// Set success state for a request
  void setSuccess(String key) {
    state = {...state, key: const RequestState(isCompleted: true)};
  }

  /// Set error state for a request
  void setError(String key, String error) {
    state = {...state, key: RequestState(isCompleted: true, error: error)};
  }

  /// Clear error for a request
  void clearError(String key) {
    final currentState = state[key];
    if (currentState != null) {
      state = {...state, key: currentState.copyWith(error: null)};
    }
  }

  /// Reset state for a request
  void reset(String key) {
    final newState = Map<String, RequestState>.from(state);
    newState.remove(key);
    state = newState;
  }

  /// Get request state by key
  RequestState getState(String key) {
    return state[key] ?? const RequestState();
  }

  /// Check if request is loading
  bool isLoading(String key) {
    return state[key]?.isLoading ?? false;
  }

  /// Check if request has error
  bool hasError(String key) {
    return state[key]?.error != null;
  }

  /// Get error message
  String? getError(String key) {
    return state[key]?.error;
  }
}

/// Provider for request notifier
final requestNotifierProvider =
    StateNotifierProvider<RequestNotifier, Map<String, RequestState>>(
      (ref) => RequestNotifier(),
    );

/// Provider for specific request state
final requestStateProvider = Provider.family<RequestState, String>((ref, key) {
  final requestStates = ref.watch(requestNotifierProvider);

  return requestStates[key] ?? const RequestState();
});
