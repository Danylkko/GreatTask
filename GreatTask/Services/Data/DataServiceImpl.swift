//
//  DataServiceImpl.swift
//  GreatTask
//
//  Created by Danylo Litvinchuk on 06.08.2026.
//

final class DataServiceImpl: DataServiceProtocol {

    private let networkService: NetworkServiceProtocol

    init(networkService: NetworkServiceProtocol) {
        self.networkService = networkService
    }

    func fetchServers() async throws -> [ServerModel] {
        try await networkService.request(Endpoint(path: "servers"))
    }
    
}
