//
//  CredentialsStorageProtocol.swift
//  GreatTask
//
//  Created by Danylo Litvinchuk on 08.08.2026.
//

import Foundation

protocol CredentialsStorageProtocol {
    func save(_ credentials: Credentials)
    func loadCredentials() -> Credentials?
    func clear()
}

struct Credentials: Equatable {
    let username: String
    let password: String
}
