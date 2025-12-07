import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/search_bloc.dart';
import '../bloc/search_event_state.dart';

class BlocSearchPage extends StatelessWidget {
  const BlocSearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SearchBloc(),
      child: const _BlocSearchView(),
    );
  }
}

class _BlocSearchView extends StatefulWidget {
  const _BlocSearchView();

  @override
  State<_BlocSearchView> createState() => _BlocSearchViewState();
}

class _BlocSearchViewState extends State<_BlocSearchView> {
  final _controller = TextEditingController();

  void _clearSearch() {
    _controller.clear();
    context.read<SearchBloc>().add(SearchQueryChanged(''));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('📦 BLoC Approach'),
        backgroundColor: Colors.blue.shade100,
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            color: Colors.blue.shade50,
            child: const Text(
              '✅ Event transformer handles debounce + cancel',
              style: TextStyle(color: Colors.blue),
            ),
          ),
          BlocBuilder<SearchBloc, SearchState>(
            builder: (context, state) {
              final isLoading = state is SearchLoading;
              return Padding(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  controller: _controller,
                  onChanged: (query) {
                    context.read<SearchBloc>().add(SearchQueryChanged(query));
                  },
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
                ),
              );
            },
          ),
          Expanded(
            child: BlocBuilder<SearchBloc, SearchState>(
              builder: (context, state) {
                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'API Calls: ${state.apiCallCount}',
                        style:
                            const TextStyle(fontSize: 18, color: Colors.blue),
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

  Widget _buildContent(SearchState state) {
    return switch (state) {
      SearchInitial() => const Center(child: Text('Start typing to search...')),
      SearchLoading() => const Center(child: CircularProgressIndicator()),
      SearchSuccess(:final results) => ListView.builder(
          itemCount: results.length,
          itemBuilder: (context, index) {
            final result = results[index];
            return ListTile(
              leading: Text(result.icon, style: const TextStyle(fontSize: 24)),
              title: Text(result.title),
              subtitle: Text(result.subtitle),
            );
          },
        ),
      SearchError(:final message) => Center(child: Text('Error: $message')),
    };
  }
}