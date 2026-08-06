//
//  DataServiceProtocol.swift
//  GreatTask
//
//  Created by Danylo Litvinchuk on 06.08.2026.
//

import Foundation

protocol DataServiceProtocol {
    func fetchServers() async throws -> [ServerModel]
}

struct ServerModel: Codable {
    let name: String
    let distance: Int
}
