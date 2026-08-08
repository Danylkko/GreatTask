//
//  Fakes.swift
//  GreatTaskTests
//

import Foundation
@testable import GreatTask

// MARK: - Networking
@MainActor
final class FakeNetworkService: NetworkServiceProtocol {

    private(set) var endpoints: [Endpoint] = []
    var responder: (Endpoint) throws -> Data = { _ in Data("{}".utf8) }

    var requestCount: Int { endpoints.count }

    func stub(json: String) {
        responder = { _ in Data(json.utf8) }
    }

    func stub(error: any Error) {
        responder = { _ in throw error }
    }

    func request<T: Decodable>(_ endpoint: Endpoint) async throws -> T {
        endpoints.append(endpoint)
        return try JSONDecoder().decode(T.self, from: try responder(endpoint))
    }

    func request(_ endpoint: Endpoint) async throws {
        endpoints.append(endpoint)
        _ = try responder(endpoint)
    }
}

// MARK: - Storage

@MainActor
final class InMemoryTokenStorage: TokenStorageProtocol {

    private(set) var token: AuthToken?
    private(set) var clearCount = 0

    init(token: AuthToken? = nil) {
        self.token = token
    }

    func save(_ token: AuthToken) { self.token = token }
    func loadToken() -> AuthToken? { token }
    func clear() {
        token = nil
        clearCount += 1
    }
}

@MainActor
final class InMemoryCredentialsStorage: CredentialsStorageProtocol {

    private(set) var credentials: Credentials?
    private(set) var saveCount = 0
    private(set) var clearCount = 0

    init(credentials: Credentials? = nil) {
        self.credentials = credentials
    }

    func save(_ credentials: Credentials) {
        self.credentials = credentials
        saveCount += 1
    }

    func loadCredentials() -> Credentials? { credentials }

    func clear() {
        credentials = nil
        clearCount += 1
    }
}

// MARK: - Services

@MainActor
final class FakeAuthService: AuthServiceProtocol {

    var remembered: Credentials?
    var signInResult: Result<AuthToken, any Error> = .success(AuthToken(token: "token"))
    var restoreResult: Result<AuthToken, any Error> = .success(AuthToken(token: "token"))

    private(set) var signInCount = 0
    private(set) var restoreCount = 0
    private(set) var signOutCount = 0
    private(set) var lastRememberMe: Bool?

    func signIn(username: String, password: String, rememberMe: Bool) async throws -> AuthToken {
        signInCount += 1
        lastRememberMe = rememberMe
        return try signInResult.get()
    }

    func rememberedCredentials() -> Credentials? { remembered }

    func restoreSession() async throws -> AuthToken {
        restoreCount += 1
        return try restoreResult.get()
    }

    func signOut() {
        signOutCount += 1
        remembered = nil
    }
}

@MainActor
final class FakeDataService: DataServiceProtocol {

    var cached: [ServerModel] = []
    var fetchResult: Result<[ServerModel], any Error> = .success([])
    var onFetch: (@MainActor () -> Void)?

    private(set) var fetchCount = 0
    private(set) var cachedReadCount = 0
    private(set) var clearCount = 0

    func cachedServers() async -> [ServerModel] {
        cachedReadCount += 1
        return cached
    }

    func fetchServers() async throws -> [ServerModel] {
        fetchCount += 1
        onFetch?()
        return try fetchResult.get()
    }

    func clearCachedServers() async {
        clearCount += 1
    }
}

@MainActor
final class FakeSignInCoordinator: SignInCoordinatorProtocol {
    private(set) var didSignInCount = 0
    func didSignIn() { didSignInCount += 1 }
}

// MARK: - Helpers

@MainActor
final class Probe {
    var isLoading: Bool?
    var isRefreshing: Bool?
    var names: [String] = []
}

enum TestError: Error {
    case boom
}
