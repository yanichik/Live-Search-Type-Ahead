# Live Search Type-Ahead (UIKit + Combine)

This project demonstrates an **Apple-style, UIKit-based live search (type-ahead) component**
implemented with **Combine**.

---

## Overview

The screen consists of:

- `UISearchBar` for user input
- `UITableView` for displaying filtered results
- A debounced Combine pipeline to avoid excessive filtering while typing

The goal is to demonstrate Combine in a small, production-quality UIKit application

---

## Architecture Choices

### UIKit + Combine?
- Combine integrates naturally with UIKit event streams

---

## Key Best Practices Applied

### 1. `final` View Controller
```swift
final class ViewController: UIViewController { }
```

**Why**
- UIKit view controllers are not designed for subclassing
- Enables compiler devirtualization
- Prevents accidental inheritance

---

### 2. Strict Access Control

```swift
private let tableView = UITableView()
private let searchBar = UISearchBar()
private var subscriptions = Set<AnyCancellable>()
```

**Why**
- Reduces surface area
- Improves maintainability
- Matches Apple sample code style

---

### 4. Combine Pipeline (Debounced Search)

```swift
liveResults
    .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
    .sink { [weak self] results in
        self?.latestResults = results
        self?.tableView.reloadData()
    }
    .store(in: &subscriptions)
```

**Why**
- Prevents excessive UI updates
- Keeps UI work on the main thread
- Uses weak capture to avoid retain cycles

---

### 5. Auto Layout: No Over-Constraining

**Correct approach**
- Pin table view to top and bottom
- Let it scroll naturally

```swift
tableView.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 25)
tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
```

**Avoid**
- Combining fixed height + bottom constraint
- Manually syncing height to `contentSize` unless building a custom dropdown

---

### 6. Separation of Responsibilities

```swift
override func viewDidLoad() {
    super.viewDidLoad()
    setupSearchBar()
    setupTableView()
    setupBindings()
}
```

**Why**
- Clear lifecycle flow
- Easier debugging
- Matches Apple documentation patterns

---

## Filtering Logic

```swift
private func findMovieMatches(_ searchText: String) -> [String] {
    let titles = allMovies.map(\.title)
    guard !searchText.isEmpty else { return titles }
    return titles.filter {
        $0.localizedCaseInsensitiveContains(searchText)
    }
}
```

**Notes**
- `map(\.title)` is key-path based and fully type-checked
- `localizedCaseInsensitiveContains` respects user locale

---

## What This Example Intentionally Avoids

- MVVM for a trivial screen
- `CurrentValueSubject` where state storage is unnecessary
- Dynamic table height animation (unless explicitly required)
- Premature abstraction

---

## When to Extend This

You could reasonably add:
- Async network-backed search
- Diffable data source
- Result highlighting
- UIKit ↔ SwiftUI bridging

But this baseline is intentionally simple and correct.

---

## Takeaway

This project reflects how Apple engineers typically write UIKit:

> **Simple, explicit, predictable, and boring — in a good way.**

