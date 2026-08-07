//
//  ServersCacheImpl.swift
//  GreatTask
//
//  Created by Danylo Litvinchuk on 07.08.2026.
//

import Foundation
import SwiftData

@ModelActor
actor ServersCacheImpl: ServersCacheProtocol {

    func load() throws -> [ServerModel] {
        let descriptor = FetchDescriptor<CachedServer>(sortBy: [SortDescriptor(\.name)])
        return try modelContext.fetch(descriptor).map(\.server)
    }
    
    func replace(with servers: [ServerModel]) throws {
        try modelContext.delete(model: CachedServer.self)
        servers.forEach { modelContext.insert(CachedServer($0)) }
        try modelContext.save()
    }

    func clear() throws {
        try modelContext.delete(model: CachedServer.self)
        try modelContext.save()
    }
}

extension ModelContainer {

    static func serversCache() -> ModelContainer {
        if let container = try? ModelContainer(for: CachedServer.self) {
            return container
        }

        do {
            return try ModelContainer(
                for: CachedServer.self,
                configurations: ModelConfiguration(isStoredInMemoryOnly: true)
            )
        } catch {
            fatalError("Invalid CachedServer schema: \(error)")
        }
    }
}
