//
//  KeychainTokenStorage.swift
//  GreatTask
//
//  Created by Danylo Litvinchuk on 06.08.2026.
//

import Foundation

final class KeychainTokenStorage: TokenStorageProtocol {

    private let keychain: Keychain
    private let key = "authToken"

    init(keychain: Keychain = Keychain(service: Bundle.main.bundleIdentifier ?? "GreatTask")) {
        self.keychain = keychain
    }

    func save(_ token: AuthToken) {
        keychain[key] = token.token
    }

    func loadToken() -> AuthToken? {
        guard let value = keychain[key] else { return nil }
        return AuthToken(token: value)
    }

    func clear() {
        keychain[key] = nil
    }
}
