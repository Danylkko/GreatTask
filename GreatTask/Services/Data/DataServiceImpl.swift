//
//  DataServiceImpl.swift
//  GreatTask
//
//  Created by Danylo Litvinchuk on 06.08.2026.
//

final class DataServiceImpl: DataServiceProtocol {
    
    private let networkService: NetworkServiceProtocol
    private let cache: ServersCacheProtocol
    
    init(
        networkService: NetworkServiceProtocol,
        cache: ServersCacheProtocol
    ) {
        self.networkService = networkService
        self.cache = cache
    }
    
    func cachedServers() async -> [ServerModel] {
        (try? await cache.load()) ?? []
    }
    
    func fetchServers() async throws -> [ServerModel] {
        let servers: [ServerModel] = try await networkService.request(Endpoint(path: "servers"))
        try? await cache.replace(with: servers)
        return servers
    }
    
    func clearCachedServers() async {
        try? await cache.clear()
    }

}
