//
//  SessionFlowTests.swift
//  GreatTaskTests
//
//  Integration: the real auth, networking, data and cache objects wired together
//  exactly as `GreatTaskApp` wires them, with only the keychain and transport faked.
//

import Foundation
import SwiftData
import Testing
@testable import GreatTask

@MainActor
@Suite("Session flow")
struct SessionFlowTests {

    private struct SUT {
        let coordinator: AppCoordinator
        let auth: AuthServiceImpl
        let data: DataServiceImpl
        let tokens: InMemoryTokenStorage
        let credentials: InMemoryCredentialsStorage
        let network: StubbedNetwork
    }

    private static let baseURL = URL(string: "https://api.example.com/v1")!

    private func makeSUT(
        remembered: Credentials? = nil,
        stub: @escaping @Sendable (URLRequest) -> StubURLProtocol.Stub = { request in
            request.url?.lastPathComponent == "tokens"
                ? .ok(#"{"token":"session-token"}"#)
                : .ok(#"[{"name":"vilnius","distance":42}]"#)
        }
    ) throws -> SUT {
        let network = StubbedNetwork(handler: stub)
        let tokens = InMemoryTokenStorage()
        let credentials = InMemoryCredentialsStorage(credentials: remembered)

        let networkService = NetworkServiceImpl(
            baseURL: Self.baseURL,
            tokenStorage: tokens,
            session: network.session
        )
        let auth = AuthServiceImpl(
            networkService: networkService,
            tokenStorage: tokens,
            credentialsStorage: credentials
        )
        let container = try ModelContainer(
            for: CachedServer.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        let data = DataServiceImpl(
            networkService: networkService,
            cache: ServersCacheImpl(modelContainer: container)
        )

        return SUT(
            coordinator: AppCoordinator(authService: auth, dataService: data),
            auth: auth,
            data: data,
            tokens: tokens,
            credentials: credentials,
            network: network
        )
    }

    @Test("the token minted at sign in authenticates the servers request")
    func signInTokenReachesTheServersRequest() async throws {
        let sut = try makeSUT()

        _ = try await sut.auth.signIn(username: "user", password: "secret", rememberMe: true)
        let servers = try await sut.data.fetchServers()

        #expect(servers.map(\.name) == ["vilnius"])

        let serversRequest = try #require(
            sut.network.requests.first { $0.url?.lastPathComponent == "servers" }
        )
        #expect(serversRequest.value(forHTTPHeaderField: "Authorization") == "Bearer session-token")
    }

    @Test("relaunching with remembered credentials restores the session end to end")
    func restoresRememberedSession() async throws {
        let sut = try makeSUT(remembered: Credentials(username: "user", password: "secret"))

        await sut.coordinator.restoreSession()

        #expect(sut.coordinator.authState == .signedIn)
        #expect(sut.tokens.token == AuthToken(token: "session-token"))
        #expect(try await sut.data.fetchServers().map(\.name) == ["vilnius"])
    }

    @Test("signing out clears the token, the credentials and the cached servers")
    func signOutClearsSessionAndCache() async throws {
        let sut = try makeSUT()
        _ = try await sut.auth.signIn(username: "user", password: "secret", rememberMe: true)
        _ = try await sut.data.fetchServers()
        sut.coordinator.didSignIn()

        sut.coordinator.signOut()
        await sut.coordinator.signOutTask?.value

        #expect(sut.coordinator.authState == .signedOut)
        #expect(sut.tokens.token == nil)
        #expect(sut.credentials.credentials == nil)
        #expect(await sut.data.cachedServers().isEmpty)
        
        await #expect(throws: NetworkError.self) {
            try await sut.data.fetchServers()
        }
    }

    @Test("an expired remembered session drops the user on the sign-in screen with a reason")
    func expiredSessionFallsBackToSignIn() async throws {
        let sut = try makeSUT(remembered: Credentials(username: "user", password: "stale")) { _ in
            .status(401)
        }

        await sut.coordinator.restoreSession()

        #expect(sut.coordinator.authState == .signedOut)
        #expect(sut.credentials.credentials == nil)
        #expect(
            sut.coordinator.makeSignInViewModel().errorMessage
                == AuthError.invalidCredentials.localizedDescription
        )
    }
}
