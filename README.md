# Search-as-You-Type Demo App

A Flutter demo showcasing **4 different approaches** to implementing search-as-you-type, plus a "bad" example showing what happens without debouncing.

## 🚀 Quick Start
```bash
git clone https://github.com/debasmitasarkar/flutter-search-demo.git
cd flutter-search-demo
flutter pub get
flutter run
```

---

## ❌ Naive Approach (Don't Do This!)

No debouncing — fires API call on every keystroke.

![Naive Demo](assets/naive.gif)

**Problems:**
- 7 API calls for typing "flutter"
- Race conditions — old results overwrite new ones
- UI flickers as results keep changing

---

## ⏱️ Timer Approach

Uses `dart:async` Timer for debouncing. Zero dependencies.

![Timer Demo](assets/timer.gif)
```dart
void _onSearchChanged(String query) {
  _debounceTimer?.cancel();
  _debounceTimer = Timer(const Duration(milliseconds: 400), () {
    _performSearch(query);
  });
}
```

**Best for:** Simple apps, prototypes

---

## 📡 RxDart Approach

Reactive streams with `debounceTime` + `switchMap` for auto-cancellation.

![RxDart Demo](assets/rxdart.gif)
```dart
_searchSubject.stream
    .debounceTime(const Duration(milliseconds: 400))
    .distinct()
    .switchMap((query) => _search(query))
    .shareReplay(maxSize: 1);
```

**Best for:** Reactive apps, complex data flows

---

## 📦 BLoC Approach

Event transformers handle debouncing and cancellation. Highly testable.

![BLoC Demo](assets/bloc.gif)
```dart
on<SearchQueryChanged>(
  _onQueryChanged,
  transformer: (events, mapper) => events
      .debounce(const Duration(milliseconds: 400))
      .switchMap(mapper),
);
```

**Best for:** Production apps, large teams

---

## 🪄 Riverpod Approach

Provider chain with auto-dispose and caching.

![Riverpod Demo](assets/riverpod.gif)
```dart
final debouncedQueryProvider = StreamProvider.autoDispose<String>((ref) {
  // debounced query logic
});

final searchResultsProvider = FutureProvider.autoDispose<List<SearchResult>>((ref) async {
  final query = await ref.watch(debouncedQueryProvider.future);
  return FakeSearchApi.search(query);
});
```

**Best for:** Apps already using Riverpod

---

## 🎯 Comparison

| Approach | API Calls | Auto-Cancel | Dependencies |
|----------|:---------:|:-----------:|:------------:|
| ❌ Naive | 7+ | ❌ | 0 |
| ⏱️ Timer | 1 | ❌ | 0 |
| 📡 RxDart | 1 | ✅ | 1 |
| 📦 BLoC | 1 | ✅ | 2 |
| 🪄 Riverpod | 1 | ❌ | 1 |

---

## 📦 Dependencies
```yaml
rxdart: ^0.28.0
flutter_bloc: ^8.1.6
stream_transform: ^2.1.0
flutter_riverpod: ^2.5.1
```

---

## 📝 Related Article

[Implementing Search-as-You-Type in Flutter](https://medium.com/@debasmitasarkar/search-as-you-type-flutter) — Full breakdown with pros/cons and when to use each approach.

---

## 📄 License

MIT