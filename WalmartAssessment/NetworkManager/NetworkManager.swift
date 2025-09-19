//
//  NetworkManager.swift
//  WalmartAssessment
//
//  Created by Arpit Mallick on 9/19/25.
//

import Foundation

protocol Networking {
    func get(_ url: URL, completion: @escaping (Result<Data, Error>) -> Void)
}

final class NetworkManager: Networking {
    private let session: URLSession

    init(session: URLSession = .shared) { self.session = session }

    func get(_ url: URL, completion: @escaping (Result<Data, Error>) -> Void) {
        session.dataTask(with: url) { data, response, error in
            if let error = error { return completion(.failure(error)) }
            guard let http = response as? HTTPURLResponse else {
                return completion(.failure(NSError(domain: "Network", code: -1,
                    userInfo: [NSLocalizedDescriptionKey: "No HTTP response"])))
            }
            guard (200..<300).contains(http.statusCode) else {
                return completion(.failure(NSError(domain: "Network", code: http.statusCode,
                    userInfo: [NSLocalizedDescriptionKey: "HTTP \(http.statusCode)"])))
            }
            guard let data = data, !data.isEmpty else {
                return completion(.failure(NSError(domain: "Network", code: -2,
                    userInfo: [NSLocalizedDescriptionKey: "Empty response body"])))
            }
            completion(.success(data))
        }.resume()
    }
}
