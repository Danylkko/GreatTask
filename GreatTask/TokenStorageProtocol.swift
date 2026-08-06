//
//  TokenStorageProtocol.swift
//  GreatTask
//
//  Created by Danylo Litvinchuk on 06.08.2026.
//

import Foundation

protocol TokenStorageProtocol {
    func save(_ token: AuthToken)
    func loadToken() -> AuthToken?
    func clear()
}
