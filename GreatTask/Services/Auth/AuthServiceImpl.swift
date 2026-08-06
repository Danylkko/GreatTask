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

    init(
        networkService: NetworkServiceProtocol,
        tokenStorage: TokenStorageProtocol
    ) {
        self.networkService = networkService
        self.tokenStorage = tokenStorage
    }

    func signIn(
        username: String,
        password: String
    ) async throws -> AuthToken {
        guard !username.isEmpty, !password.isEmpty else {
            throw AuthError.invalidCredentials
        }

        let body = try JSONEncoder().encode(LoginRequest(username: username, password: password))
        let endpoint = Endpoint(
            path: "tokens",
            method: .post,
            headers: ["Content-Type": "application/json"],
            body: body,
            requiresAuth: false
        )

        let response: LoginResponse = try await networkService.request(endpoint)
        let token = AuthToken(token: response.token)
        tokenStorage.save(token)
        return token
    }

    func currentToken() -> AuthToken? {
        tokenStorage.loadToken()
    }

    func signOut() {
        tokenStorage.clear()
    }
}

private struct LoginRequest: Encodable {
    let username: String
    let password: String
}

private struct LoginResponse: Decodable {
    let token: String
}
