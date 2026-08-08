//
//  NetworkServiceTests.swift
//  GreatTaskTests
//

import Foundation
import Testing
@testable import GreatTask

@MainActor
@Suite("NetworkService")
struct NetworkServiceTests {

    private struct Payload: Decodable, Equatable {
        let name: String
    }
    
    private struct SUT {
        let service: NetworkServiceImpl
        let network: StubbedNetwork

        var requests: [URLRequest] { network.requests }
    }

    private static let baseURL = URL(string: "https://api.example.com/v1")!

    private func makeSUT(
        token: AuthToken? = AuthToken(token: "abc123"),
        stub: @escaping @Sendable (URLRequest) -> StubURLProtocol.Stub
    ) -> SUT {
        let network = StubbedNetwork(handler: stub)
        return SUT(
            service: NetworkServiceImpl(
                baseURL: Self.baseURL,
                tokenStorage: InMemoryTokenStorage(token: token),
                session: network.session
            ),
            network: network
        )
    }

    @Test("a 2xx response is decoded and carries the bearer token")
    func decodesSuccessAndSendsAuthorization() async throws {
        let sut = makeSUT { _ in .ok(#"{"name":"vilnius"}"#) }

        let payload: Payload = try await sut.service.request(
            Endpoint(path: "servers", queryItems: [URLQueryItem(name: "page", value: "2")])
        )

        #expect(payload == Payload(name: "vilnius"))

        let request = try #require(sut.requests.first)
        #expect(request.url?.absoluteString == "https://api.example.com/v1/servers?page=2")
        #expect(request.httpMethod == "GET")
        #expect(request.value(forHTTPHeaderField: "Authorization") == "Bearer abc123")
    }

    @Test("an unauthenticated endpoint omits the Authorization header")
    func skipsAuthorizationWhenNotRequired() async throws {
        let sut = makeSUT(token: nil) { _ in .ok() }

        try await sut.service.request(Endpoint(path: "tokens", method: .post, requiresAuth: false))

        let request = try #require(sut.requests.first)
        #expect(request.httpMethod == "POST")
        #expect(request.value(forHTTPHeaderField: "Authorization") == nil)
    }

    @Test("an authenticated endpoint without a token fails before reaching the network")
    func failsFastWithoutToken() async throws {
        let sut = makeSUT(token: nil) { _ in .ok() }

        await #expect(throws: NetworkError.self) {
            try await sut.service.request(Endpoint(path: "servers")) as Payload
        }
        #expect(sut.requests.isEmpty)
    }

    @Test("status codes map onto their error cases", arguments: [401, 403, 404, 422, 500, 302])
    func mapsStatusCodes(status: Int) async throws {
        let sut = makeSUT { _ in .status(status) }

        let error = await capture {
            _ = try await sut.service.request(Endpoint(path: "servers")) as Payload
        }

        switch (status, error as? NetworkError) {
        case (401, .unauthorized), (403, .forbidden), (404, .notFound):
            break
        case (422, .clientError(let code, _)), (500, .serverError(let code, _)), (302, .unexpectedStatus(let code, _)):
            #expect(code == status)
        default:
            Issue.record("\(status) mapped to unexpected error: \(String(describing: error))")
        }
    }

    @Test("a malformed body becomes a decoding error")
    func mapsDecodingFailure() async throws {
        let sut = makeSUT { _ in .ok(#"{"unexpected":true}"#) }

        let error = await capture {
            _ = try await sut.service.request(Endpoint(path: "servers")) as Payload
        }

        guard case .decoding = try #require(error as? NetworkError) else {
            Issue.record("expected a decoding error, got \(String(describing: error))")
            return
        }
    }

    @Test("a dropped connection becomes a transport error")
    func mapsTransportFailure() async throws {
        let sut = makeSUT { _ in .failure(.notConnectedToInternet) }

        let error = await capture {
            _ = try await sut.service.request(Endpoint(path: "servers")) as Payload
        }

        guard case .transport = try #require(error as? NetworkError) else {
            Issue.record("expected a transport error, got \(String(describing: error))")
            return
        }
    }

    private func capture(_ operation: () async throws -> Void) async -> (any Error)? {
        do {
            try await operation()
            return nil
        } catch {
            return error
        }
    }
}
