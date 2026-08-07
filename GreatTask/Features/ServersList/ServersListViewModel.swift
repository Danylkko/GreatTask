//
//  ServersListViewModel.swift
//  GreatTask
//
//  Created by Danylo Litvinchuk on 07.08.2026.
//

import SwiftUI

@MainActor
@Observable
final class ServersListViewModel {

    enum SortField {
        case name
        case distance
    }

    enum SortOrder {
        case ascending
        case descending
    }

    private var servers: [ServerModel] = []
    private(set) var isLoading = true
    private(set) var isRefreshing = false
    private(set) var errorMessage: String?
    private(set) var sortField: SortField = .name
    private(set) var sortOrder: SortOrder = .ascending

    var sortedServers: [ServerModel] {
        let ascending = sortOrder == .ascending
        switch sortField {
        case .name:
            return servers.sorted {
                ascending
                    ? $0.name.localizedStandardCompare($1.name) == .orderedAscending
                    : $0.name.localizedStandardCompare($1.name) == .orderedDescending
            }
        case .distance:
            return servers.sorted {
                ascending ? $0.distance < $1.distance : $0.distance > $1.distance
            }
        }
    }

    private let dataService: DataServiceProtocol
    private(set) var loadTask: Task<Void, Never>?

    init(dataService: DataServiceProtocol) {
        self.dataService = dataService
    }

    func loadServers() {
        guard loadTask == nil else { return }

        loadTask = Task {
            defer { loadTask = nil }

            if servers.isEmpty {
                let cached = await dataService.cachedServers()
                if !cached.isEmpty {
                    servers = cached
                    isLoading = false
                }
            }
            
            errorMessage = nil
            isRefreshing = !servers.isEmpty
            
            do {
                servers = try await dataService.fetchServers()
            } catch {
                errorMessage = error.localizedDescription
            }
            
            isLoading = false
            isRefreshing = false
        }
    }

    func toggleSort(_ field: SortField) {
        if sortField == field {
            sortOrder = sortOrder == .ascending ? .descending : .ascending
        } else {
            sortField = field
            sortOrder = .ascending
        }
    }
}
