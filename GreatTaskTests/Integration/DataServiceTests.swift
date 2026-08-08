//
//  DataServiceTests.swift
//  GreatTaskTests
//
//  Integration: real SwiftData cache, stubbed network.
//

import SwiftData
import Testing
@testable import GreatTask

@MainActor
@Suite("DataService + cache")
struct DataServiceTests {

    private func makeSUT() throws -> (DataServiceImpl, FakeNetworkService, ServersCacheImpl) {
        let container = try ModelContainer(
            for: CachedServer.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        let cache = ServersCacheImpl(modelContainer: container)
        let network = FakeNetworkService()
        return (DataServiceImpl(networkService: network, cache: cache), network, cache)
    }

    @Test("a successful fetch is written through to the cache")
    func fetchWritesThroughToCache() async throws {
        let (service, network, _) = try makeSUT()
        network.stub(json: #"[{"name":"vilnius","distance":42}]"#)

        let fetched = try await service.fetchServers()
        #expect(fetched.map(\.name) == ["vilnius"])

        let cached = await service.cachedServers()
        #expect(cached.map(\.name) == ["vilnius"])
    }

    /// Offline behaviour: a failed refresh must never destroy what we can still show.
    @Test("a failed fetch leaves the previous cache intact")
    func failedFetchPreservesCache() async throws {
        let (service, network, _) = try makeSUT()
        network.stub(json: #"[{"name":"vilnius","distance":42}]"#)
        _ = try await service.fetchServers()

        network.stub(error: NetworkError.serverError(code: 500, body: nil))
        await #expect(throws: NetworkError.self) {
            try await service.fetchServers()
        }

        let cached = await service.cachedServers()
        #expect(cached.map(\.name) == ["vilnius"])
    }

    @Test("clearing removes the cached servers")
    func clearRemovesCachedServers() async throws {
        let (service, network, _) = try makeSUT()
        network.stub(json: #"[{"name":"vilnius","distance":42}]"#)
        _ = try await service.fetchServers()

        await service.clearCachedServers()

        #expect(await service.cachedServers().isEmpty)
    }
}
