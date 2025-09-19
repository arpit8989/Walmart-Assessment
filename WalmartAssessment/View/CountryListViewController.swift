//
//  CountryListViewController.swift
//  WalmartAssessment
//
//  Created by Arpit Mallick on 9/19/25.
//

import UIKit

final class CountryListViewController: UIViewController {
    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    private let searchController = UISearchController(searchResultsController: nil)
    private let errorView = ErrorView()

    private let viewModel: CountriesViewModel

    private var items: [Country] = []

    init(viewModel: CountriesViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        configureTable()
        configureSearch()
        configureErrorView()
        bindViewModel()
        viewModel.load()
    }

    private func configureTable() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(CountryCell.self, forCellReuseIdentifier: CountryCell.reuseID)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 68
        tableView.dataSource = self
        tableView.delegate = self

        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func configureSearch() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search by name or capital"
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }

    private func configureErrorView() {
        errorView.translatesAutoresizingMaskIntoConstraints = false
        errorView.isHidden = true
        errorView.retryButton.addTarget(self, action: #selector(didTapRetry), for: .touchUpInside)
        view.addSubview(errorView)
        NSLayoutConstraint.activate([
            errorView.topAnchor.constraint(equalTo: view.topAnchor),
            errorView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            errorView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            errorView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func bindViewModel() {
        viewModel.onStateChange = { [weak self] state in
            guard let self = self else { return }
            switch state {
            case .idle:
                self.navigationItem.rightBarButtonItem = nil
                self.errorView.isHidden = true
            case .loading:
                self.errorView.isHidden = true
                self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: self.spinner())
            case .loaded:
                self.navigationItem.rightBarButtonItem = nil
                self.errorView.isHidden = true
            case .error(let msg):
                self.navigationItem.rightBarButtonItem = nil
                self.errorView.messageLabel.text = msg
                self.errorView.isHidden = false
                self.tableView.isHidden = true
            }
        }

        viewModel.onListChange = { [weak self] list in
            guard let self = self else { return }
            self.items = list
            self.tableView.isHidden = false
            self.tableView.reloadData()
        }
    }

    @objc private func didTapRetry() { viewModel.retry() }

    private func spinner() -> UIActivityIndicatorView {
        let s = UIActivityIndicatorView(style: .medium); s.startAnimating(); return s
    }
}

extension CountryListViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CountryCell.reuseID, for: indexPath) as! CountryCell
        cell.bind(items[indexPath.row])
        return cell
    }
}

extension CountryListViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        viewModel.updateSearch(query: searchController.searchBar.text)
    }
}
