import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stream_transform/stream_transform.dart';
import '../fake_api.dart';
import 'search_event_state.dart';

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  int _apiCallCount = 0;

  SearchBloc() : super(const SearchInitial()) {
    on<SearchQueryChanged>(
      _onQueryChanged,
      transformer: (events, mapper) => events
          .debounce(const Duration(milliseconds: 400))
          .switchMap(mapper),
    );
  }

  Future<void> _onQueryChanged(
    SearchQueryChanged event,
    Emitter<SearchState> emit,
  ) async {
    final query = event.query;

    if (query.isEmpty) {
      emit(const SearchInitial());
      return;
    }

    _apiCallCount++;
    emit(SearchLoading(apiCallCount: _apiCallCount));

    try {
      final results = await FakeSearchApi.search(query);
      emit(SearchSuccess(results, apiCallCount: _apiCallCount));
    } catch (e) {
      emit(SearchError(e.toString(), apiCallCount: _apiCallCount));
    }
  }
}