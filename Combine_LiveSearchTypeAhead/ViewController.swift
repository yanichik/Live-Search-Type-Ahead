//
//  ViewController.swift
//  Combine_LiveSearchTypeAhead
//
//  Created by Yan's Mac on 12/9/25.
//

import UIKit
import Combine

struct Movies: Codable {
    let allMovies: [Movie]
    
}

public struct Movie: Codable {
    let id: Int
    let title: String
    let year: Int
    let genre: [String]
}

final class ViewController: UIViewController {
    
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
    
    private var tableView = UITableView()
    
    /// Used to create a dynamic height for table view
    private var tableViewHeightConstraint: NSLayoutConstraint!
    
    private var subscriptions = Set<AnyCancellable>()
    private let searchBar = UISearchBar()
    private var liveResults = PassthroughSubject<[String], Never>()
    var latestResults = [String]()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        setupSearchBar()
        setupBindings()
        setupTableView()
    }
    
    private func setupSearchBar() {
        searchBar.delegate = self
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(searchBar)
        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            searchBar.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            searchBar.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            searchBar.heightAnchor.constraint(equalToConstant: 50)
        ])
        searchBar.placeholder = "Search for Movie"
        searchBar.searchBarStyle = .prominent
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.clipsToBounds = true
        view.addSubview(tableView)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 25),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 5),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -5),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        ])
        tableViewHeightConstraint = tableView.heightAnchor.constraint(equalToConstant: 50)
        tableViewHeightConstraint.isActive = true
    }
    
    private func setupBindings() {
        liveResults
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .sink(
                receiveCompletion: { print("Completed with: \($0)")},
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
    }
}

// MARK: - Table View Data Source
extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        latestResults.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = latestResults[indexPath.row]
        return cell
    }
}

// MARK: - Search Bar Delegate
extension ViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        let matchedMovies: [String] = findMovieMatches(searchText)
        liveResults
            .send(matchedMovies)
    }
}
    
// MARK: - Helper Methods
extension ViewController {
    private func findMovieMatches(_ searchText: String) -> [String] {
        let titles = allMovies.map(\.title)
        return titles.filter { $0.localizedCaseInsensitiveContains(searchText) }
    }
}

// MARK: - Table View Delegate
extension ViewController: UITableViewDelegate {
    
}
