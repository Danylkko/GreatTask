//
//  ServersCacheProtocol.swift
//  GreatTask
//
//  Created by Danylo Litvinchuk on 07.08.2026.
//

protocol ServersCacheProtocol: Sendable {
    func load() async throws -> [ServerModel]
    func replace(with servers: [ServerModel]) async throws
    func clear() async throws
}
