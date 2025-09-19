//
//  WalmartAssessmentTests.swift
//  WalmartAssessmentTests
//
//  Created by Arpit Mallick on 9/19/25.
//

import XCTest
@testable import WalmartAssessment

extension CountriesViewModel {
    var countriesAreEmpty: Bool { allCountries.isEmpty && visibleCountries.isEmpty }
    func onDataChangeHandlersReset() {}
}

struct ImmediateDispatcher: Dispatching {
    func async(_ block: @escaping () -> Void) { block() }
}

final class CountriesIntegrationTests: XCTestCase {

    var viewModel: CountriesViewModel!

    override func setUp() {
        super.setUp()
        let network = MockNetworkManager(mode: .successFromBundle(resource: "MockCountries", ext: "json"))
        viewModel = CountriesViewModel(network: network, dispatcher: ImmediateDispatcher())
    }

    override func tearDown() {
        viewModel = nil
        super.tearDown()
    }

    func testFetchCountries_Success_fromMockJSON() {
        let loadedExp = expectation(description: "Fetch countries from mock API")

        var received: [Country] = []
        viewModel.onDataChangeHandlersReset()
        viewModel.onStateChange = { state in
            if case .loaded = state { loadedExp.fulfill() }
        }
        viewModel.onListChange = { list in received = list }

        viewModel.load()
        wait(for: [loadedExp], timeout: 2.0)

        XCTAssertFalse(received.isEmpty, "Expected countries from MockCountries.json")

        XCTAssertEqual(viewModel.visibleCountries.count, received.count)
        XCTAssertEqual(viewModel.allCountries.count, received.count)
    }

    func testFetchCountries_Error_invalidResponse() {
        let network = MockNetworkManager(mode: .invalidResponse)
        viewModel = CountriesViewModel(network: network, dispatcher: ImmediateDispatcher())

        let errorExp = expectation(description: "Handle invalid response error")
        viewModel.onStateChange = { state in if case .error = state { errorExp.fulfill() } }
        viewModel.onListChange = { _ in }

        viewModel.load()
        wait(for: [errorExp], timeout: 2.0)

        XCTAssertTrue(viewModel.countriesAreEmpty)
    }

    func testFetchCountries_Error_badURL() {
        let network = MockNetworkManager(mode: .badURL)
        viewModel = CountriesViewModel(network: network, dispatcher: ImmediateDispatcher())

        let errorExp = expectation(description: "Handle bad URL error")
        viewModel.onStateChange = { state in if case .error = state { errorExp.fulfill() } }
        viewModel.onListChange = { _ in }

        viewModel.load()
        wait(for: [errorExp], timeout: 2.0)

        XCTAssertTrue(viewModel.countriesAreEmpty)
    }

    func testFetchCountries_Error_emptyBody() {
        let network = MockNetworkManager(mode: .emptyBody)
        viewModel = CountriesViewModel(network: network, dispatcher: ImmediateDispatcher())

        let errorExp = expectation(description: "Handle empty body error")
        viewModel.onStateChange = { state in if case .error = state { errorExp.fulfill() } }
        viewModel.onListChange = { _ in }

        viewModel.load()
        wait(for: [errorExp], timeout: 2.0)

        XCTAssertTrue(viewModel.countriesAreEmpty)
    }
}

final class CountriesViewModelUnitTests: XCTestCase {

    func makeViewModelWithData(_ data: Data) -> CountriesViewModel {
        let network = MockNetworkManager(mode: .successData(data))
        return CountriesViewModel(network: network, dispatcher: ImmediateDispatcher())
    }

    func makeViewModelWithJSONArray(_ items: [[String: String]]) throws -> CountriesViewModel {
        let data = try JSONSerialization.data(withJSONObject: items, options: [])
        return makeViewModelWithData(data)
    }

    func testInitialState_isIdle_andListsEmpty() throws {
        let vm = makeViewModelWithData(Data())
        XCTAssertEqual(vm.visibleCountries.count, 0)
        XCTAssertEqual(vm.allCountries.count, 0)
    }

    func testLoad_success_populatesLists_andSetsLoaded() throws {
        // Arrange
        let items = [
            ["name": "Alpha", "code": "AA", "capital": "A City", "region": "A Region"],
            ["name": "Beta",  "code": "BB", "capital": "B City", "region": "B Region"]
        ]
        let vm = try makeViewModelWithJSONArray(items)

        let loadedExp = expectation(description: "state -> loaded")
        var callbackList: [Country] = []
        vm.onStateChange = { state in if case .loaded = state { loadedExp.fulfill() } }
        vm.onListChange = { list in callbackList = list }

        // Act
        vm.load()
        wait(for: [loadedExp], timeout: 1.0)

        // Assert
        XCTAssertEqual(vm.allCountries.count, 2)
        XCTAssertEqual(vm.visibleCountries.count, 2)
        XCTAssertEqual(callbackList.count, 2)
        XCTAssertEqual(vm.allCountries.first?.name, "Alpha")
        XCTAssertEqual(vm.visibleCountries.last?.name, "Beta")
    }

    func testLoad_failure_setsError_andEmptiesLists() throws {
        let network = MockNetworkManager(mode: .invalidResponse)
        let vm = CountriesViewModel(network: network, dispatcher: ImmediateDispatcher())

        let errorExp = expectation(description: "state -> error")
        var lastState: CountriesViewModel.State = .idle
        vm.onStateChange = { state in
            lastState = state
            if case .error = state { errorExp.fulfill() }
        }

        vm.load()
        wait(for: [errorExp], timeout: 1.0)

        if case .error(let message) = lastState {
            XCTAssertFalse(message.isEmpty)
        } else {
            XCTFail("Expected error state")
        }
        XCTAssertEqual(vm.allCountries.count, 0)
        XCTAssertEqual(vm.visibleCountries.count, 0)
    }

    func testUpdateSearch_filtersByNameOrCapital_caseInsensitive() throws {

        let items = [
            ["name": "Canada",    "code": "CA", "capital": "Ottawa",   "region": "Americas"],
            ["name": "Cameroon",  "code": "CM", "capital": "Yaounde",  "region": "Africa"],
            ["name": "Japan",     "code": "JP", "capital": "Tokyo",    "region": "Asia"]
        ]
        let vm = try makeViewModelWithJSONArray(items)

        let loadedExp = expectation(description: "loaded")
        vm.onStateChange = { state in if case .loaded = state { loadedExp.fulfill() } }
        vm.onListChange = { _ in }
        vm.load()
        wait(for: [loadedExp], timeout: 1.0)

        vm.updateSearch(query: "ca")
        XCTAssertEqual(vm.visibleCountries.map { $0.name }, ["Canada", "Cameroon"])

        vm.updateSearch(query: "yo")
        XCTAssertEqual(vm.visibleCountries.map { $0.name }, ["Japan"])

        vm.updateSearch(query: "   ")
        XCTAssertEqual(vm.visibleCountries.count, 3)
    }

    func testRetry_invokesLoadAgain() throws {
        // First attempt fails, second succeeds
        let failing = MockNetworkManager(mode: .invalidResponse)
        let vm = CountriesViewModel(network: failing, dispatcher: ImmediateDispatcher())

        let errorExp = expectation(description: "first -> error")
        vm.onStateChange = { state in if case .error = state { errorExp.fulfill() } }
        vm.load()
        wait(for: [errorExp], timeout: 1.0)

        let items = [["name": "X", "code": "XX", "capital": "XC", "region": "XR"]]
        let succeeding = try makeViewModelWithJSONArray(items)

        var sawLoading = false
        vm.onStateChange = { state in if case .loading = state { sawLoading = true } }
        vm.retry()
        XCTAssertTrue(sawLoading, "Retry should trigger loading state")
    }
}

