//
//  AuthServiceImpl.swift
//  GreatTask
//
//  Created by Danylo Litvinchuk on 06.08.2026.
//

import Foundation

final class AuthServiceImpl: AuthServiceProtocol {

    private let networkService: NetworkServiceProtocol
    private let tokenStorage: TokenStorageProtocol
    private let credentialsStorage: CredentialsStorageProtocol

    init(
        networkService: NetworkServiceProtocol,
        tokenStorage: TokenStorageProtocol,
        credentialsStorage: CredentialsStorageProtocol
    ) {
        self.networkService = networkService
        self.tokenStorage = tokenStorage
        self.credentialsStorage = credentialsStorage
    }

    func signIn(
        username: String,
        password: String,
        rememberMe: Bool
    ) async throws -> AuthToken {
        guard !username.isEmpty, !password.isEmpty else {
            throw AuthError.emptyCredentials
        }

        let credentials = Credentials(username: username, password: password)
        let token = try await requestToken(for: credentials)

        if rememberMe {
            credentialsStorage.save(credentials)
        } else {
            credentialsStorage.clear()
        }

        return token
    }

    func rememberedCredentials() -> Credentials? {
        credentialsStorage.loadCredentials()
    }

    func restoreSession() async throws -> AuthToken {
        guard let credentials = credentialsStorage.loadCredentials() else {
            throw AuthError.noRememberedCredentials
        }

        do {
            return try await requestToken(for: credentials)
        } catch AuthError.invalidCredentials {
            credentialsStorage.clear()
            throw AuthError.invalidCredentials
        }
    }

    func signOut() {
        tokenStorage.clear()
        credentialsStorage.clear()
    }

    private func requestToken(for credentials: Credentials) async throws -> AuthToken {
        let body = try JSONEncoder().encode(
            LoginRequest(username: credentials.username, password: credentials.password)
        )
        let endpoint = Endpoint(
            path: "tokens",
            method: .post,
            headers: ["Content-Type": "application/json"],
            body: body,
            requiresAuth: false
        )

        let response: LoginResponse
        do {
            response = try await networkService.request(endpoint)
        } catch NetworkError.unauthorized {
            throw AuthError.invalidCredentials
        }

        let token = AuthToken(token: response.token)
        tokenStorage.save(token)
        return token
    }
}

private struct LoginRequest: Encodable {
    let username: String
    let password: String
}

private struct LoginResponse: Decodable {
    let token: String
}
