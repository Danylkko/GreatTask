//
//  NetworkServiceImpl.swift
//  GreatTask
//
//  Created by Danylo Litvinchuk on 06.08.2026.
//

import Foundation

final class NetworkServiceImpl: NetworkServiceProtocol {

    private let baseURL: URL
    private let tokenStorage: TokenStorageProtocol
    private let session: URLSession
    private let decoder: JSONDecoder

    init(
        baseURL: URL,
        tokenStorage: TokenStorageProtocol,
        session: URLSession = .shared,
        decoder: JSONDecoder = JSONDecoder()
    ) {
        self.baseURL = baseURL
        self.tokenStorage = tokenStorage
        self.session = session
        self.decoder = decoder
    }

    func request<T: Decodable>(_ endpoint: Endpoint) async throws -> T {
        let (data, _) = try await execute(endpoint)
        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw NetworkError.decoding(error)
        }
    }

    func request(_ endpoint: Endpoint) async throws {
        _ = try await execute(endpoint)
    }

    private func execute(_ endpoint: Endpoint) async throws -> (Data, HTTPURLResponse) {
        guard var components = URLComponents(
            url: baseURL.appendingPathComponent(endpoint.path),
            resolvingAgainstBaseURL: false
        ) else {
            throw NetworkError.invalidURL
        }
        components.queryItems = endpoint.queryItems.isEmpty ? nil : endpoint.queryItems

        guard let url = components.url else {
            throw NetworkError.invalidURL
        }

        var headers = endpoint.headers
        if endpoint.requiresAuth {
            guard let token = tokenStorage.loadToken() else {
                throw NetworkError.unauthorized
            }
            headers["Authorization"] = "Bearer \(token.token)"
        }

        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue
        request.httpBody = endpoint.body
        headers.forEach { request.setValue($1, forHTTPHeaderField: $0) }

        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await session.data(for: request)
        } catch {
            throw NetworkError.transport(error)
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        guard (200..<300).contains(httpResponse.statusCode) else {
            throw NetworkError.httpStatus(httpResponse.statusCode)
        }

        return (data, httpResponse)
    }
}
