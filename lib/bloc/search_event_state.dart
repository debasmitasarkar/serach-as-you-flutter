import '../fake_api.dart';

sealed class SearchEvent {}

final class SearchQueryChanged extends SearchEvent {
  final String query;
  SearchQueryChanged(this.query);
}

sealed class SearchState {
  final int apiCallCount;
  const SearchState({this.apiCallCount = 0});
}

final class SearchInitial extends SearchState {
  const SearchInitial() : super();
}

final class SearchLoading extends SearchState {
  const SearchLoading({super.apiCallCount});
}

final class SearchSuccess extends SearchState {
  final List<SearchResult> results;
  const SearchSuccess(this.results, {super.apiCallCount});
}

final class SearchError extends SearchState {
  final String message;
  const SearchError(this.message, {super.apiCallCount});
}