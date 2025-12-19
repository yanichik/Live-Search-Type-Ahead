# 🎬 Combine Live Search Type-Ahead (UIKit + Combine)

![Swift](https://img.shields.io/badge/Swift-5.9-orange)
![Platform](https://img.shields.io/badge/Platform-iOS-blue)
![UI](https://img.shields.io/badge/UI-UIKit-lightgrey)
![Reactive](https://img.shields.io/badge/Reactive-Combine-purple)
![License](https://img.shields.io/badge/License-MIT-green)

A UIKit mini-project demonstrating **Combine-based debounced live search**, dynamic UI updates, and Auto Layout–driven animations.

This project shows how to connect a `UISearchBar` to a Combine pipeline that filters a dataset in real time and displays results in a dynamically resizing `UITableView`.

---

## 🎥 Demo

![Demo](demo.gif)

---

## 🚀 What This Project Demonstrates

### ✅ Combine fundamentals
- `PassthroughSubject`
- `debounce(for:scheduler:)`
- `sink(receiveValue:)`
- `AnyCancellable` lifecycle management

### ✅ UIKit integration
- `UISearchBarDelegate`
- `UITableViewDataSource` / `UITableViewDelegate`
- Constraint-based layout
- Animated Auto Layout updates

### ✅ Real-world UI behavior
- Type-ahead search
- Debounced user input
- Dynamic table view height based on content
- Smooth height animations

---

## 🧠 How It Works

### 1️⃣ User Input → Combine

Each keystroke in the search bar triggers:

```swift
func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
    let matchedMovies: [String] = findMovieMatches(searchText)
    liveResults.send(matchedMovies)
}
```

- The search bar delegate emits filtered results
- Results are sent through a `PassthroughSubject<[String], Never>`

---

### 2️⃣ Debounced Combine Pipeline

The Combine pipeline is set up once during view initialization:

```swift
liveResults
    .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
    .sink(
        receiveCompletion: { print("Completed with: \($0)") },
        receiveValue: { [weak self] results in
            guard let self else { return }
            self.latestResults = results
            self.tableView.reloadData()
            self.tableViewHeightConstraint.constant = self.tableView.contentSize.height
            UIView.animate(withDuration: 0.25) {
                self.view.layoutIfNeeded()
            }
        }
    )
    .store(in: &subscriptions)
```

This pipeline:
- Waits 300ms after the last keystroke
- Delivers results on the main run loop
- Updates the table view data source
- Adjusts the table view’s height constraint
- Animates the constraint-driven layout change

---

### 3️⃣ Dynamic Table View Height

The table view does **not** scroll full-screen by default.
Instead, its height is dynamically updated to match its content:

```swift
tableViewHeightConstraint = tableView.heightAnchor.constraint(equalToConstant: 50)
tableViewHeightConstraint.isActive = true
```

Each time new results arrive:

```swift
self.tableViewHeightConstraint.constant = self.tableView.contentSize.height
```

This allows the table to behave like a **search suggestion dropdown**, expanding and collapsing as results change.

---

### 4️⃣ Constraint-Driven Animation

The layout update is animated using the standard UIKit pattern:

```swift
UIView.animate(withDuration: 0.25) {
    self.view.layoutIfNeeded()
}
```

This forces Auto Layout to recompute frames inside the animation block, producing a smooth resize effect.

---

## 📦 Data Source

Movies are loaded from a bundled JSON file using `Codable`:

```swift
private lazy var allMovies: [Movie] = {
    guard let moviesURL = Bundle.main.url(forResource: "movies", withExtension: "json") else { return [] }
    do {
        let data = try Data(contentsOf: moviesURL)
        let movies = try JSONDecoder().decode(Movies.self, from: data)
        return movies.allMovies
    } catch {
        print("Failed to load movies from path: \(moviesURL.absoluteString)")
        return []
    }
}()
```

Search filtering is performed using a simple, case-insensitive match:

```swift
let titles = allMovies.map(\.title)
return titles.filter { $0.localizedCaseInsensitiveContains(searchText) }
```

---

## 🧩 Architecture Overview

```
UISearchBar
   ↓
PassthroughSubject<[String]>
   ↓ debounce(300ms)
Combine Sink
   ↓
UITableView reload + height constraint update
   ↓
Animated Auto Layout pass
```

---

## 📂 Project Structure

```
Combine_LiveSearchTypeAhead/
│
├── movies.json           // Local movie dataset
├── ViewController.swift  // All UI + Combine logic
└── AppDelegate.swift
```

---

## 🧪 Why This Is a Good Combine Demo

- Demonstrates **reactive thinking**: input streams → transformation → UI output
- Uses **back-pressure control** (`debounce`) to protect performance
- Shows **correct threading** for UI updates (`RunLoop.main`)
- Applies **Auto Layout animations** driven by constraint updates
- Clean separation of:
  - input events
  - reactive pipeline
  - UI state
- Memory-safe Combine usage with `[weak self]`

This mirrors real-world patterns used in search, autocomplete, and suggestions UIs.

---

## ▶️ Running the Project

1. Clone the repository
2. Open in Xcode
3. Run on an iOS simulator
4. Type in the search bar
5. Observe debounced filtering and animated result expansion

---
