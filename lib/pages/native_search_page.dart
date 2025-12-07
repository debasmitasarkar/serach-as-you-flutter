import 'package:flutter/material.dart';
import '../fake_api.dart';

class NaiveSearchPage extends StatefulWidget {
  const NaiveSearchPage({super.key});

  @override
  State<NaiveSearchPage> createState() => _NaiveSearchPageState();
}

class _NaiveSearchPageState extends State<NaiveSearchPage> {
  final _controller = TextEditingController();
  List<SearchResult> _results = [];
  bool _isLoading = false;
  int _apiCallCount = 0;

  void _onSearchChanged(String query) {
    if (query.isEmpty) {
      setState(() => _results = []);
      return;
    }
    _performSearch(query);
  }

  Future<void> _performSearch(String query) async {
    setState(() {
      _isLoading = true;
      _apiCallCount++;
    });

    final results = await FakeSearchApi.search(query, randomDelay: true);

    setState(() {
      _results = results;
      _isLoading = false;
    });
  }

  void _clearSearch() {
    _controller.clear();
    setState(() => _results = []);
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
        title: const Text('❌ Naive Approach'),
        backgroundColor: Colors.red.shade100,
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            color: Colors.red.shade50,
            child: const Text(
              '⚠️ Type quickly to see flickering!',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _controller,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Try typing "flutter" quickly...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _isLoading
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
                border: const OutlineInputBorder(),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'API Calls: $_apiCallCount',
              style: const TextStyle(fontSize: 18, color: Colors.red),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _results.isEmpty
                ? const Center(child: Text('Start typing to search...'))
                : ListView.builder(
                    itemCount: _results.length,
                    itemBuilder: (context, index) {
                      final result = _results[index];
                      return ListTile(
                        leading: Text(result.icon,
                            style: const TextStyle(fontSize: 24)),
                        title: Text(result.title),
                        subtitle: Text(result.subtitle),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}