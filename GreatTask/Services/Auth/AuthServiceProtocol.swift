//
//  AuthServiceProtocol.swift
//  GreatTask
//
//  Created by Danylo Litvinchuk on 06.08.2026.
//

import Foundation

protocol AuthServiceProtocol {
    func signIn(username: String, password: String) async throws -> AuthToken
    func currentToken() -> AuthToken?
    func signOut()
}

struct AuthToken: Equatable {
    let token: String
}

enum AuthError: LocalizedError {
    case invalidCredentials

    var errorDescription: String? {
        switch self {
        case .invalidCredentials:
            return "Enter a username and password."
        }
    }
}
