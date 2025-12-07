import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../fake_api.dart';

class Debouncer {
  final Duration delay;
  Timer? _timer;

  Debouncer({this.delay = const Duration(milliseconds: 400)});

  void call(void Function() action) {
    _timer?.cancel();
    _timer = Timer(delay, action);
  }

  void dispose() => _timer?.cancel();
}

final apiCallCountProvider = StateProvider<int>((ref) => 0);
final searchQueryProvider = StateProvider<String>((ref) => '');

final _debouncerProvider = Provider.autoDispose<Debouncer>((ref) {
  final debouncer = Debouncer();
  ref.onDispose(debouncer.dispose);
  return debouncer;
});

final debouncedQueryProvider = StreamProvider.autoDispose<String>((ref) {
  final controller = StreamController<String>();
  final debouncer = ref.watch(_debouncerProvider);

  // Emit empty string immediately so we don't start in loading state
  controller.add('');

  ref.listen(searchQueryProvider, (_, query) {
    debouncer(() => controller.add(query));
  });

  ref.onDispose(controller.close);
  return controller.stream;
});

final searchResultsProvider =
    FutureProvider.autoDispose<List<SearchResult>>((ref) async {
  final query = await ref.watch(debouncedQueryProvider.future);

  if (query.isEmpty) return [];

  ref.read(apiCallCountProvider.notifier).state++;
  return FakeSearchApi.search(query);
});

class RiverpodSearchPage extends ConsumerStatefulWidget {
  const RiverpodSearchPage({super.key});

  @override
  ConsumerState<RiverpodSearchPage> createState() => _RiverpodSearchPageState();
}

class _RiverpodSearchPageState extends ConsumerState<RiverpodSearchPage> {
  final _controller = TextEditingController();

  void _clearSearch() {
    _controller.clear();
    ref.read(searchQueryProvider.notifier).state = '';
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final resultsAsync = ref.watch(searchResultsProvider);
    final apiCallCount = ref.watch(apiCallCountProvider);
    final query = ref.watch(searchQueryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('🪄 Riverpod Approach'),
        backgroundColor: Colors.purple.shade100,
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            color: Colors.purple.shade50,
            child: const Text(
              '✅ Provider chain with auto-dispose',
              style: TextStyle(color: Colors.purple),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _controller,
              onChanged: (query) {
                ref.read(searchQueryProvider.notifier).state = query;
              },
              decoration: InputDecoration(
                hintText: 'Search...',
                prefixIcon: const Icon(Icons.search),
                border: const OutlineInputBorder(),
                suffixIcon: query.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: _clearSearch,
                      )
                    : null,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'API Calls: $apiCallCount',
              style: const TextStyle(fontSize: 18, color: Colors.purple),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: resultsAsync.when(
              data: (results) => results.isEmpty
                  ? const Center(child: Text('Start typing to search...'))
                  : ListView.builder(
                      itemCount: results.length,
                      itemBuilder: (_, i) {
                        final result = results[i];
                        return ListTile(
                          leading: Text(result.icon,
                              style: const TextStyle(fontSize: 24)),
                          title: Text(result.title),
                          subtitle: Text(result.subtitle),
                        );
                      },
                    ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
            ),
          ),
        ],
      ),
    );
  }
}