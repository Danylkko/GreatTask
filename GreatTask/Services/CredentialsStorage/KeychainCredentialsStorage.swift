//
//  KeychainCredentialsStorage.swift
//  GreatTask
//
//  Created by Danylo Litvinchuk on 08.08.2026.
//

import Foundation

final class KeychainCredentialsStorage: CredentialsStorageProtocol {

    private let keychain: Keychain
    private let usernameKey = "credentialsUsername"
    private let passwordKey = "credentialsPassword"

    init(keychain: Keychain = Keychain(service: Bundle.main.bundleIdentifier ?? "GreatTask")) {
        self.keychain = keychain
    }

    func save(_ credentials: Credentials) {
        keychain[usernameKey] = credentials.username
        keychain[passwordKey] = credentials.password
    }

    func loadCredentials() -> Credentials? {
        guard let username = keychain[usernameKey],
              let password = keychain[passwordKey] else { return nil }
        return Credentials(username: username, password: password)
    }

    func clear() {
        keychain[usernameKey] = nil
        keychain[passwordKey] = nil
    }
}
