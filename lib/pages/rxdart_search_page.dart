import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import '../fake_api.dart';

class RxDartSearchPage extends StatefulWidget {
  const RxDartSearchPage({super.key});

  @override
  State<RxDartSearchPage> createState() => _RxDartSearchPageState();
}

class _RxDartSearchPageState extends State<RxDartSearchPage> {
  final _controller = TextEditingController();
  final _searchSubject = BehaviorSubject<String>.seeded('');
  late final Stream<_SearchState> _stateStream;
  int _apiCallCount = 0;

  @override
  void initState() {
    super.initState();
    _stateStream = _searchSubject.stream
        .debounceTime(const Duration(milliseconds: 400))
        .distinct()
        .switchMap((query) => _search(query))
        .shareReplay(maxSize: 1); 
  }

  Stream<_SearchState> _search(String query) async* {
    if (query.isEmpty) {
      yield _SearchState.empty(_apiCallCount);
      return;
    }

    _apiCallCount++; 
    yield _SearchState.loading(_apiCallCount);

    final results = await FakeSearchApi.search(query);
    yield _SearchState.success(results, _apiCallCount);
  }

  void _clearSearch() {
    _controller.clear();
    _searchSubject.add('');
  }

  @override
  void dispose() {
    _searchSubject.close();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('📡 RxDart Approach'),
        backgroundColor: Colors.pink.shade100,
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            color: Colors.pink.shade50,
            child: const Text(
              '✅ switchMap auto-cancels old requests',
              style: TextStyle(color: Colors.pink),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: StreamBuilder<_SearchState>(
              stream: _stateStream,
              initialData: _SearchState.empty(0),
              builder: (context, snapshot) {
                final isLoading = snapshot.data?.isLoading ?? false;
                return TextField(
                  controller: _controller,
                  onChanged: _searchSubject.add,
                  decoration: InputDecoration(
                    hintText: 'Search...',
                    prefixIcon: const Icon(Icons.search),
                    border: const OutlineInputBorder(),
                    suffixIcon: isLoading
                        ? const Padding(
                            padding: EdgeInsets.all(12),
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          )
                        : _controller.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: _clearSearch,
                              )
                            : null,
                  ),
                );
              },
            ),
          ),
          Expanded(
            child: StreamBuilder<_SearchState>(
              stream: _stateStream,
              initialData: _SearchState.empty(0),
              builder: (context, snapshot) {
                final state = snapshot.data!;

                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'API Calls: ${state.apiCallCount}',
                        style:
                            const TextStyle(fontSize: 18, color: Colors.pink),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Expanded(child: _buildContent(state)),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(_SearchState state) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.results.isEmpty) {
      return const Center(child: Text('Start typing to search...'));
    }

    return ListView.builder(
      itemCount: state.results.length,
      itemBuilder: (context, index) {
        final result = state.results[index];
        return ListTile(
          leading: Text(result.icon, style: const TextStyle(fontSize: 24)),
          title: Text(result.title),
          subtitle: Text(result.subtitle),
        );
      },
    );
  }
}

class _SearchState {
  final List<SearchResult> results;
  final bool isLoading;
  final int apiCallCount;

  _SearchState._({
    this.results = const [],
    this.isLoading = false,
    this.apiCallCount = 0,
  });

  factory _SearchState.empty(int count) =>
      _SearchState._(apiCallCount: count);
  factory _SearchState.loading(int count) =>
      _SearchState._(isLoading: true, apiCallCount: count);
  factory _SearchState.success(List<SearchResult> results, int count) =>
      _SearchState._(results: results, apiCallCount: count);
}