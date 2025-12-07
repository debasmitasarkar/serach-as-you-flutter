import 'dart:async';
import 'package:flutter/material.dart';
import '../fake_api.dart';

class TimerSearchPage extends StatefulWidget {
  const TimerSearchPage({super.key});

  @override
  State<TimerSearchPage> createState() => _TimerSearchPageState();
}

class _TimerSearchPageState extends State<TimerSearchPage> {
  final _controller = TextEditingController();
  Timer? _debounceTimer;

  List<SearchResult> _results = [];
  bool _isLoading = false;
  int _apiCallCount = 0;

  void _onSearchChanged(String query) {
    _debounceTimer?.cancel();

    if (query.isEmpty) {
      setState(() => _results = []);
      return;
    }

    _debounceTimer = Timer(const Duration(milliseconds: 400), () {
      _performSearch(query);
    });
  }

  Future<void> _performSearch(String query) async {
    setState(() {
      _isLoading = true;
      _apiCallCount++;
    });

    final results = await FakeSearchApi.search(query);

    setState(() {
      _results = results;
      _isLoading = false;
    });
  }

  void _clearSearch() {
    _debounceTimer?.cancel();
    _controller.clear();
    setState(() => _results = []);
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('⏱️ Timer Approach'),
        backgroundColor: Colors.green.shade100,
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            color: Colors.green.shade50,
            child: const Text(
              '✅ Debounced - waits 400ms after typing stops',
              style: TextStyle(color: Colors.green),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _controller,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Search...',
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
              style: const TextStyle(fontSize: 18, color: Colors.green),
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