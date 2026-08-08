//
//  ServersCacheTests.swift
//  GreatTaskTests
//
//  Integration: exercises the real SwiftData stack in an in-memory store.
//

import SwiftData
import Testing
@testable import GreatTask

@Suite("ServersCache (SwiftData)")
struct ServersCacheTests {

    private func makeSUT() throws -> ServersCacheImpl {
        let container = try ModelContainer(
            for: CachedServer.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        return ServersCacheImpl(modelContainer: container)
    }

    @Test("an empty store loads as an empty list rather than throwing")
    func loadsEmptyStore() async throws {
        let cache = try makeSUT()

        #expect(try await cache.load().isEmpty)
    }

    @Test("values survive the model round trip")
    func roundTripsValues() async throws {
        let cache = try makeSUT()

        try await cache.replace(with: [ServerModel(name: "vilnius", distance: 42)])
        let loaded = try await cache.load()

        #expect(loaded.count == 1)
        #expect(loaded.first?.name == "vilnius")
        #expect(loaded.first?.distance == 42)
    }

    /// `replace` deletes before inserting — a partial delete would leave stale rows behind.
    @Test("replacing with a smaller set removes the old rows")
    func replaceDoesNotAccumulate() async throws {
        let cache = try makeSUT()
        try await cache.replace(with: (1...5).map { ServerModel(name: "server-\($0)", distance: $0) })

        try await cache.replace(with: [
            ServerModel(name: "berlin", distance: 1),
            ServerModel(name: "amsterdam", distance: 2),
        ])

        let loaded = try await cache.load()
        #expect(loaded.count == 2)
        #expect(loaded.map(\.name) == ["amsterdam", "berlin"])
    }

    @Test("clear empties the store")
    func clearEmptiesStore() async throws {
        let cache = try makeSUT()
        try await cache.replace(with: [ServerModel(name: "vilnius", distance: 42)])

        try await cache.clear()

        #expect(try await cache.load().isEmpty)
    }
}
