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

![1](https://github.com/user-attachments/assets/703d815d-b22a-4185-b9f3-1bea6ec17774)

**Problems:**
- 7 API calls for typing "flutter"
- Race conditions — old results overwrite new ones
- UI flickers as results keep changing

---

## ⏱️ Timer Approach

Uses `dart:async` Timer for debouncing. Zero dependencies.

![Simulator Screen Recording - iPhone 17 Pro Max - 2025-12-07 at 21 43 54](https://github.com/user-attachments/assets/3cc93052-383d-4b3b-b91a-4128c3b65bb4)


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

![Simulator Screen Recording - iPhone 17 Pro Max - 2025-12-07 at 21 54 29](https://github.com/user-attachments/assets/7a4df0c1-a481-4685-809f-9dd3c9efae05)

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

![Simulator Screen Recording - iPhone 17 Pro Max - 2025-12-07 at 22 03 23](https://github.com/user-attachments/assets/f1cc5442-215f-46b1-8230-7e4b7392ffb6)

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

![Simulator Screen Recording - iPhone 17 Pro Max - 2025-12-07 at 22 14 44](https://github.com/user-attachments/assets/715c0995-3a19-4ac6-8db4-108b22ab499e)

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
