//
//  MockNetworkManager.swift
//  WalmartAssessmentTests
//
//  Created by Arpit Mallick on 9/19/25.
//

import Foundation

@testable import WalmartAssessment

enum MockNetworkError: Error, LocalizedError {
    case badURL
    case invalidResponse
    case emptyBody
    case other(String)

    var errorDescription: String? {
        switch self {
        case .badURL: return "Bad URL"
        case .invalidResponse: return "Invalid HTTP response"
        case .emptyBody: return "Empty response body"
        case .other(let msg): return msg
        }
    }
}

final class MockNetworkManager: Networking {

    enum Mode {
        case successFromBundle(resource: String = "MockCountries", ext: String = "json", bundle: Bundle = .main)
        case successData(Data)
        case badURL
        case invalidResponse
        case emptyBody
        case failure(Error)
    }

    var mode: Mode

    init(mode: Mode = .successFromBundle()) {
        self.mode = mode
    }

    func get(_ url: URL, completion: @escaping (Result<Data, Error>) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async { [mode] in
            switch mode {
            case .successFromBundle(let resource, let ext, let bundle):
                let testBundle = Bundle(for: MockNetworkManager.self)
                let targetBundle = testBundle.url(forResource: resource, withExtension: ext) != nil ? testBundle : bundle
                guard let url = targetBundle.url(forResource: resource, withExtension: ext) else {
                    return completion(.failure(MockNetworkError.badURL))
                }
                do {
                    let data = try Data(contentsOf: url)
                    completion(.success(data))
                } catch {
                    completion(.failure(MockNetworkError.other(error.localizedDescription)))
                }

            case .successData(let data):
                completion(.success(data))

            case .badURL:
                completion(.failure(MockNetworkError.badURL))

            case .invalidResponse:
                completion(.failure(MockNetworkError.invalidResponse))

            case .emptyBody:
                completion(.failure(MockNetworkError.emptyBody))

            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
