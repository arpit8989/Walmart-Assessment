//
//  CountriesViewModel.swift
//  WalmartAssessment
//
//  Created by Arpit Mallick on 9/19/25.
//

import Foundation

protocol Dispatching {
    func async(_ work: @escaping () -> Void)
}

struct MainQueueDispatcher: Dispatching {
    func async(_ work: @escaping () -> Void) { DispatchQueue.main.async(execute: work) }
}

final class CountriesViewModel {

    enum State: Equatable {
        case idle, loading, loaded, error(String)
    }

    var onStateChange: ((State) -> Void)?
    var onListChange: (([Country]) -> Void)?

    private let network: Networking
    private let dispatcher: Dispatching
    private let url = URL(string:
      "https://gist.githubusercontent.com/peymano-wmt/32dcb892b06648910ddd40406e37fdab/raw/db25946fd77c5873b0303b858e861ce724e0dcd0/countries.json"
    )!

    private(set) var allCountries: [Country] = []
    private(set) var visibleCountries: [Country] = []
    private(set) var state: State = .idle { didSet { onStateChange?(state) } }

    init(network: Networking, dispatcher: Dispatching = MainQueueDispatcher()) {
        self.network = network
        self.dispatcher = dispatcher
    }

    func load() {
        state = .loading
        network.get(url) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .failure(let error):
                dispatcher.async {
                    self.allCountries = []
                    self.visibleCountries = []
                    self.state = .error(error.localizedDescription)
                    self.onListChange?(self.visibleCountries)
                }
            case .success(let data):
                do {
                    let items = try JSONDecoder().decode([Country].self, from: data)
                    dispatcher.async {
                        self.allCountries = items
                        self.visibleCountries = items
                        self.state = .loaded
                        self.onListChange?(items)
                    }
                } catch {
                    dispatcher.async {
                        self.state = .error(error.localizedDescription)
                        self.onListChange?([])
                    }
                }
            }
        }
    }

    func updateSearch(query: String?) {
        let term = (query ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        guard !term.isEmpty else {
            visibleCountries = allCountries
            onListChange?(visibleCountries)
            return
        }
        let q = term.lowercased()
        visibleCountries = allCountries.filter {
            $0.name.lowercased().contains(q) || $0.capital.lowercased().contains(q)
        }
        onListChange?(visibleCountries)
    }

    func retry() { load() }
}
