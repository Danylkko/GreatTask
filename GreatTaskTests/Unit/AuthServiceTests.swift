//
//  AuthServiceTests.swift
//  GreatTaskTests
//

import Foundation
import Testing
@testable import GreatTask

@MainActor
@Suite("AuthService")
struct AuthServiceTests {

    private struct SUT {
        let service: AuthServiceImpl
        let network: FakeNetworkService
        let tokens: InMemoryTokenStorage
        let credentials: InMemoryCredentialsStorage
    }

    private func makeSUT(remembered: Credentials? = nil) -> SUT {
        let network = FakeNetworkService()
        network.stub(json: #"{"token":"fresh-token"}"#)

        let tokens = InMemoryTokenStorage()
        let credentials = InMemoryCredentialsStorage(credentials: remembered)

        return SUT(
            service: AuthServiceImpl(
                networkService: network,
                tokenStorage: tokens,
                credentialsStorage: credentials
            ),
            network: network,
            tokens: tokens,
            credentials: credentials
        )
    }

    // MARK: - signIn

    @Test("empty credentials fail before any network call")
    func signInRejectsEmptyCredentials() async throws {
        let sut = makeSUT()

        await #expect(throws: AuthError.emptyCredentials) {
            try await sut.service.signIn(username: "", password: "secret", rememberMe: true)
        }
        await #expect(throws: AuthError.emptyCredentials) {
            try await sut.service.signIn(username: "user", password: "", rememberMe: true)
        }

        #expect(sut.network.requestCount == 0)
        #expect(sut.credentials.saveCount == 0)
    }

    @Test("successful sign in stores the token and honours rememberMe")
    func signInRemembersCredentials() async throws {
        let sut = makeSUT()

        let token = try await sut.service.signIn(username: "user", password: "secret", rememberMe: true)

        #expect(token == AuthToken(token: "fresh-token"))
        #expect(sut.tokens.token == AuthToken(token: "fresh-token"))
        #expect(sut.credentials.credentials == Credentials(username: "user", password: "secret"))
    }

    @Test("signing in without rememberMe clears any stored credentials")
    func signInWithoutRememberMeClearsCredentials() async throws {
        let sut = makeSUT(remembered: Credentials(username: "old", password: "old"))

        _ = try await sut.service.signIn(username: "user", password: "secret", rememberMe: false)

        #expect(sut.credentials.credentials == nil)
        #expect(sut.credentials.saveCount == 0)
    }

    @Test("401 is surfaced as invalidCredentials and leaves stored credentials alone")
    func signInMapsUnauthorized() async throws {
        let stored = Credentials(username: "old", password: "old")
        let sut = makeSUT(remembered: stored)
        sut.network.stub(error: NetworkError.unauthorized(body: nil))

        await #expect(throws: AuthError.invalidCredentials) {
            try await sut.service.signIn(username: "user", password: "wrong", rememberMe: true)
        }

        #expect(sut.credentials.credentials == stored)
        #expect(sut.tokens.token == nil)
    }

    // MARK: - restoreSession

    @Test("restoring without stored credentials fails before any network call")
    func restoreWithoutCredentials() async throws {
        let sut = makeSUT(remembered: nil)

        await #expect(throws: AuthError.noRememberedCredentials) {
            try await sut.service.restoreSession()
        }

        #expect(sut.network.requestCount == 0)
    }

    @Test("restoring with rejected credentials wipes them")
    func restoreDiscardsRejectedCredentials() async throws {
        let sut = makeSUT(remembered: Credentials(username: "user", password: "stale"))
        sut.network.stub(error: NetworkError.unauthorized(body: nil))

        await #expect(throws: AuthError.invalidCredentials) {
            try await sut.service.restoreSession()
        }

        #expect(sut.credentials.credentials == nil)
    }
    
    @Test("restoring while offline keeps the stored credentials")
    func restoreKeepsCredentialsOnTransportFailure() async throws {
        let stored = Credentials(username: "user", password: "secret")
        let sut = makeSUT(remembered: stored)
        sut.network.stub(error: NetworkError.transport(URLError(.notConnectedToInternet)))

        await #expect(throws: NetworkError.self) {
            try await sut.service.restoreSession()
        }

        #expect(sut.credentials.credentials == stored)
    }

    // MARK: - signOut

    @Test("signing out clears both the token and the credentials")
    func signOutClearsEverything() async throws {
        let sut = makeSUT(remembered: Credentials(username: "user", password: "secret"))
        _ = try await sut.service.signIn(username: "user", password: "secret", rememberMe: true)

        sut.service.signOut()

        #expect(sut.tokens.token == nil)
        #expect(sut.credentials.credentials == nil)
    }
}
