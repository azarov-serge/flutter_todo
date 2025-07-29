import 'package:queries/queries.dart';
import 'package:redux/redux.dart';
import '../state/fetch_state.dart';
import '../actions/fetch_actions.dart';

/// Редюсер для обработки действий
Reducer<FetchState> fetchReducer = (state, action) {
  if (action is FetchStartAction) {
    final status = state.statuses[action.key] ?? QueryStatus();

    return state.copyWith(
      statuses: {
        ...state.statuses,
        action.key: status.copyWith(
          isFetching: true,
          isFetched: false,
          error: null,
        ),
      },
    );
  }

  if (action is FetchSuccessAction) {
    return state.copyWith(
      statuses: {
        ...state.statuses,
        action.key: QueryStatus(isFetching: false, isFetched: true),
      },
    );
  }

  if (action is FetchFailureAction) {
    return state.copyWith(
      statuses: {
        ...state.statuses,
        action.key: QueryStatus(
          isFetching: false,
          isFetched: true,
          error: action.error,
        ),
      },
    );
  }

  if (action is FetchResetAction) {
    final newStatuses = <String, QueryStatus>{...state.statuses};
    newStatuses.remove(action.key);
    return state.copyWith(statuses: newStatuses);
  }

  if (action is FetchClearErrorAction) {
    final status = state.statuses[action.key] ?? QueryStatus();

    return state.copyWith(
      statuses: {
        ...state.statuses,
        action.key: status.copyWith(error: ''),
      },
    );
  }

  return state;
};
