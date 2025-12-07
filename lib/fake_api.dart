import 'dart:math';

class FakeSearchApi {
  static final _random = Random();

  static Future<List<SearchResult>> search(
    String query, {
    bool randomDelay = false,
  }) async {
    final delay = randomDelay
        ? Duration(milliseconds: 200 + _random.nextInt(800))
        : const Duration(milliseconds: 500);
    
    await Future.delayed(delay);

    if (query.isEmpty) return [];

    return List.generate(
      5,
      (i) => SearchResult(
        title: '$query result ${i + 1}',
        subtitle: 'Description for $query item ${i + 1}',
        icon: _getIconForIndex(i),
      ),
    );
  }

  static String _getIconForIndex(int index) {
    const icons = ['📱', '💻', '🎨', '🚀', '⭐'];
    return icons[index % icons.length];
  }
}

class SearchResult {
  final String title;
  final String subtitle;
  final String icon;

  SearchResult({
    required this.title,
    required this.subtitle,
    required this.icon,
  });
}