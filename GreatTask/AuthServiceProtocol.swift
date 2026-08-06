//
//  AuthServiceProtocol.swift
//  GreatTask
//
//  Created by Danylo Litvinchuk on 06.08.2026.
//

import Foundation

protocol AuthServiceProtocol {
    func signIn(username: String, password: String) async throws -> AuthToken
}

struct AuthToken: Equatable {
    let token: String
}
