//
//  StubURLProtocol.swift
//  GreatTaskTests
//

import Foundation

final class StubURLProtocol: URLProtocol {

    struct Stub {
        var status: Int = 200
        var data: Data = Data()
        var error: URLError?

        static func ok(_ json: String = "{}") -> Stub {
            Stub(status: 200, data: Data(json.utf8))
        }

        static func status(_ code: Int, _ json: String = "{}") -> Stub {
            Stub(status: code, data: Data(json.utf8))
        }

        static func failure(_ code: URLError.Code) -> Stub {
            Stub(error: URLError(code))
        }
    }

    static let sessionKeyHeader = "X-Stub-Session"

    private static let lock = NSLock()
    nonisolated(unsafe) private static var handlers: [String: @Sendable (URLRequest) -> Stub] = [:]
    nonisolated(unsafe) private static var recorded: [String: [URLRequest]] = [:]

    static func register(_ key: String, handler: @escaping @Sendable (URLRequest) -> Stub) {
        lock.withLock {
            handlers[key] = handler
            recorded[key] = []
        }
    }

    static func unregister(_ key: String) {
        lock.withLock {
            handlers[key] = nil
            recorded[key] = nil
        }
    }

    static func requests(for key: String) -> [URLRequest] {
        lock.withLock { recorded[key] ?? [] }
    }

    private static func key(for request: URLRequest) -> String? {
        request.value(forHTTPHeaderField: sessionKeyHeader)
    }

    /// Claims every request tagged with a session key, even one whose handler is gone,
    /// so that a released `StubbedNetwork` fails the test instead of hitting the real network.
    override class func canInit(with request: URLRequest) -> Bool {
        key(for: request) != nil
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }

    override func startLoading() {
        guard let key = Self.key(for: request),
              let handler = Self.lock.withLock({ Self.handlers[key] }) else {
            client?.urlProtocol(self, didFailWithError: URLError(.unsupportedURL))
            return
        }

        Self.lock.withLock { Self.recorded[key, default: []].append(request) }

        let stub = handler(request)

        if let error = stub.error {
            client?.urlProtocol(self, didFailWithError: error)
            return
        }

        let response = HTTPURLResponse(
            url: request.url!,
            statusCode: stub.status,
            httpVersion: "HTTP/1.1",
            headerFields: nil
        )!

        client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        client?.urlProtocol(self, didLoad: stub.data)
        client?.urlProtocolDidFinishLoading(self)
    }

    override func stopLoading() {}
}

/// Owns a `URLSession` wired to `StubURLProtocol` plus the stub registration for it.
final class StubbedNetwork {

    let session: URLSession
    private let key = UUID().uuidString

    init(handler: @escaping @Sendable (URLRequest) -> StubURLProtocol.Stub) {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [StubURLProtocol.self]
        configuration.httpAdditionalHeaders = [StubURLProtocol.sessionKeyHeader: key]

        session = URLSession(configuration: configuration)
        StubURLProtocol.register(key, handler: handler)
    }

    var requests: [URLRequest] { StubURLProtocol.requests(for: key) }

    deinit { StubURLProtocol.unregister(key) }
}
