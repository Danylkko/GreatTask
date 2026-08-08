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
        let data = try await execute(endpoint)
        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw NetworkError.decoding(error)
        }
    }

    func request(_ endpoint: Endpoint) async throws {
        _ = try await execute(endpoint)
    }

    private func execute(_ endpoint: Endpoint) async throws -> Data {
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
                throw NetworkError.missingCredentials
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
        } catch let error as URLError {
            throw NetworkError.transport(error)
        } catch {
            throw NetworkError.unknown(error)
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }

        let body = data.isEmpty ? nil : data
        switch httpResponse.statusCode {
        case 200..<300:
            return data
        case 401:
            throw NetworkError.unauthorized(body: body)
        case 403:
            throw NetworkError.forbidden(body: body)
        case 404:
            throw NetworkError.notFound(body: body)
        case 400..<500:
            throw NetworkError.clientError(code: httpResponse.statusCode, body: body)
        case 500..<600:
            throw NetworkError.serverError(code: httpResponse.statusCode, body: body)
        default:
            throw NetworkError.unexpectedStatus(code: httpResponse.statusCode, body: body)
        }
    }
}
