import 'package:flutter/material.dart';
import 'native_search_page.dart';
import 'timer_search_page.dart';
import 'rxdart_search_page.dart';
import 'bloc_search_page.dart';
import 'riverpod_search_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search-as-You-Type Demo'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Choose an approach:',
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 16),
          
          _DemoCard(
            title: '❌ Naive (Bad)',
            subtitle: 'No debouncing - flickering & race conditions',
            color: Colors.red.shade50,
            borderColor: Colors.red,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const NaiveSearchPage()),
            ),
          ),
          
          const SizedBox(height: 12),
          const Divider(),
          const SizedBox(height: 12),
          
          _DemoCard(
            title: '⏱️ Timer',
            subtitle: 'Zero dependencies',
            color: Colors.green.shade50,
            borderColor: Colors.green,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const TimerSearchPage()),
            ),
          ),
          
          const SizedBox(height: 12),
          
          _DemoCard(
            title: '📡 RxDart',
            subtitle: 'Auto-cancellation with switchMap',
            color: Colors.pink.shade50,
            borderColor: Colors.pink,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const RxDartSearchPage()),
            ),
          ),
          
          const SizedBox(height: 12),
          
          _DemoCard(
            title: '📦 BLoC',
            subtitle: 'Event transformers',
            color: Colors.blue.shade50,
            borderColor: Colors.blue,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const BlocSearchPage()),
            ),
          ),
          
          const SizedBox(height: 12),
          
          _DemoCard(
            title: '🪄 Riverpod',
            subtitle: 'Provider-based',
            color: Colors.purple.shade50,
            borderColor: Colors.purple,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const RiverpodSearchPage()),
            ),
          ),
        ],
      ),
    );
  }
}

class _DemoCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Color color;
  final Color borderColor;
  final VoidCallback onTap;

  const _DemoCard({
    required this.title,
    required this.subtitle,
    required this.color,
    required this.borderColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: color,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: borderColor, width: 2),
      ),
      child: ListTile(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: Icon(Icons.arrow_forward_ios, color: borderColor),
        onTap: onTap,
      ),
    );
  }
}