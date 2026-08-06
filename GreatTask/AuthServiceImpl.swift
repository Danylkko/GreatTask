//
//  AuthServiceImpl.swift
//  GreatTask
//
//  Created by Danylo Litvinchuk on 06.08.2026.
//

import Foundation

final class AuthServiceImpl: AuthServiceProtocol {

    private let tokenStorage: TokenStorageProtocol

    init(tokenStorage: TokenStorageProtocol) {
        self.tokenStorage = tokenStorage
    }

    func signIn(
        username: String,
        password: String
    ) async throws -> AuthToken {
        guard !username.isEmpty, !password.isEmpty else {
            throw AuthError.invalidCredentials
        }
        
        fatalError("\(#function) not implemented")
    }

    func currentToken() -> AuthToken? {
        tokenStorage.loadToken()
    }

    func signOut() {
        tokenStorage.clear()
    }
}
